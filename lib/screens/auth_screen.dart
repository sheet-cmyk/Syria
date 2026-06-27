import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../gen_l10n/app_localizations.dart';
import '../gen_l10n/app_localizations_ar.dart';
import 'language_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loading = false;
  String? _error;
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _disposed = false;

  static const _langStrip = [
    {'code': 'ar',  'flag': '🇮🇶', 'label': 'AR'},
    {'code': 'en',  'flag': '🇺🇸', 'label': 'EN'},
    {'code': 'ku',  'flag': 'ku',  'label': 'KU'},
  ];

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    VideoPlayerController? ctrl;
    try {
      ctrl = VideoPlayerController.asset('assets/videos/intro.mp4');
      await ctrl.initialize();
      if (_disposed) { ctrl.dispose(); return; }
      _videoCtrl = ctrl;
      await _videoCtrl!.setLooping(true);
      await _videoCtrl!.setVolume(1.0);
      await _videoCtrl!.play();
      if (mounted) setState(() => _videoReady = true);
    } catch (e) {
      debugPrint('Video error: $e');
      ctrl?.dispose();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _videoCtrl?.dispose();
    super.dispose();
  }

  Future<void> _googleLogin() async {
    setState(() { _loading = true; _error = null; });
    final error = await AuthService.loginWithGoogle();
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
    } else if (error == 'cancelled') {
      setState(() => _loading = false);
    } else {
      setState(() { _error = error; _loading = false; });
    }
  }

  Future<void> _changeLang(String code) async {
    await LocaleService.setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsAr();
    final currentCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── فيديو الخلفية ──
          if (_videoReady && _videoCtrl != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoCtrl!.value.size.width,
                height: _videoCtrl!.value.size.height,
                child: VideoPlayer(_videoCtrl!),
              ),
            )
          else
            Container(color: Colors.black),

          // ── تعتيم ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x44000000), Color(0x88000000), Color(0xDD000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── المحتوى الكامل ──
          SafeArea(
            child: Column(
              children: [
                // ── شريط اللغات أفقي بالأعلى ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _langStrip.map((lang) {
                      final isActive = lang['code'] == currentCode;
                      return GestureDetector(
                        onTap: () => _changeLang(lang['code']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFFD600).withValues(alpha: 0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isActive
                                ? Border.all(color: const Color(0xFFFFD600), width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (lang['flag'] == 'ku')
                                const KurdishFlag(size: 18)
                              else
                                Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 2),
                              Text(
                                lang['label']!,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  color: isActive ? const Color(0xFFFFD600) : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ── المحتوى الرئيسي ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // رسالة الخطأ
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(color: Colors.red, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // زر Google
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _googleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 2,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const _GoogleColorIcon(),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          l.loginWithGoogle,
                                          style: const TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // متابعة بدون تسجيل
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              l.continueWithoutLogin,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleColorIcon extends StatelessWidget {
  const _GoogleColorIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleColorPainter()),
    );
  }
}

class _GoogleColorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
            color: Color(0xFF4285F4), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}


