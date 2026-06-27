import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_model.dart';

class AuctionService {
  static final _db = FirebaseFirestore.instance;
  static final _auctions = _db.collection('auctions');

  // ── Stream: مزادات نشطة (real-time) ──
  static Stream<List<AuctionModel>> streamActiveAuctions({int limit = 10}) {
    return _auctions
        .where('status', whereIn: ['active', 'endingSoon'])
        .orderBy('endTime')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(AuctionModel.fromFirestore).toList());
  }

  // ── Stream: مزاد واحد بالتفصيل ──
  static Stream<AuctionModel?> streamAuction(String id) {
    return _auctions.doc(id).snapshots().map(
          (s) => s.exists ? AuctionModel.fromFirestore(s) : null,
        );
  }

  // ── Stream: تاريخ المزايدات لمزاد ──
  static Stream<List<BidModel>> streamBids(String auctionId) {
    return _auctions
        .doc(auctionId)
        .collection('bids')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(BidModel.fromFirestore).toList());
  }

  // ── وضع مزايدة جديدة ──
  static Future<String?> placeBid({
    required AuctionModel auction,
    required String bidderId,
    required String bidderName,
    required String bidderPhoto,
    required double amount,
    Map<String, String> bidderContact = const {},
  }) async {
    // التحقق: المزاد لا يزال نشطاً
    if (!auction.isActive) return 'المزاد منتهي';
    if (DateTime.now().isAfter(auction.endTime)) return 'انتهى وقت المزاد';

    // التحقق: لا يزايد البائع على مزاده
    if (bidderId == auction.sellerId) return 'لا يمكنك المزايدة على مزادك';

    // التحقق: المبلغ أكبر من الحد الأدنى
    final minRequired = auction.currentPrice + auction.minBidIncrement;
    if (amount < minRequired) {
      final formattedPrice = auction.currency == 'USD'
          ? '\$${minRequired.toInt()}'
          : '${minRequired.toInt()} ل.س';
      return 'الحد الأدنى للمزايدة: $formattedPrice';
    }

    // التحقق: لم يكن هو المزايد الأعلى بالفعل
    if (bidderId == auction.highestBidderId) {
      return 'أنت بالفعل صاحب أعلى مزايدة';
    }

    try {
      await _db.runTransaction((tx) async {
        final auctionRef = _auctions.doc(auction.id);
        final freshSnap = await tx.get(auctionRef);
        if (!freshSnap.exists) throw Exception('المزاد غير موجود');

        final fresh = AuctionModel.fromFirestore(freshSnap);

        // تحقق مزدوج داخل Transaction لمنع race conditions
        if (amount < fresh.currentPrice + fresh.minBidIncrement) {
          throw Exception('مزايدة أعلى موجودة بالفعل');
        }

        // حساب الحالة الجديدة
        final remaining = fresh.endTime.difference(DateTime.now());
        final newStatus = remaining.inHours < 2 ? 'endingSoon' : 'active';

        // تحديث المزاد
        tx.update(auctionRef, {
          'currentPrice': amount,
          'highestBidderId': bidderId,
          'highestBidderName': bidderName,
          'highestBidderContact': bidderContact,
          'bidderPhotos': FieldValue.arrayUnion([bidderPhoto]),
          'totalBids': FieldValue.increment(1),
          'status': newStatus,
        });

        // إضافة المزايدة في subcollection
        final bidRef = auctionRef.collection('bids').doc();
        tx.set(bidRef, {
          'auctionId': auction.id,
          'bidderId': bidderId,
          'bidderName': bidderName,
          'bidderPhoto': bidderPhoto,
          'amount': amount,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      return null; // نجاح
    } on FirebaseException catch (e) {
      return e.message ?? 'خطأ في الاتصال';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  // ── إنشاء مزاد جديد ──
  static Future<String?> createAuction(AuctionModel auction) async {
    try {
      await _auctions.add(auction.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── تحديث عداد المشاهدات ──
  static Future<void> incrementViewCount(String auctionId) async {
    try {
      await _auctions
          .doc(auctionId)
          .update({'viewCount': FieldValue.increment(1)});
    } catch (_) {}
  }

  // ── حذف مزاد (البائع فقط) ──
  static Future<String?> deleteAuction(String auctionId) async {
    try {
      // حذف المزايدات الفرعية أولاً
      final bids = await _auctions.doc(auctionId).collection('bids').get();
      final batch = _db.batch();
      for (final doc in bids.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_auctions.doc(auctionId));
      await batch.commit();
      return null;
    } catch (e) {
      return 'فشل الحذف، حاول مجدداً';
    }
  }

  // ── تحديث حالة المزادات المنتهية (يُستدعى دورياً) ──
  static Future<void> updateExpiredAuctions() async {
    try {
      final now = Timestamp.now();
      final expired = await _auctions
          .where('status', whereIn: ['active', 'endingSoon'])
          .where('endTime', isLessThan: now)
          .limit(20)
          .get();

      final batch = _db.batch();
      for (final doc in expired.docs) {
        final data = doc.data();
        final hasBidder = data['highestBidderId'] != null;
        batch.update(doc.reference, {
          'status': hasBidder ? 'sold' : 'expired',
        });
      }
      if (expired.docs.isNotEmpty) await batch.commit();
    } catch (_) {}
  }
}
