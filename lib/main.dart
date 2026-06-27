import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/ad_deep_link_screen.dart';
import 'services/notification_service.dart';
import 'services/locale_service.dart';
import 'firebase_options.dart';
import 'gen_l10n/app_localizations.dart';
import 'gen_l10n/kurdish_localizations.dart';

// معالج FCM في الخلفية — للموبايل فقط
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.showLocalNotification(
    title:
        message.notification?.title ?? message.data['title'] ?? 'رسالة جديدة',
    body: message.notification?.body ?? message.data['body'] ?? '',
  );
}

// ─── دعم الكردي (Material) ───────────────────────────────────────────────────
class _KuMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _KuMaterialDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
  @override
  bool shouldReload(_KuMaterialDelegate old) => false;
}

// ─── دعم الكردي (Cupertino) ──────────────────────────────────────────────────
class _KuCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KuCupertinoDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));
  @override
  bool shouldReload(_KuCupertinoDelegate old) => false;
}

// ─── اللغات المدعومة في التطبيق ──────────────────────────────────────────────
const _kSupportedLangCodes = {
  'ar',
  'en',
  'ku',
};

/// يقرأ لغة الجهاز ويعيد كودها إذا كانت مدعومة، وإلا يعيد الإنجليزية.
/// يُستدعى فقط عند أول تشغيل (قبل أن يختار المستخدم لغةً ويحفظها).
String _resolveDeviceLocale() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return _kSupportedLangCodes.contains(code) ? code : 'en';
}

// ─── main ────────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // معالج FCM في الخلفية — موبايل فقط
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // تفعيل الكاش المحلي لـ Firestore (موبايل فقط — الويب يستخدم IndexedDB تلقائياً)
  if (!kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // ربط مفتاح التنقل بخدمة الإشعارات
  NotificationService.navigatorKey = GlobalKey<NavigatorState>();

  // تهيئة الإشعارات (غير مانعة)
  NotificationService.init();

  // بدء الاستماع لإشعارات Firestore إذا كان المستخدم مسجلاً
  if (FirebaseAuth.instance.currentUser != null) {
    NotificationService.startListening();
  }

  // الاستماع لتغيير حالة تسجيل الدخول لبدء/إيقاف المستمع
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      NotificationService.saveToken();
      NotificationService.startListening();
    } else {
      NotificationService.stopListening();
    }
  });

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('app_language') ?? _resolveDeviceLocale();

  runApp(MyApp(initialLocale: Locale(savedLang)));
}

// ─── MyApp ───────────────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  // ignore: library_private_types_in_public_api
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    LocaleService.register(setLocale);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', locale.languageCode);
    if (mounted) setState(() => _locale = locale);
  }

  Locale get locale => _locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      title: 'Ads App',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('ku'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('ar');
        for (final s in supportedLocales) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('ar');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        CountryLocalizations.delegate,
        KurdishLocalizationsDelegate('ku'),
        _KuMaterialDelegate(),
        _KuCupertinoDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        final isRtl = locale.languageCode == 'ar' ||
            locale.languageCode == 'ckb' ||
            locale.languageCode == 'ku';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5BDB)),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
      ),
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith('/ad/')) {
          final docId = name.substring(4).split('?').first.trim();
          if (docId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => AdDeepLinkScreen(docId: docId),
            );
          }
        }
        return null;
      },
    );
  }
}
