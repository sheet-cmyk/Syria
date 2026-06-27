import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WinnerDialog extends StatelessWidget {
  final String auctionTitle;
  final double winningPrice;
  final String sellerName;
  final String sellerPhoto;
  final VoidCallback onContactSeller;

  const WinnerDialog({
    super.key,
    required this.auctionTitle,
    required this.winningPrice,
    required this.sellerName,
    required this.sellerPhoto,
    required this.onContactSeller,
  });

  static Future<void> show(
    BuildContext context, {
    required String auctionTitle,
    required double winningPrice,
    required String sellerName,
    required String sellerPhoto,
    required VoidCallback onContactSeller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: WinnerDialog(
          auctionTitle: auctionTitle,
          winningPrice: winningPrice,
          sellerName: sellerName,
          sellerPhoto: sellerPhoto,
          onContactSeller: () {
            Navigator.pop(context);
            onContactSeller();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 60, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 28, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط السحب
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // أيقونة الكأس
            const Text('🏆', style: TextStyle(fontSize: 72))
                .animate()
                .scale(duration: 700.ms, curve: Curves.elasticOut)
                .then()
                .shake(duration: 500.ms, hz: 4),

            const SizedBox(height: 16),

            Text(
              'مبروك عليك!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFFFD600),
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 6),

            const Text(
              'فزت بالمزاد',
              style: TextStyle(color: Colors.white60, fontSize: 15),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // بطاقة التفاصيل
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'السلعة', value: auctionTitle),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  _InfoRow(
                    label: 'سعر الفوز',
                    value: '${winningPrice.toStringAsFixed(2)} ل.س',
                    valueColor: const Color(0xFFFFD600),
                    valueFontSize: 20,
                    valueBold: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white24,
                            backgroundImage: sellerPhoto.isNotEmpty
                                ? NetworkImage(sellerPhoto)
                                : null,
                            child: sellerPhoto.isEmpty
                                ? const Icon(Icons.person,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sellerName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      const Text('البائع',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // زر التواصل مع البائع
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContactSeller,
                icon: const Icon(Icons.chat_rounded, size: 20),
                label: const Text(
                  'تواصل مع البائع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'لاحقاً',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double valueFontSize;
  final bool valueBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontSize = 14,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: valueFontSize,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }
}
