import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku')
  ];

  String get appTitle;
  String get appName;
  String get home;
  String get settings;
  String get favorites;
  String get myAds;
  String get addAd;
  String get addAdNow;
  String get search;
  String get allCategories;
  String get login;
  String get logout;
  String get loginWithGoogle;
  String get continueWithoutLogin;
  String get welcome;
  String get loginToAccess;
  String get profile;
  String get editProfile;
  String get fullName;
  String get email;
  String get phone;
  String get saveChanges;
  String get savedSuccess;
  String get publishAd;
  String get adTitle;
  String get category;
  String get chooseCategory;
  String get description;
  String get price;
  String get condition;
  String get conditionNew;
  String get conditionLikeNew;
  String get conditionUsed;
  String get conditionGift;
  String get location;
  String get city;
  String get zipCode;
  String get street;
  String get optional;
  String get autoDetect;
  String get publish;
  String get publishing;
  String get publishedSuccess;
  String get adDetails;
  String get contactWhatsApp;
  String get shareAd;
  String get addToFavorites;
  String get inFavorites;
  String get views;
  String get videoLink;
  String get videoLinkHint;
  String get watchVideo;
  String get language;
  String get notifications;
  String get privacy;
  String get help;
  String get about;
  String get loginRequired;
  String get loginRequiredMsg;
  String get cancel;
  String get delete;
  String get deleteAd;
  String get deleteAdConfirm;
  String get noAdsYet;
  String get startFirstAd;
  String get addNewAd;
  String get noFavorites;
  String get tapHeartToSave;
  String get noResults;
  String get results;
  String get ads;
  String get iSell;
  String get iLook;
  String get fixedPrice;
  String get negotiable;
  String get freeGift;
  String get priceType;
  String get photos;
  String get addPhoto;
  String get maxPhotos;
  String get uploadingPhotos;
  String get takePhoto;
  String get chooseFromGallery;
  String get shareOn;
  String get tapToAddLink;
  String get contactInfo;
  String get saveDraft;
  String get draftSaved;
  String get logoutConfirm;
  String get guestUser;
  String get tapToLogin;
  String get contactVia;
  String get publishedDate;
  String get chooseCountry;

  // NOTE: Additional getters used by the app (generated l10n files must override these).

  // ── البحث والفلتر ──
  String get allCities;
  String get chooseCity;
  String get searchCity;
  String get clearFilter;

  // ── الراديو ──
  String get allRadio;
  String get chooseRadio;

  // ── Auction keys ──
  String get auctionScreenTitle;

  String get auctionTabActive;
  String get auctionTabEndingSoon;
  String get auctionTabEnded;
  String get auctionCatAll;
  String get auctionCatElectronics;
  String get auctionCatCars;
  String get auctionCatClothing;
  String get auctionCatFurniture;
  String get auctionCatRealEstate;
  String get auctionCatOther;
  String get auctionNoAuctions;
  String get auctionAddBtn;
  String get auctionLoginFirst;
  String get auctionBid;
  String get auctionStatusActive;
  String get auctionStatusEndingSoon;
  String get auctionStatusSold;
  String get auctionStatusExpired;
  String get auctionDeleteTitle;
  String get auctionDeleteConfirm;
  String get auctionDeleteFailed;
  String get auctionCurrentPrice;
  String get auctionHighestBidLabel;
  String get auctionMinBidLabel;
  String get auctionBidHistory;
  String get auctionNoBids;
  String get auctionBidNow;
  String get auctionSoldFor;
  String get auctionEndedNoBids;
  String get auctionEnterBid;
  String get auctionInvalidAmount;
  String get auctionBidSuccess;
  String get auctionAddNew;
  String get auctionTitleField;
  String get auctionStartPrice;
  String get auctionMinIncrement;
  String get auctionEndDate;
  String get auctionPublishBtn;
  String get auctionPublishSuccess;
  String get auctionEnterTitle;
  String get auctionEnterValidPrice;
  String get auctionImagesSection;
  String get auctionInfoSection;
  String get auctionPriceDuration;
  String get auctionSectionHome;
  String get auctionAddYours;
  String get auctionBeFirst;
  String get auctionNoActive;
  String get auctionAddPhoto;
  String get phoneRequiredTitle;
  String get phoneRequiredBody;
  String get phoneRequiredOk;
  String get auctionViewAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale".');
}
