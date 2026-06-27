import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/auction_model.dart';
import '../gen_l10n/app_localizations.dart';

class AuctionCard extends StatelessWidget {
  final AuctionModel auction;
  final VoidCallback onTap;

  const AuctionCard({super.key, required this.auction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = auction.computedStatus;
    final isEndingSoon = status == AuctionStatus.endingSoon;
    final isSold = status == AuctionStatus.sold;
    final isExpired = status == AuctionStatus.expired;
    final isDone = isSold || isExpired;
    final leaderPhoto = auction.sellerPhoto;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isEndingSoon
              ? Border.all(color: Colors.orange, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── الصورة الكاملة العرض ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: _buildImage(),
                  ),

                  // تعتيم عند الانتهاء
                  if (isDone)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.50),
                          child: Center(
                            child: Text(
                              isSold
                                  ? l10n.auctionStatusSold
                                  : l10n.auctionStatusExpired,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Badge الحالة — أعلى اليسار
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _StatusBadge(status: status),
                  ),

                  // Badge مميز
                  if (auction.isFeatured)
                    Positioned(
                      top: 6,
                      right: leaderPhoto.isNotEmpty ? 39 : 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          '⭐ مميز',
                          style: TextStyle(
                              fontSize: 7, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // أفاتار أعلى مزايد — زاوية علوية يمين
                  if (leaderPhoto.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFFD600), width: 2),
                          color: const Color(0xFFE5E7EB),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.20),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: leaderPhoto,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 14,
                                color: Color(0xFF9CA3AF)),
                            placeholder: (_, __) => const Icon(Icons.person,
                                size: 14, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── التفاصيل تحت الصورة ──
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // الاسم
                  Text(
                    auction.title,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 3),

                  // السعر
                  Text(
                    auction.currency == 'USD'
                        ? '\$${auction.currentPrice.toStringAsFixed(0)}'
                        : '${auction.currentPrice.toStringAsFixed(0)} ل.س',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF059669),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 3),

                  // المدينة + الدبوس
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        auction.city,
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 3),
                      const Text('📍', style: TextStyle(fontSize: 9)),
                    ],
                  ),

                  // الوقت المتبقي
                  if (!isDone) ...[
                    const SizedBox(height: 6),
                    _CountdownRow(endTime: auction.endTime),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (auction.images.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: auction.images.first,
        width: double.infinity,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.gavel, color: Color(0xFF9CA3AF), size: 33),
      );
}

// ══════════════════════════════════════════════════
// شريط الوقت المتبقي مع المنبه الدوار
// ══════════════════════════════════════════════════
class _CountdownRow extends StatefulWidget {
  final DateTime endTime;
  const _CountdownRow({required this.endTime});

  @override
  State<_CountdownRow> createState() => _CountdownRowState();
}

class _CountdownRowState extends State<_CountdownRow>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _remaining;
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _remaining = _calc();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _calc());
    });
  }

  Duration _calc() {
    final diff = widget.endTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent;
    if (_remaining.inHours < 1) {
      accent = const Color(0xFFDC2626);
    } else if (_remaining.inHours < 4) {
      accent = const Color(0xFFD97706);
    } else {
      accent = const Color(0xFF059669);
    }

    final hh = _remaining.inHours.toString().padLeft(2, '0');
    final mm = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: accent.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // الوقت + التسمية
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$hh:$mm:$ss',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // المنبه الدوار
          RotationTransition(
            turns: _spin,
            child: Image.asset(
              'assets/alarm_icons/clock1.png',
              width: 26,
              height: 26,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// Badge الحالة
// ══════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final AuctionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (Color bg, String text) = switch (status) {
      AuctionStatus.active => (
          const Color(0xFF059669),
          '🟢 ${l10n.auctionStatusActive}'
        ),
      AuctionStatus.endingSoon => (
          Colors.orange,
          '🔥 ${l10n.auctionStatusEndingSoon}'
        ),
      AuctionStatus.sold => (
          const Color(0xFF3B5BDB),
          '🔨 ${l10n.auctionStatusSold}'
        ),
      AuctionStatus.expired => (Colors.grey, '⏰ ${l10n.auctionStatusExpired}'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
    );
  }
}
