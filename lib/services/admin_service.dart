import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class AdminService {
  static final _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════════
  //  إعلانات
  // ══════════════════════════════════════════════════

  static Future<String?> deleteAdPermanently(String docId) async {
    try {
      await _db.collection('ads').doc(docId).delete();
      return null;
    } catch (_) {
      return 'فشل الحذف';
    }
  }

  static Future<String?> toggleAdVisibility(String docId, bool hidden) async {
    try {
      await _db.collection('ads').doc(docId).update({'hidden': hidden});
      return null;
    } catch (_) {
      return 'فشل التحديث';
    }
  }

  static Future<String?> updateAd(
      String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection('ads').doc(docId).update(data);
      return null;
    } catch (_) {
      return 'فشل التحديث';
    }
  }

  static Future<String?> replaceAdImage(
      String docId, int imageIndex, Uint8List imageBytes) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('ads/$docId/image_$imageIndex.jpg');
      await ref.putData(imageBytes);
      final url = await ref.getDownloadURL();
      final doc = await _db.collection('ads').doc(docId).get();
      final images = List<String>.from(doc.data()?['images'] ?? []);
      if (imageIndex < images.length) {
        images[imageIndex] = url;
      } else {
        images.add(url);
      }
      await _db.collection('ads').doc(docId).update({'images': images});
      return null;
    } catch (e) {
      return 'فشل رفع الصورة';
    }
  }

  static Future<String?> updateAdImageUrl(
      String docId, int imageIndex, String url) async {
    try {
      final doc = await _db.collection('ads').doc(docId).get();
      final images = List<String>.from(doc.data()?['images'] ?? []);
      if (imageIndex < images.length) {
        images[imageIndex] = url;
      } else {
        images.add(url);
      }
      await _db.collection('ads').doc(docId).update({'images': images});
      return null;
    } catch (_) {
      return 'فشل التحديث';
    }
  }

  // ══════════════════════════════════════════════════
  //  مزادات
  // ══════════════════════════════════════════════════

  static Future<String?> deleteAuctionPermanently(String id) async {
    try {
      final bids = await _db
          .collection('auctions')
          .doc(id)
          .collection('bids')
          .get();
      final batch = _db.batch();
      for (final d in bids.docs) {
        batch.delete(d.reference);
      }
      batch.delete(_db.collection('auctions').doc(id));
      await batch.commit();
      return null;
    } catch (_) {
      return 'فشل الحذف';
    }
  }

  static Future<String?> toggleAuctionVisibility(
      String id, bool hidden) async {
    try {
      await _db.collection('auctions').doc(id).update({'hidden': hidden});
      return null;
    } catch (_) {
      return 'فشل التحديث';
    }
  }

  static Future<String?> cancelAuction(String id) async {
    try {
      await _db.collection('auctions').doc(id).update({
        'status': 'cancelled',
        'hidden': true,
      });
      return null;
    } catch (_) {
      return 'فشل الإلغاء';
    }
  }

  static Future<String?> updateAuction(
      String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('auctions').doc(id).update(data);
      return null;
    } catch (_) {
      return 'فشل التحديث';
    }
  }

  // ══════════════════════════════════════════════════
  //  حظر الأجهزة والمستخدمين
  // ══════════════════════════════════════════════════

  static Future<String?> banDevice(String deviceId,
      {DateTime? until}) async {
    try {
      await _db.collection('devices').doc(deviceId).set({
        'banned': true,
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedUntil':
            until != null ? Timestamp.fromDate(until) : null,
      }, SetOptions(merge: true));
      return null;
    } catch (_) {
      return 'فشل الحظر';
    }
  }

  static Future<String?> unbanDevice(String deviceId) async {
    try {
      await _db.collection('devices').doc(deviceId).update({
        'banned': false,
        'bannedUntil': null,
      });
      return null;
    } catch (_) {
      return 'فشل رفع الحظر';
    }
  }

  static Future<String?> banUser(String userId,
      {DateTime? until}) async {
    try {
      await _db.collection('users').doc(userId).update({
        'banned': true,
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedUntil':
            until != null ? Timestamp.fromDate(until) : null,
      });
      return null;
    } catch (_) {
      return 'فشل الحظر';
    }
  }

  static Future<String?> unbanUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'banned': false,
        'bannedUntil': null,
      });
      return null;
    } catch (_) {
      return 'فشل رفع الحظر';
    }
  }

  static Future<bool> checkDeviceBan(String deviceId) async {
    try {
      final doc =
          await _db.collection('devices').doc(deviceId).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      if (data['banned'] != true) return false;
      final until = data['bannedUntil'] as Timestamp?;
      if (until == null) return true;
      if (until.toDate().isAfter(DateTime.now())) return true;
      await _db.collection('devices').doc(deviceId).update(
          {'banned': false, 'bannedUntil': null});
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkUserBan(String userId) async {
    try {
      final doc =
          await _db.collection('users').doc(userId).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      if (data['banned'] != true) return false;
      final until = data['bannedUntil'] as Timestamp?;
      if (until == null) return true;
      if (until.toDate().isAfter(DateTime.now())) return true;
      await _db.collection('users').doc(userId).update(
          {'banned': false, 'bannedUntil': null});
      return false;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════
  //  Streams للوحة التحكم
  // ══════════════════════════════════════════════════

  static Stream<QuerySnapshot> streamAllAds() => _db
      .collection('ads')
      .orderBy('createdAt', descending: true)
      .limit(200)
      .snapshots();

  static Stream<QuerySnapshot> streamAllAuctions() => _db
      .collection('auctions')
      .orderBy('endTime', descending: true)
      .limit(200)
      .snapshots();

  static Stream<QuerySnapshot> streamAllUsers() => _db
      .collection('users')
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots();

  static Stream<QuerySnapshot> streamBannedDevices() => _db
      .collection('devices')
      .where('banned', isEqualTo: true)
      .snapshots();
}
