// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  // ── الأساسية ──
  @override
  String get favorites => 'Bijartî';

  @override
  String get noFavorites => 'Di bijartîyan de reklam tune';

  @override
  String get clickHeart => 'Tap the heart to save ads';

  @override
  String get currency => 'SYP';

  @override
  String get location => 'Cih';

  // ── تسجيل الدخول ──
  @override
  String get loginRequired => 'Têketin pêwîst e';

  @override
  String get loginRequiredMsg => 'Ji bo berdewamkirinê divê têkevi';

  @override
  String get cancel => 'Betal bike';

  @override
  String get login => 'Têkeve';

  // ── شريط التنقل ──
  @override
  String get home => 'Mal';

  @override
  String get myAds => 'Reklamên min';

  @override
  String get addAd => 'Reklam zêde bike';

  // ── البحث والفلتر ──
  @override
  String get search => 'Bigere...';

  @override
  String get noResults => 'Encam tune';

  @override
  String get allCities => 'Hemû Bajar';

  @override
  String get chooseCity => 'Bajêr hilbijêre';

  @override
  String get searchCity => 'Li bajêr bigere';

  @override
  String get clearFilter => 'Paqijkirina Fîlterê';

  // ── الراديو ──
  @override
  String get allRadio => 'Hemû Stasyon';

  @override
  String get chooseRadio => 'Stasyon hilbijêre';

  // ── المزادات ──
  @override
  String get auctionViewAll => 'Hemû bibîne';

  @override
  String get auctionSectionHome => '🔨 Mezadên çalak';

  @override
  String get auctionAddYours => 'Mezada xwe zêde bike';

  @override
  String get auctionNoActive => 'Mezadên çalak tune';

  @override
  String get auctionBeFirst => 'Yekem bibe ku mezadek zêde bike';
}
