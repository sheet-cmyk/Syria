const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {getMessaging} = require("firebase-admin/messaging");
const nodemailer = require("nodemailer");

initializeApp();

const GMAIL_PASS = defineSecret("GMAIL_PASS");
const GMAIL_USER = "alzainsheet@gmail.com";

// ─── حد الأجهزة ──────────────────────────────────────────────────────────────
exports.checkDeviceLimit = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "غير مصرح");
  }

  const deviceId = request.data.deviceId;
  const uid = request.auth.uid;

  if (!deviceId || deviceId === "unknown") {
    return {allowed: true};
  }

  const db = getFirestore();
  const deviceRef = db.collection("devices").doc(deviceId);
  const deviceSnap = await deviceRef.get();

  if (deviceSnap.exists) {
    const accounts = deviceSnap.data().accounts || [];
    if (accounts.includes(uid)) return {allowed: true};
    if (accounts.length >= 3) {
      try { await getAuth().deleteUser(uid); } catch (e) {}
      return {allowed: false};
    }
    await deviceRef.update({
      accounts: FieldValue.arrayUnion(uid),
      updatedAt: FieldValue.serverTimestamp(),
    });
  } else {
    await deviceRef.set({
      accounts: [uid],
      createdAt: FieldValue.serverTimestamp(),
    });
  }

  return {allowed: true};
});

// ─── كشف المزادات المنتهية كل دقيقة ─────────────────────────────────────────
exports.checkExpiredAuctions = onSchedule(
  {schedule: "every 1 minutes", secrets: [GMAIL_PASS]},
  async () => {
    const db = getFirestore();
    const now = new Date();

    console.log(`[checkExpiredAuctions] تشغيل عند ${now.toISOString()}`);

    let snapshot;
    try {
      snapshot = await db.collection("auctions")
        .where("status", "in", ["active", "endingSoon"])
        .where("endTime", "<=", now)
        .get();
    } catch (err) {
      console.error("[checkExpiredAuctions] خطأ في الاستعلام:", err);
      return;
    }

    if (snapshot.empty) {
      console.log("[checkExpiredAuctions] لا توجد مزادات منتهية");
      return;
    }

    console.log(`[checkExpiredAuctions] وُجد ${snapshot.size} مزاد منتهٍ`);

    const mailer = _createMailer();
    const batch = db.batch();

    for (const doc of snapshot.docs) {
      const auction = doc.data();
      const newStatus = auction.highestBidderId ? "sold" : "expired";

      console.log(`[checkExpiredAuctions] مزاد ${doc.id} → ${newStatus}`);
      batch.update(doc.ref, {status: newStatus});

      if (newStatus === "sold") {
        try { await _notifyWinner(db, mailer, auction, doc.id); } catch (e) {
          console.error(`[notifyWinner] خطأ للمزاد ${doc.id}:`, e);
        }
        try { await _notifySeller(db, mailer, auction, doc.id); } catch (e) {
          console.error(`[notifySeller] خطأ للمزاد ${doc.id}:`, e);
        }
      }
    }

    try {
      await batch.commit();
      console.log("[checkExpiredAuctions] تم تحديث الحالات بنجاح");
    } catch (err) {
      console.error("[checkExpiredAuctions] خطأ في batch.commit:", err);
    }
  }
);

// ─── إنشاء Nodemailer transporter ─────────────────────────────────────────────
function _createMailer() {
  return nodemailer.createTransport({
    service: "gmail",
    auth: {user: GMAIL_USER, pass: GMAIL_PASS.value()},
  });
}

// ─── إشعار الفائز ─────────────────────────────────────────────────────────────
async function _notifyWinner(db, mailer, auction, auctionId) {
  const winnerId = auction.highestBidderId;
  console.log(`[notifyWinner] معالجة الفائز ${winnerId}`);

  const winnerDoc = await db.collection("users").doc(winnerId).get();
  if (!winnerDoc.exists) {
    console.warn(`[notifyWinner] المستخدم ${winnerId} غير موجود`);
    return;
  }
  const winner = winnerDoc.data();
  const sellerContact = auction.sellerContact || {};
  const contactLines = _buildContactLines(sellerContact);

  const title = "🏆 مبروك! فزت بالمزاد";
  const body = `فزت بـ "${auction.title}" بسعر €${auction.currentPrice}`;

  // حفظ في Firestore
  await db.collection("users").doc(winnerId)
    .collection("notifications").add({
      type: "auction_won",
      title,
      body,
      auctionId,
      sellerName: auction.sellerName,
      sellerId: auction.sellerId,
      sellerPhoto: auction.sellerPhoto || "",
      sellerContact,
      contactLines,
      createdAt: FieldValue.serverTimestamp(),
      read: false,
    });

  // Push Notification
  if (winner.fcmToken && winner.notificationsEnabled !== false) {
    try {
      await getMessaging().send({
        token: winner.fcmToken,
        notification: {title, body},
        data: {type: "auction_won", auctionId, click_action: "FLUTTER_NOTIFICATION_CLICK"},
        android: {priority: "high"},
      });
      console.log(`[notifyWinner] Push أُرسل للفائز ${winnerId}`);
    } catch (e) {
      console.error(`[notifyWinner] فشل Push للفائز ${winnerId}:`, e);
    }
  }

  // بريد إلكتروني
  if (winner.email) {
    try {
      await mailer.sendMail({
        from: `"Next.DE - المزادات" <${GMAIL_USER}>`,
        to: winner.email,
        subject: `🏆 مبروك! فزت بمزاد "${auction.title}"`,
        html: _winnerEmailHtml({
          winnerName: winner.name || auction.highestBidderName,
          auctionTitle: auction.title,
          price: auction.currentPrice,
          sellerName: auction.sellerName,
          contactLines,
          sellerContact,
        }),
      });
      console.log(`[notifyWinner] بريد أُرسل للفائز: ${winner.email}`);
    } catch (e) {
      console.error(`[notifyWinner] فشل إرسال البريد للفائز:`, e);
    }
  } else {
    console.warn(`[notifyWinner] لا يوجد بريد إلكتروني للفائز ${winnerId}`);
  }
}

// ─── إشعار البائع ─────────────────────────────────────────────────────────────
async function _notifySeller(db, mailer, auction, auctionId) {
  const sellerId = auction.sellerId;
  console.log(`[notifySeller] معالجة البائع ${sellerId}`);

  const sellerDoc = await db.collection("users").doc(sellerId).get();
  if (!sellerDoc.exists) {
    console.warn(`[notifySeller] البائع ${sellerId} غير موجود`);
    return;
  }
  const seller = sellerDoc.data();

  // بيانات تواصل الفائز محفوظة في وثيقة المزاد مباشرةً عند المزايدة
  const winnerContact = auction.highestBidderContact || {};

  // إذا فارغة نحاول جلبها من الملف الشخصي كبديل
  if (Object.keys(winnerContact).length === 0) {
    const winnerDoc = await db.collection("users").doc(auction.highestBidderId).get();
    const winnerData = winnerDoc.exists ? winnerDoc.data() : {};
    if (winnerData.phone) winnerContact.phone = winnerData.phone;
    const social = winnerData.socialLinks || {};
    if (social.whatsapp) winnerContact.whatsapp = social.whatsapp;
    if (social.facebook) winnerContact.facebook = social.facebook;
    if (social.instagram) winnerContact.instagram = social.instagram;
  }
  const contactLines = _buildContactLines(winnerContact);

  const title = "✅ تم بيع سلعتك!";
  const body = `بيعت "${auction.title}" بـ €${auction.currentPrice} للمشتري ${auction.highestBidderName}`;

  // حفظ في Firestore
  await db.collection("users").doc(sellerId)
    .collection("notifications").add({
      type: "auction_sold",
      title,
      body,
      auctionId,
      buyerName: auction.highestBidderName,
      buyerId: auction.highestBidderId,
      winnerContact,
      contactLines,
      createdAt: FieldValue.serverTimestamp(),
      read: false,
    });

  // Push Notification
  if (seller.fcmToken && seller.notificationsEnabled !== false) {
    try {
      await getMessaging().send({
        token: seller.fcmToken,
        notification: {title, body},
        data: {type: "auction_sold", auctionId, click_action: "FLUTTER_NOTIFICATION_CLICK"},
        android: {priority: "high"},
      });
      console.log(`[notifySeller] Push أُرسل للبائع ${sellerId}`);
    } catch (e) {
      console.error(`[notifySeller] فشل Push للبائع ${sellerId}:`, e);
    }
  }

  // بريد إلكتروني
  if (seller.email) {
    try {
      await mailer.sendMail({
        from: `"Next.DE - المزادات" <${GMAIL_USER}>`,
        to: seller.email,
        subject: `✅ تم بيع مزادك "${auction.title}"`,
        html: _sellerEmailHtml({
          sellerName: seller.name || auction.sellerName,
          auctionTitle: auction.title,
          price: auction.currentPrice,
          buyerName: auction.highestBidderName,
          contactLines,
          winnerContact,
        }),
      });
      console.log(`[notifySeller] بريد أُرسل للبائع: ${seller.email}`);
    } catch (e) {
      console.error(`[notifySeller] فشل إرسال البريد للبائع:`, e);
    }
  } else {
    console.warn(`[notifySeller] لا يوجد بريد إلكتروني للبائع ${sellerId}`);
  }
}

// ─── قالب بريد الفائز ─────────────────────────────────────────────────────────
function _winnerEmailHtml({winnerName, auctionTitle, price, sellerName, sellerContact}) {
  const rows = [];
  if (sellerContact.phone) rows.push(`<tr><td>📞 الهاتف</td><td>${sellerContact.phone}</td></tr>`);
  if (sellerContact.whatsapp) rows.push(`<tr><td>💬 واتساب</td><td>${sellerContact.whatsapp}</td></tr>`);
  if (sellerContact.facebook) rows.push(`<tr><td>👤 فيسبوك</td><td><a href="${sellerContact.facebook}">${sellerContact.facebook}</a></td></tr>`);
  if (sellerContact.instagram) rows.push(`<tr><td>📸 إنستقرام</td><td><a href="${sellerContact.instagram}">${sellerContact.instagram}</a></td></tr>`);

  return `
  <div dir="rtl" style="font-family:Arial,sans-serif;max-width:600px;margin:auto;background:#f9f9f9;padding:20px;border-radius:12px;">
    <div style="background:linear-gradient(135deg,#1A237E,#1565C0);padding:30px;border-radius:12px;text-align:center;margin-bottom:20px;">
      <div style="font-size:60px;">🏆</div>
      <h1 style="color:#FFD600;margin:10px 0;">مبروك عليك!</h1>
      <p style="color:white;margin:0;">فزت بالمزاد</p>
    </div>
    <div style="background:white;padding:20px;border-radius:10px;margin-bottom:16px;">
      <p>مرحباً <strong>${winnerName}</strong>،</p>
      <p>تهانينا! لقد فزت بمزاد <strong>"${auctionTitle}"</strong> بسعر <strong style="color:#059669;">€${price}</strong>.</p>
    </div>
    <div style="background:white;padding:20px;border-radius:10px;margin-bottom:16px;">
      <h3 style="color:#1A237E;margin-top:0;">📋 معلومات تواصل البائع (${sellerName})</h3>
      <table style="width:100%;border-collapse:collapse;">
        ${rows.join("")}
      </table>
      ${rows.length === 0 ? "<p style='color:gray;'>لم يضف البائع معلومات تواصل</p>" : ""}
    </div>
    <p style="color:#6B7280;font-size:12px;text-align:center;">Next.DE — كل شيء في مكان واحد</p>
  </div>`;
}

// ─── قالب بريد البائع ─────────────────────────────────────────────────────────
function _sellerEmailHtml({sellerName, auctionTitle, price, buyerName, winnerContact}) {
  const rows = [];
  if (winnerContact.email) rows.push(`<tr><td>📧 البريد</td><td><a href="mailto:${winnerContact.email}">${winnerContact.email}</a></td></tr>`);
  if (winnerContact.phone) rows.push(`<tr><td>📞 الهاتف</td><td>${winnerContact.phone}</td></tr>`);
  if (winnerContact.whatsapp) rows.push(`<tr><td>💬 واتساب</td><td>${winnerContact.whatsapp}</td></tr>`);
  if (winnerContact.facebook) rows.push(`<tr><td>👤 فيسبوك</td><td><a href="${winnerContact.facebook}">${winnerContact.facebook}</a></td></tr>`);
  if (winnerContact.instagram) rows.push(`<tr><td>📸 إنستقرام</td><td><a href="${winnerContact.instagram}">${winnerContact.instagram}</a></td></tr>`);

  return `
  <div dir="rtl" style="font-family:Arial,sans-serif;max-width:600px;margin:auto;background:#f9f9f9;padding:20px;border-radius:12px;">
    <div style="background:linear-gradient(135deg,#059669,#047857);padding:30px;border-radius:12px;text-align:center;margin-bottom:20px;">
      <div style="font-size:60px;">✅</div>
      <h1 style="color:white;margin:10px 0;">تم بيع سلعتك!</h1>
    </div>
    <div style="background:white;padding:20px;border-radius:10px;margin-bottom:16px;">
      <p>مرحباً <strong>${sellerName}</strong>،</p>
      <p>تهانينا! تم بيع مزادك <strong>"${auctionTitle}"</strong> بسعر <strong style="color:#059669;">€${price}</strong> للمشتري <strong>${buyerName}</strong>.</p>
    </div>
    <div style="background:white;padding:20px;border-radius:10px;margin-bottom:16px;">
      <h3 style="color:#059669;margin-top:0;">📋 معلومات تواصل المشتري (${buyerName})</h3>
      <table style="width:100%;border-collapse:collapse;">
        ${rows.join("")}
      </table>
      ${rows.length === 0 ? "<p style='color:gray;'>المشتري لم يضف معلومات تواصل في ملفه الشخصي</p>" : ""}
    </div>
    <p style="color:#6B7280;font-size:12px;text-align:center;">Next.DE — كل شيء في مكان واحد</p>
  </div>`;
}

// ─── بناء نص التواصل ──────────────────────────────────────────────────────────
function _buildContactLines(contact) {
  const lines = [];
  if (contact.email) lines.push(`📧 ${contact.email}`);
  if (contact.phone) lines.push(`📞 ${contact.phone}`);
  if (contact.whatsapp) lines.push(`💬 واتساب: ${contact.whatsapp}`);
  if (contact.facebook) lines.push(`👤 فيسبوك: ${contact.facebook}`);
  if (contact.instagram) lines.push(`📸 إنستقرام: ${contact.instagram}`);
  return lines.join("\n");
}
