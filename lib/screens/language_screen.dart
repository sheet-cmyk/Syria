import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../main.dart';

class KurdishFlag extends StatelessWidget {
  final double size;
  const KurdishFlag({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: size * 1.5,
        height: size,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: Container(color: const Color(0xFFD21034))),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: const Color(0xFF007A3D))),
              ],
            ),
            Center(
              child: CustomPaint(
                size: Size(size * 0.55, size * 0.55),
                painter: _KurdishSunPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KurdishSunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.42;
    final rayStart = outerR * 0.52;

    final rayPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = outerR * 0.13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 21; i++) {
      final angle = (i * 2 * math.pi / 21) - math.pi / 2;
      canvas.drawLine(
        Offset(center.dx + rayStart * math.cos(angle),
            center.dy + rayStart * math.sin(angle)),
        Offset(center.dx + outerR * math.cos(angle),
            center.dy + outerR * math.sin(angle)),
        rayPaint,
      );
    }

    canvas.drawCircle(
        center,
        innerR,
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_KurdishSunPainter old) => false;
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  // Keep only Arabic (Iraq flag), English (US flag), and Kurdish (custom flag)
  static const _languages = [
    {'name': 'العربية', 'native': 'العربية', 'code': 'ar', 'flag': '🇮🇶'},
    {'name': 'English', 'native': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Kurdî', 'native': 'کوردی', 'code': 'ku', 'flag': 'ku'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentCode = MyApp.of(context)?.locale.languageCode ?? 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('اللغة / Sprache / Langue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFD600),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        itemBuilder: (_, i) {
          final lang = _languages[i];
          final isSelected = lang['code'] == currentCode;
          return GestureDetector(
            onTap: () {
              MyApp.of(context)?.setLocale(Locale(lang['code']!));
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFFDE7) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFFFD600) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 6)
                ],
              ),
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        color: Color(0xFFFFD600), size: 22)
                  else
                    const SizedBox(width: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang['name']!,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500)),
                        Text(lang['native']!,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  if (lang['flag'] == 'ku')
                    const KurdishFlag(size: 28)
                  else
                    Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
