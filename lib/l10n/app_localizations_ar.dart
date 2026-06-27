// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  // ── الأساسية ──
  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavorites => 'لا توجد إعلانات في المفضلة';

  @override
  String get clickHeart => 'اضغط القلب لحفظ الإعلانات';

  @override
  String get currency => 'SYP';

  @override
  String get location => 'الموقع';

  // ── تسجيل الدخول ──
  @override
  String get loginRequired => 'تسجيل الدخول مطلوب';

  @override
  String get loginRequiredMsg => 'يجب تسجيل الدخول للمتابعة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get login => 'تسجيل الدخول';

  // ── شريط التنقل ──
  @override
  String get home => 'الرئيسية';

  @override
  String get myAds => 'إعلاناتي';

  @override
  String get addAd => 'أضف إعلان';

  // ── البحث والفلتر ──
  @override
  String get search => 'ابحث هنا...';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get allCities => 'كل المدن';

  @override
  String get chooseCity => 'اختر مدينة';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get clearFilter => 'إلغاء الفلتر';

  // ── الراديو ──
  @override
  String get allRadio => 'كل القنوات';

  @override
  String get chooseRadio => 'اختر قناة راديو';

  // ── المزادات ──
  @override
  String get auctionViewAll => 'عرض الكل';

  @override
  String get auctionSectionHome => '🔨 المزادات النشطة';

  @override
  String get auctionAddYours => 'أضف مزادك';

  @override
  String get auctionNoActive => 'لا توجد مزادات نشطة';

  @override
  String get auctionBeFirst => 'كن أول من يضيف مزاداً';
}
