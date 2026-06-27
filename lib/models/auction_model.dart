import 'package:cloud_firestore/cloud_firestore.dart';

enum AuctionStatus { active, endingSoon, sold, expired }

class AuctionModel {
  final String id;
  final String title;
  final String description;
  final String sellerId;
  final String sellerName;
  final String sellerPhoto;
  final bool sellerVerified;
  final List<String> images;
  final String category;
  final String city;
  final double startingPrice;
  final double currentPrice;
  final double minBidIncrement;
  final String? highestBidderId;
  final String? highestBidderName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalBids;
  final int viewCount;
  final AuctionStatus status;
  final bool isFeatured;
  final String? videoUrl;
  final List<String> bidderPhotos; // صور المزايدين لعرضها في الكارد
  final Map<String, String>
      sellerContact; // {phone, whatsapp, facebook, instagram}
  final String currency; // 'SYP' or 'USD'

  const AuctionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhoto,
    required this.sellerVerified,
    required this.images,
    required this.category,
    required this.city,
    required this.startingPrice,
    required this.currentPrice,
    required this.minBidIncrement,
    this.highestBidderId,
    this.highestBidderName,
    required this.startTime,
    required this.endTime,
    required this.totalBids,
    required this.viewCount,
    required this.status,
    required this.isFeatured,
    this.videoUrl,
    this.bidderPhotos = const [],
    this.sellerContact = const {},
    this.currency = 'SYP',
  });

  bool get isActive =>
      status == AuctionStatus.active || status == AuctionStatus.endingSoon;

  Duration get timeRemaining {
    final now = DateTime.now();
    if (endTime.isBefore(now)) return Duration.zero;
    return endTime.difference(now);
  }

  AuctionStatus get computedStatus {
    final now = DateTime.now();
    if (endTime.isBefore(now)) {
      return highestBidderId != null
          ? AuctionStatus.sold
          : AuctionStatus.expired;
    }
    final remaining = endTime.difference(now);
    if (remaining.inHours < 2) return AuctionStatus.endingSoon;
    return AuctionStatus.active;
  }

  factory AuctionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AuctionModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      sellerId: d['sellerId'] ?? '',
      sellerName: d['sellerName'] ?? '',
      sellerPhoto: d['sellerPhoto'] ?? '',
      sellerVerified: d['sellerVerified'] ?? false,
      images: List<String>.from(d['images'] ?? []),
      category: d['category'] ?? '',
      city: d['city'] ?? '',
      startingPrice: (d['startingPrice'] ?? 0).toDouble(),
      currentPrice: (d['currentPrice'] ?? 0).toDouble(),
      minBidIncrement: (d['minBidIncrement'] ?? 1).toDouble(),
      highestBidderId: d['highestBidderId'],
      highestBidderName: d['highestBidderName'],
      startTime: (d['startTime'] as Timestamp).toDate(),
      endTime: (d['endTime'] as Timestamp).toDate(),
      totalBids: d['totalBids'] ?? 0,
      viewCount: d['viewCount'] ?? 0,
      status: _statusFromString(d['status']),
      isFeatured: d['isFeatured'] ?? false,
      videoUrl: d['videoUrl'] as String?,
      bidderPhotos: List<String>.from(d['bidderPhotos'] ?? []),
      sellerContact: Map<String, String>.from(d['sellerContact'] ?? {}),
      currency: d['currency'] ?? 'SYP',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerPhoto': sellerPhoto,
        'sellerVerified': sellerVerified,
        'images': images,
        'category': category,
        'city': city,
        'startingPrice': startingPrice,
        'currentPrice': currentPrice,
        'minBidIncrement': minBidIncrement,
        'highestBidderId': highestBidderId,
        'highestBidderName': highestBidderName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'totalBids': totalBids,
        'viewCount': viewCount,
        'status': _statusToString(status),
        'isFeatured': isFeatured,
        if (videoUrl != null && videoUrl!.isNotEmpty) 'videoUrl': videoUrl,
        'bidderPhotos': bidderPhotos,
        'sellerContact': sellerContact,
        'currency': currency,
      };

  static AuctionStatus _statusFromString(String? s) {
    switch (s) {
      case 'endingSoon':
        return AuctionStatus.endingSoon;
      case 'sold':
        return AuctionStatus.sold;
      case 'expired':
        return AuctionStatus.expired;
      default:
        return AuctionStatus.active;
    }
  }

  static String _statusToString(AuctionStatus s) {
    switch (s) {
      case AuctionStatus.endingSoon:
        return 'endingSoon';
      case AuctionStatus.sold:
        return 'sold';
      case AuctionStatus.expired:
        return 'expired';
      default:
        return 'active';
    }
  }
}

class BidModel {
  final String id;
  final String auctionId;
  final String bidderId;
  final String bidderName;
  final String bidderPhoto;
  final double amount;
  final DateTime createdAt;

  const BidModel({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.bidderName,
    required this.bidderPhoto,
    required this.amount,
    required this.createdAt,
  });

  factory BidModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BidModel(
      id: doc.id,
      auctionId: d['auctionId'] ?? '',
      bidderId: d['bidderId'] ?? '',
      bidderName: d['bidderName'] ?? '',
      bidderPhoto: d['bidderPhoto'] ?? '',
      amount: (d['amount'] ?? 0).toDouble(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'auctionId': auctionId,
        'bidderId': bidderId,
        'bidderName': bidderName,
        'bidderPhoto': bidderPhoto,
        'amount': amount,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
