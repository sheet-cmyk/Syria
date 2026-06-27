import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import '../services/radio_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../gen_l10n/app_localizations.dart';
import '../gen_l10n/app_localizations_ar.dart';
import '../utils/category_helper.dart';
import '../widgets/cached_ad_image.dart';
import 'sub_category_screen.dart';
import 'add_ad_screen.dart';
import 'my_ads_screen.dart';
import 'friends_screen.dart';
import 'my_profile_screen.dart';
import 'ad_detail_screen.dart';
import 'auth_screen.dart';
import '../services/auction_service.dart';
import '../models/auction_model.dart';
import '../widgets/auction_card.dart';
import 'auctions_screen.dart';
import 'auction_detail_screen.dart';
import 'add_auction_screen.dart';

// ── بيانات قنوات الراديو ──

class _RadioStation {
  final String nameAr;
  final String nameEn;
  final String nameDe;
  final String nameFr;
  final String url;
  final String countryKey;

  const _RadioStation({
    required this.nameAr,
    required this.nameEn,
    required this.nameDe,
    required this.nameFr,
    required this.url,
    required this.countryKey,
  });

  String nameFor(String lang) {
    switch (lang) {
      case 'en':
        return nameEn;
      case 'de':
        return nameDe;
      case 'fr':
        return nameFr;
      default:
        return nameAr;
    }
  }
}

const _radioCountries = <String, Map<String, String>>{
  'quran': {
    'ar': '📖 راديو قران',
    'en': '📖 Quran Radio',
    'de': '📖 Koran Radio',
    'fr': '📖 Radio Coran',
    'sv': '📖 Koranen Radio',
    'uk': '📖 Радіо Коран',
    'tr': '📖 Kuran Radyosu',
    'ku': '📖 Radyoya Quranê',
    'ckb': '📖 ڕادیۆی قورئان'
  },
};

const _kCountryOrder = ['quran'];

const _radioStations = <_RadioStation>[
  _RadioStation(
      nameAr: 'إذاعة القرآن الكريم - بث عام',
      nameEn: 'Holy Quran Radio - General',
      nameDe: 'Koran Radio - Allgemein',
      nameFr: 'Radio Coran - Général',
      url: 'https://Qurango.net/radio/tarteel',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ عبدالباسط عبدالصمد',
      nameEn: 'Abdulbasit Abdulsamad',
      nameDe: 'Abdulbasit Abdulsamad',
      nameFr: 'Abdulbasit Abdulsamad',
      url: 'https://Qurango.net/radio/abdulbasit_abdulsamad_mojawwad',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ مشاري العفاسي',
      nameEn: 'Mishary Alafasi',
      nameDe: 'Mishary Alafasi',
      nameFr: 'Mishary Alafasi',
      url: 'https://Qurango.net/radio/mishary_alafasi',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ ماهر المعيقلي',
      nameEn: 'Maher Al Muaiqly',
      nameDe: 'Maher Al Muaiqly',
      nameFr: 'Maher Al Muaiqly',
      url: 'https://Qurango.net/radio/maher_al_muaiqly',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ ياسر الدوسري',
      nameEn: 'Yasser Al Dosari',
      nameDe: 'Yasser Al Dosari',
      nameFr: 'Yasser Al Dosari',
      url: 'https://Qurango.net/radio/yasser_al_dosari',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ أحمد العجمي',
      nameEn: 'Ahmad Al Ajmy',
      nameDe: 'Ahmad Al Ajmy',
      nameFr: 'Ahmad Al Ajmy',
      url: 'https://Qurango.net/radio/ahmad_al_ajmy',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ سعد الغامدي',
      nameEn: 'Saad Al Ghamdi',
      nameDe: 'Saad Al Ghamdi',
      nameFr: 'Saad Al Ghamdi',
      url: 'https://Qurango.net/radio/saad_alghamidi',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ سعود الشريم',
      nameEn: 'Saud Al Shuraim',
      nameDe: 'Saud Al Shuraim',
      nameFr: 'Saud Al Shuraim',
      url: 'https://Qurango.net/radio/shuraym',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ فارس عباد',
      nameEn: 'Fares Abbad',
      nameDe: 'Fares Abbad',
      nameFr: 'Fares Abbad',
      url: 'https://Qurango.net/radio/fares_abbad',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ أبو بكر الشاطري',
      nameEn: 'Abu Bakr Al Shatri',
      nameDe: 'Abu Bakr Al Shatri',
      nameFr: 'Abu Bakr Al Shatri',
      url: 'https://Qurango.net/radio/abu_bakr_al_shatri',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'القارئ محمود خليل الحصري',
      nameEn: 'Mahmoud Khalil Al Hussary',
      nameDe: 'Mahmoud Khalil Al Hussary',
      nameFr: 'Mahmoud Khalil Al Hussary',
      url: 'https://Qurango.net/radio/mahmoud_khalil_alhussary',
      countryKey: 'quran'),
  _RadioStation(
      nameAr: 'إذاعة الفتاوى',
      nameEn: 'Fatwa Radio',
      nameDe: 'Fatwa Radio',
      nameFr: 'Radio Fatwa',
      url: 'https://qurango.net/radio/fatwa',
      countryKey: 'quran'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 4;
  late AppLocalizations _l;
  String _userCity = '';
  final _searchCtrl = TextEditingController();
  String? _selectedCity;
  String? _selectedRadioName;
  String? _selectedRadioUrl;
  bool _radioError = false;
  Map<String, List<Map<String, String>>> _liveStations = {};

  Timer? _searchDebounce;

  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;
  List<Map<String, dynamic>> _bannerAds = [];
  List<QueryDocumentSnapshot> _allDocs = [];
  bool _adsLoading = true;

  StreamSubscription? _adsSubscription;
  StreamSubscription? _bannerSubscription;
  StreamSubscription? _unreadSubscription;
  StreamSubscription? _auctionSubscription;
  int _totalUnread = 0;
  List<AuctionModel> _activeAuctions = [];
  bool _auctionsLoading = true;

  List<QueryDocumentSnapshot>? _filteredCache;
  String _lastQuery = '';
  String _lastCity = '';

  // ── [Responsive] تحديد نوع الشاشة ──
  bool _isDesktop = false;
  static const _desktopBreakpoint = 800.0;
  // خريطة تربط ترتيب NavRail بمؤشر التبويب الأصلي
  static const _desktopNavMap = [4, 3, 1, 0]; // home, myAds, friends, profile

  @override
  void initState() {
    super.initState();
    _loadUserCity();
    _loadBannerAds();
    _listenToAds();
    _listenUnread();
    _listenAuctions();
    _prefetchRadioStations();
  }

  Future<void> _prefetchRadioStations() async {
    // جلب محطات إخبارية من كل دولة بواسطة رمز البلد + وسم news
    const base = 'https://de1.api.radio-browser.info/json/stations/search';
    // رموز الدول — السعودية تستخدم وسم quran بدلاً من news
    // Syria has few stations in RadioBrowser, so no tag filter for it
    const tagByCountry = <String, String>{
      'de': 'news',
      'sy': '',
      'lb': 'news',
      'iq': 'news',
      'tr': 'news',
      'sa': 'quran',
      'dz': 'news',
      'ma': 'news',
      'tn': 'news',
      'ua': 'news',
    };
    const codeByKey = <String, String>{
      'de': 'DE',
      'sy': 'SY',
      'lb': 'LB',
      'iq': 'IQ',
      'tr': 'TR',
      'sa': 'SA',
      'dz': 'DZ',
      'ma': 'MA',
      'tn': 'TN',
      'ua': 'UA',
    };
    final builtQueries = <String, List<String>>{
      for (final key in codeByKey.keys)
        key: [
          (tagByCountry[key] ?? '').isEmpty
              ? '$base?countrycode=${codeByKey[key]}&limit=8&order=votes&reverse=true&hidebroken=true'
              : '$base?countrycode=${codeByKey[key]}&tagList=${tagByCountry[key]}&limit=8&order=votes&reverse=true&hidebroken=true'
        ],
    };
    try {
      final futures = builtQueries.entries.map((e) async {
        final seen = <String>{};
        final merged = <Map<String, String>>[];
        for (final url in e.value) {
          try {
            final resp = await http.get(Uri.parse(url), headers: const {
              'User-Agent': 'ArabAdsApp/1.0'
            }).timeout(const Duration(seconds: 12));
            if (resp.statusCode == 200) {
              final data = jsonDecode(resp.body) as List<dynamic>;
              for (final s in data) {
                final name = ((s['name'] as String?) ?? '').trim();
                final stUrl = (s['url_resolved'] as String?) ??
                    (s['url'] as String?) ??
                    '';
                final lo = stUrl.toLowerCase();
                final nameLo = name.toLowerCase();
                final blocked = nameLo.contains('sham') ||
                    nameLo == 'news' ||
                    nameLo.startsWith('news ') ||
                    nameLo.endsWith(' news') ||
                    nameLo == 'news radio' ||
                    nameLo == 'news fm';
                final ok = name.isNotEmpty &&
                    stUrl.isNotEmpty &&
                    !blocked &&
                    !lo.contains('.m3u8') &&
                    !lo.contains('.pls') &&
                    seen.add(stUrl);
                if (ok) merged.add({'name': name, 'url': stUrl});
              }
            }
          } catch (_) {}
        }
        return MapEntry(e.key, merged);
      });
      final results = await Future.wait(futures);
      if (mounted) setState(() => _liveStations = Map.fromEntries(results));
    } catch (_) {}
  }

  Future<void> _playUrl(String url, String name) async {
    setState(() {
      _selectedRadioName = name;
      _selectedRadioUrl = url;
      _radioError = false;
    });
    try {
      await playRadioStation(url);
    } catch (_) {
      if (!mounted) return;
      // ابقِ الاسم والـ URL — لا تُخفِ المشغّل، فقط أظهر حالة الخطأ
      setState(() => _radioError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ $name — جرّب محطة أخرى'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _stopRadio() {
    radioPlayer.stop();
    setState(() {
      _selectedRadioName = null;
      _selectedRadioUrl = null;
      _radioError = false;
    });
  }

  void _pauseRadio() => radioPlayer.pause();

  void _resumeRadio() => radioPlayer.play();

  void _listenToAds() {
    _adsSubscription = FirebaseFirestore.instance
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snap) {
      if (mounted) {
        setState(() {
          _allDocs = snap.docs;
          _adsLoading = false;
          _filteredCache = null;
        });
      }
    });
  }

  void _listenUnread() {
    final myId = AuthService.currentUser?.uid;
    if (myId == null) return;
    _unreadSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: myId)
        .snapshots()
        .listen((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final counts = data['unreadCounts'] as Map<String, dynamic>? ?? {};
        total += (counts[myId] as num?)?.toInt() ?? 0;
      }
      if (mounted) setState(() => _totalUnread = total);
    });
  }

  void _listenAuctions() {
    _auctionSubscription =
        AuctionService.streamActiveAuctions(limit: 8).listen((list) {
      if (mounted)
        setState(() {
          _activeAuctions = list;
          _auctionsLoading = false;
        });
    });
  }

  Future<void> _loadBannerAds() async {
    _bannerSubscription = FirebaseFirestore.instance
        .collection('banner_ads')
        .snapshots()
        .listen((snap) {
      if (mounted) {
        final docs = snap.docs.where((d) {
          final data = d.data();
          return data['نشيط'] == true || data['active'] == true;
        }).toList()
          ..sort((a, b) {
            final aO = (a.data()['طلب'] ?? a.data()['order'] ?? 0) as num;
            final bO = (b.data()['طلب'] ?? b.data()['order'] ?? 0) as num;
            return aO.compareTo(bO);
          });
        setState(() => _bannerAds = docs.map((d) => d.data()).toList());
        _startBannerTimer();
      }
    });
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    if (_bannerAds.length > 1) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted || !_bannerController.hasClients) return;
        final next = (_bannerIndex + 1) % _bannerAds.length;
        _bannerController.animateToPage(next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      });
    }
  }

  Future<void> _openBannerLink(String link) async {
    if (link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _loadUserCity() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _userCity = prefs.getString('draft_city') ?? '');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    _searchDebounce?.cancel();
    _adsSubscription?.cancel();
    _bannerSubscription?.cancel();
    _unreadSubscription?.cancel();
    _auctionSubscription?.cancel();
    super.dispose();
  }

  static const _langs = ['ar', 'en', 'de', 'fr', 'sv', 'uk', 'tr', 'ku', 'ckb'];

  // يبني مجموعة من جميع ترجمات الأقسام التي تطابق الاستعلام
  Set<String> _catEquivalents(String qLow) {
    final result = <String>{};
    for (final key in CatKey.values) {
      bool hit = false;
      for (final lang in _langs) {
        final n = getCatName(key, lang).toLowerCase();
        if (n.isNotEmpty && (n.contains(qLow) || qLow.contains(n))) {
          hit = true;
          break;
        }
      }
      if (hit) {
        for (final lang in _langs) {
          final n = getCatName(key, lang).toLowerCase();
          if (n.isNotEmpty) result.add(n);
        }
      }
    }
    return result;
  }

  // يبني مجموعة من جميع ترجمات الأقسام الفرعية التي تطابق الاستعلام
  Set<String> _subEquivalents(String qLow) {
    final result = <String>{};
    for (final key in SubKey.values) {
      bool hit = false;
      for (final lang in _langs) {
        final n = getSubName(key, lang).toLowerCase();
        if (n.isNotEmpty && (n.contains(qLow) || qLow.contains(n))) {
          hit = true;
          break;
        }
      }
      if (hit) {
        for (final lang in _langs) {
          final n = getSubName(key, lang).toLowerCase();
          if (n.isNotEmpty) result.add(n);
        }
      }
    }
    return result;
  }

  List<QueryDocumentSnapshot> get _filteredDocs {
    final q = _searchCtrl.text.trim();
    final qLow = q.toLowerCase();
    if (_filteredCache != null && q == _lastQuery && _userCity == _lastCity) {
      return _filteredCache!;
    }
    _lastQuery = q;
    _lastCity = _userCity;

    List<QueryDocumentSnapshot> result;

    final sourceDocs = _selectedCity != null
        ? _allDocs.where((doc) {
            final city =
                ((doc.data() as Map)['city'] ?? '').toString().toLowerCase();
            return city.contains(_selectedCity!.toLowerCase()) ||
                _selectedCity!.toLowerCase().contains(city);
          }).toList()
        : _allDocs;

    if (q.isEmpty) {
      if (_userCity.isNotEmpty && _selectedCity == null) {
        final sorted = List<QueryDocumentSnapshot>.from(sourceDocs);
        sorted.sort((a, b) {
          final aCity =
              ((a.data() as Map)['city'] ?? '').toString().toLowerCase();
          final bCity =
              ((b.data() as Map)['city'] ?? '').toString().toLowerCase();
          final uCity = _userCity.toLowerCase();
          final aM = aCity.contains(uCity) || uCity.contains(aCity);
          final bM = bCity.contains(uCity) || uCity.contains(bCity);
          if (aM && !bM) return -1;
          if (!aM && bM) return 1;
          return 0;
        });
        result = sorted;
      } else {
        result = sourceDocs;
      }
    } else {
      // كلمات البحث (دعم متعدد الكلمات)
      final words =
          qLow.split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();

      // مجموعة الترجمات المكافئة للأقسام وللأقسام الفرعية
      final catEq = _catEquivalents(qLow);
      final subEq = _subEquivalents(qLow);

      final scored = <MapEntry<QueryDocumentSnapshot, int>>[];
      for (final doc in sourceDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '').toString().toLowerCase();
        final desc = (data['description'] ?? '').toString().toLowerCase();
        final cat = (data['category'] ?? '').toString().toLowerCase();
        final subCat = (data['subCategory'] ?? '').toString().toLowerCase();
        final city = (data['city'] ?? '').toString().toLowerCase();

        int score = 0;

        // مطابقة القسم بأي لغة (أعلى أولوية)
        if (catEq.any((eq) => cat.contains(eq) || eq.contains(cat)))
          score += 20;
        if (subEq.any((eq) => subCat.contains(eq) || eq.contains(subCat)))
          score += 15;

        // مطابقة الكلمات الفردية
        int wordHits = 0;
        for (final word in words) {
          bool hit = false;
          if (title.contains(word)) {
            score += 10;
            hit = true;
          }
          if (cat.contains(word)) {
            score += 6;
            hit = true;
          }
          if (subCat.contains(word)) {
            score += 5;
            hit = true;
          }
          if (city.contains(word)) {
            score += 4;
            hit = true;
          }
          if (desc.contains(word)) {
            score += 2;
            hit = true;
          }
          if (hit) wordHits++;
        }

        // مكافأة عند تطابق كل الكلمات
        if (words.length > 1 && wordHits == words.length) score += 8;

        if (score > 0) scored.add(MapEntry(doc, score));
      }
      scored.sort((a, b) => b.value.compareTo(a.value));
      result = scored.map((e) => e.key).toList();
    }

    _filteredCache = result;
    return result;
  }

  void _onNavTap(int index) async {
    if (index == 2) {
      if (!AuthService.isLoggedIn) {
        await _showAuthRequired();
        return;
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AddAdScreen()));
      return;
    }
    setState(() => _selectedTabIndex = index);
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MyProfileScreen()));
        break;
      case 1:
        if (!AuthService.isLoggedIn) {
          await _showAuthRequired();
          return;
        }
        final user = AuthService.currentUser;
        if (user != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FriendsScreen(userId: user.uid)));
        }
        break;
      case 3:
        if (!AuthService.isLoggedIn) {
          await _showAuthRequired();
          return;
        }
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MyAdsScreen()));
        break;
    }
  }

  Future<void> _showAuthRequired() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_l.loginRequired, textAlign: TextAlign.right),
        content: Text(_l.loginRequiredMsg, textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(_l.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()));
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black),
            child: Text(_l.login),
          ),
        ],
      ),
    );
  }

  Future<bool> _onPopInvoked() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('هل تريد الخروج؟',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('هل أنت متأكد من الخروج من التطبيق؟',
            textAlign: TextAlign.right, style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا، تراجع',
                  style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('نعم، خروج',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    _l = AppLocalizations.of(context) ?? AppLocalizationsAr('ar');
    return LayoutBuilder(
      builder: (context, constraints) {
        _isDesktop = constraints.maxWidth >= _desktopBreakpoint;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final should = await _onPopInvoked();
            if (should) SystemNavigator.pop();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _isDesktop
                        ? _buildDesktopBody()
                        : _buildScrollContent(),
                  ),
                  // المشغّل ثابت أسفل المحتوى دائماً
                  _buildMiniPlayer(),
                ],
              ),
            ),
            bottomNavigationBar: _isDesktop ? null : _buildBottomNavBar(),
          ),
        );
      },
    );
  }

  Widget _buildScrollContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildBannerAds()),
        SliverToBoxAdapter(child: _buildCategoriesSection()),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildCityFilterBar()),
        SliverToBoxAdapter(
            child: _searchCtrl.text.isNotEmpty
                ? _buildSearchResults()
                : _buildAdsGrid()),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      children: [
        _buildDesktopNavRail(),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _buildScrollContent()),
      ],
    );
  }

  Widget _buildDesktopNavRail() {
    final navIndex = _desktopNavMap.indexOf(_selectedTabIndex);
    final railIndex = navIndex < 0 ? 0 : navIndex;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              selectedIndex: railIndex,
              onDestinationSelected: (i) => _onNavTap(_desktopNavMap[i]),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Color(0xFF3B5BDB)),
              selectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF3B5BDB),
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
              unselectedIconTheme:
                  const IconThemeData(color: Color(0xFF9CA3AF)),
              unselectedLabelTextStyle:
                  const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(_l.home),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon: const Icon(Icons.grid_view),
                  label: Text(_l.myAds),
                ),
                NavigationRailDestination(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.people_outline),
                      if (_totalUnread > 0)
                        Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 16, minHeight: 16),
                            child: Text(
                              _totalUnread > 99 ? '99+' : '$_totalUnread',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  selectedIcon: const Icon(Icons.people),
                  label: Text(_friendsLabel),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(_profileLabel),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: IconButton(
              onPressed: () async {
                if (!AuthService.isLoggedIn) {
                  await _showAuthRequired();
                  return;
                }
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddAdScreen()));
              },
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFFFFD600), size: 28),
              tooltip: _l.addAd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAds() {
    if (_bannerAds.isEmpty) return const SizedBox();
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: _isDesktop ? 960 : double.infinity),
        child: Container(
          height: _isDesktop ? 221.0 : 153.0,
          margin: const EdgeInsets.only(top: 8),
          child: Stack(children: [
            PageView.builder(
              controller: _bannerController,
              itemCount: _bannerAds.length,
              onPageChanged: (i) => setState(() => _bannerIndex = i),
              itemBuilder: (_, i) {
                final ad = _bannerAds[i];
                final imageUrl = ad['رابط الصورة'] ?? ad['imageUrl'] ?? '';
                final title = ad['title'] ?? ad['عنوان'] ?? '';
                final subtitle = ad['subtitle'] ?? ad['وصف'] ?? '';
                final link = ad['وصلة'] ??
                    ad['link'] ??
                    ad['linkUrl'] ??
                    ad['linkurl'] ??
                    '';
                return GestureDetector(
                  onTap: () => _openBannerLink(link),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1E3A5F)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(fit: StackFit.expand, children: [
                        if (imageUrl.isNotEmpty)
                          CachedAdImage(
                            url: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: _bannerGradient(),
                            placeholder: _bannerGradient(),
                          )
                        else
                          _bannerGradient(),
                        Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                              Colors.black.withOpacity(0.55),
                              Colors.transparent
                            ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter))),
                        if (title.isNotEmpty || subtitle.isNotEmpty)
                          Positioned(
                              bottom: 16,
                              right: 16,
                              left: 16,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (title.isNotEmpty)
                                      Text(title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.right),
                                    if (subtitle.isNotEmpty)
                                      Text(subtitle,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13),
                                          textAlign: TextAlign.right),
                                  ])),
                      ]),
                    ),
                  ),
                );
              },
            ),
            if (_bannerAds.length > 1)
              Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          _bannerAds.length,
                          (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: _bannerIndex == i ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    color: _bannerIndex == i
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(4)),
                              )))),
            // أيقونة تحميل تطبيق الأندرويد
            if (kIsWeb)
              Positioned(
                top: 10,
                right: 22,
                child: GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.hussein.syriaadsapp');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4)
                      ],
                    ),
                    child: const Icon(Icons.android,
                        color: Colors.green, size: 24),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _bannerGradient() => Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2D5A8E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)));

  Widget _buildCategoriesSection() {
    final lang = Localizations.localeOf(context).languageCode;
    final allCats = CategoryHelper.forLang(lang);
    if (allCats.length < 7) return const SizedBox();
    final displayCategories = [
      allCats[0],
      allCats[1],
      allCats[6],
      allCats[3],
      allCats[4],
      allCats[5]
    ];
    final servicesCat = allCats[2];
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _isDesktop ? 6 : 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0),
          itemCount: displayCategories.length,
          itemBuilder: (context, index) {
            final cat = displayCategories[index];

            // ── تغيير أيقونة واسم قسم الملابس (index 4 = ملابس في displayCategories) ──
            final isClothes = index == 4;
            final displayIcon = isClothes ? Icons.style : cat.icon;
            final displayColor =
                isClothes ? const Color(0xFFE91E8C) : cat.color;
            final displayName = cat.name;

            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SubCategoryScreen(category: cat))),
              child: Container(
                decoration: BoxDecoration(
                    color: isClothes
                        ? const Color(0xFFE91E8C).withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: isClothes
                            ? const Color(0xFFE91E8C).withOpacity(0.3)
                            : const Color(0xFFE5E7EB))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(displayIcon, color: displayColor, size: 32),
                      const SizedBox(height: 6),
                      Text(displayName,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isClothes
                                  ? const Color(0xFFE91E8C)
                                  : const Color(0xFF1F2937)),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ]),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            if (!AuthService.isLoggedIn) {
              await _showAuthRequired();
              return;
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddAdScreen()));
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFD600), Color(0xFFFFB300)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_circle_outline,
                  color: Colors.black87, size: 28),
              const SizedBox(width: 10),
              Text(_l.addAd,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ]),
          ),
        ),
        // ── قسم خدمات وبحث عن عمل ──
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SubCategoryScreen(category: servicesCat))),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة مركبة: خدمات + عمل
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.work_outline,
                        color: Color(0xFF8B5CF6), size: 30),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              width: 0.5),
                        ),
                        child: const Icon(Icons.build_outlined,
                            color: Color(0xFF8B5CF6), size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  servicesCat.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildAuctionSection(),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        TextField(
          controller: _searchCtrl,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          onChanged: (val) {
            _searchDebounce?.cancel();
            _searchDebounce = Timer(const Duration(milliseconds: 300), () {
              if (mounted) {
                _filteredCache = null;
                setState(() {});
              }
            });
          },
          decoration: InputDecoration(
            hintText: _l.search,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            prefixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchCtrl.clear();
                      _filteredCache = null;
                      setState(() {});
                    })
                : null,
            suffixIcon: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.search, color: Colors.white, size: 18)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        if (_searchCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${_filteredDocs.length} نتيجة',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ]),
    );
  }

  Widget _buildSearchResults() {
    final docs = _filteredDocs;
    if (_adsLoading) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD600))));
    }
    if (docs.isEmpty) {
      return Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.search_off, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            const Text('لا توجد نتائج',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center),
          ])));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final images = (data['images'] as List?)?.cast<String>() ?? [];
        final category = data['category'] ?? '';
        final found = CategoryHelper.find(category);
        return GestureDetector(
          onTap: () {
            final ad = AdModel(
                id: index,
                title: data['title'] ?? '',
                category: data['category'] ?? '',
                subCategory: data['subCategory'] ?? '',
                price: data['price'] ?? '',
                city: data['city'] ?? '',
                phone: data['phone'] ?? '',
                description: data['description'] ?? '',
                condition: data['condition'] ?? '',
                date: '');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AdDetailScreen(
                        ad: ad, firestoreData: data, docId: doc.id)));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 6)
                ]),
            child: Row(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(14)),
                child: CachedAdImage(
                  url: images.isNotEmpty ? images.first : null,
                  category: found,
                  height: 100,
                  width: 100,
                ),
              ),
              Expanded(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(data['title'] ?? '',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right),
                      const SizedBox(height: 4),
                      Text(
                          (data['currency'] ?? 'SYP') == 'USD'
                              ? '\$${data["price"] ?? ""}'
                              : '${data["price"] ?? ""} ل.س',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFFD600))),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text(data['city'] ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280))),
                        const SizedBox(width: 3),
                        const Text('📍', style: TextStyle(fontSize: 11)),
                      ]),
                    ]),
              )),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildAdsGrid() {
    if (_adsLoading) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD600))));
    }
    final docs = _filteredDocs;
    if (docs.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
              child: Text('لا توجد إعلانات',
                  style: TextStyle(color: Colors.grey))));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _isDesktop ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 230),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data() as Map<String, dynamic>;
          final images = (data['images'] as List?)?.cast<String>() ?? [];
          final category = data['category'] ?? '';
          final isNearby = _userCity.isNotEmpty &&
              ((data['city'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(_userCity.toLowerCase()) ||
                  _userCity
                      .toLowerCase()
                      .contains((data['city'] ?? '').toString().toLowerCase()));
          final found = CategoryHelper.find(category);
          return GestureDetector(
            onTap: () {
              final ad = AdModel(
                  id: index,
                  title: data['title'] ?? '',
                  category: data['category'] ?? '',
                  subCategory: data['subCategory'] ?? '',
                  price: data['price'] ?? '',
                  city: data['city'] ?? '',
                  phone: data['phone'] ?? '',
                  description: data['description'] ?? '',
                  condition: data['condition'] ?? '',
                  date: '');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AdDetailScreen(
                          ad: ad, firestoreData: data, docId: doc.id)));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: isNearby
                      ? Border.all(color: const Color(0xFFFFD600), width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 6)
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: CachedAdImage(
                          url: images.isNotEmpty ? images.first : null,
                          category: found,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(data['title'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right),
                              const SizedBox(height: 4),
                              Text(
                                  (data['currency'] ?? 'SYP') == 'USD'
                                      ? '\$${data["price"] ?? ""}'
                                      : '${data["price"] ?? ""} ل.س',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFFD600))),
                              const SizedBox(height: 3),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                        child: Text(
                                            (data['city'] ?? '')
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF6B7280)),
                                            overflow: TextOverflow.ellipsis)),
                                    const SizedBox(width: 3),
                                    const Text('📍',
                                        style: TextStyle(fontSize: 10)),
                                  ]),
                            ])),
                  ]),
            ),
          );
        },
      ),
    );
  }

  // ── قائمة مواقع سوريا (محافظات، مدن، أقضية ونواحي)
  static const List<String> _iraqLocations = [
    'دمشق',
    'ريف دمشق',
    'المزة',
    'المالكي',
    'أبو رمانة',
    'القصاع',
    'باب توما',
    'الميدان',
    'كفرسوسة',
    'دمر',
    'قدسيا',
    'جرمانا',
    'السيدة زينب',
    'صحنايا',
    'داريا',
    'دوما',
    'حرستا',
    'عربين',
    'القابون',
    'برزة',
    'حلب',
    'حلب القديمة',
    'الشهباء',
    'العزيزية',
    'الجميلية',
    'السبيل',
    'الراموسة',
    'الزهراء',
    'حمص',
    'الخالدية',
    'الوعر',
    'بابا عمرو',
    'تلبيسة',
    'الرستن',
    'تدمر',
    'حماه',
    'سلمية',
    'مصياف',
    'اللاذقية',
    'جبلة',
    'طرطوس',
    'بانياس',
    'صافيتا',
    'إدلب',
    'دير الزور',
    'البوكمال',
    'الميادين',
    'الحسكة',
    'القامشلي',
    'عامودا',
    'الرقة',
    'منبج',
    'درعا',
    'السويداء',
    'القنيطرة',
    'عفرين',
    'اعزاز',
    'الباب',
    'صيدنايا',
    'معلولا',
    'قطنا',
    'الكسوة',
  ];

  List<Map<String, String>> _allStationsFlat(String lang) {
    final result = <Map<String, String>>[];
    for (final ck in _kCountryOrder) {
      final live = _liveStations[ck] ?? [];
      final stations = (live.isNotEmpty
              ? live
              : _radioStations
                  .where((s) => s.countryKey == ck)
                  .map((s) => {'name': s.nameFor(lang), 'url': s.url})
                  .toList())
          .take(30)
          .toList();
      result.addAll(stations);
    }
    return result;
  }

  void _cycleToNextStation() {
    final lang = Localizations.localeOf(context).languageCode;
    final all = _allStationsFlat(lang);
    if (all.isEmpty) return;
    final idx = all.indexWhere((s) => s['url'] == _selectedRadioUrl);
    final next = all[(idx + 1) % all.length];
    _playUrl(next['url']!, next['name']!);
  }

  Widget _buildMiniPlayer() {
    if (_selectedRadioName == null) return const SizedBox.shrink();

    final stationName = _selectedRadioName!;

    // إذا فشل التشغيل — أبقِ المشغّل ظاهراً مع رسالة خطأ
    if (_radioError) {
      return _miniPlayerShell(
          stationName: stationName,
          isLoading: false,
          isPlaying: false,
          isError: true);
    }

    return StreamBuilder<PlayerState>(
      stream: radioPlayer.playerStateStream,
      builder: (context, snap) {
        final state = snap.data;
        final ps = state?.processingState;
        final isPlaying = state?.playing ?? false;
        final isLoading =
            ps == ProcessingState.loading || ps == ProcessingState.buffering;

        return _miniPlayerShell(
            stationName: stationName,
            isLoading: isLoading,
            isPlaying: isPlaying);
      },
    );
  }

  Widget _miniPlayerShell(
      {required String stationName,
      required bool isLoading,
      required bool isPlaying,
      bool isError = false}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF4C6EF5)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF3B5BDB).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          // زر تقليب المحطات — يسار
          GestureDetector(
            onTap: _cycleToNextStation,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.skip_next, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          // معلومات المحطة — وسط
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stationName,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  isError
                      ? '❌ تعذر تشغيل القناة'
                      : isLoading
                          ? '⏳ جاري التحميل...'
                          : isPlaying
                              ? '🔴 يبث الآن'
                              : '⏸ متوقف مؤقتاً',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // زر تشغيل / إيقاف مؤقت — يمين
          GestureDetector(
            onTap: isLoading ? null : (isPlaying ? _pauseRadio : _resumeRadio),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          // زر إيقاف كلي — يمين
          GestureDetector(
            onTap: _stopRadio,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.stop, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilterBar() {
    final hasCity = _selectedCity != null;
    final hasRadio = _selectedRadioName != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ── فلتر الراديو ──
          GestureDetector(
            onTap: _showRadioSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: hasRadio ? const Color(0xFF3B5BDB) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasRadio
                      ? const Color(0xFF3B5BDB)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasRadio)
                    GestureDetector(
                      onTap: _stopRadio,
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  if (hasRadio) const SizedBox(width: 4),
                  Icon(Icons.radio,
                      size: 16,
                      color: hasRadio ? Colors.white : const Color(0xFF6B7280)),
                  const SizedBox(width: 5),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      hasRadio ? _selectedRadioName! : _l.allRadio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            hasRadio ? FontWeight.bold : FontWeight.normal,
                        color:
                            hasRadio ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16,
                      color: hasRadio ? Colors.white : const Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ── فلتر المدينة ──
          GestureDetector(
            onTap: _showCityFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: hasCity ? const Color(0xFFFFD600) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasCity
                      ? const Color(0xFFFFD600)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCity)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCity = null;
                          _filteredCache = null;
                        });
                      },
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.black87),
                    ),
                  if (hasCity) const SizedBox(width: 4),
                  Icon(Icons.location_on,
                      size: 16,
                      color:
                          hasCity ? Colors.black87 : const Color(0xFF6B7280)),
                  const SizedBox(width: 5),
                  Text(
                    hasCity ? _selectedCity! : _l.allCities,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasCity ? FontWeight.bold : FontWeight.normal,
                      color: hasCity ? Colors.black87 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16,
                      color:
                          hasCity ? Colors.black87 : const Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityFilterSheet() {
    final searchCtrl = TextEditingController();
    List<String> filtered = List.from(_iraqLocations);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (_, scrollCtrl) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // العنوان + زر إلغاء
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_selectedCity != null)
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _selectedCity = null;
                                  _filteredCache = null;
                                });
                              },
                              child: Text(_l.clearFilter,
                                  style: const TextStyle(color: Colors.red)),
                            )
                          else
                            const SizedBox(),
                          Text(_l.chooseCity,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // حقل البحث
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: TextField(
                        controller: searchCtrl,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        onChanged: (val) {
                          setSheetState(() {
                            filtered = _iraqLocations
                                .where((c) =>
                                    c.toLowerCase().contains(val.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: _l.searchCity,
                          hintTextDirection: TextDirection.rtl,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    // قائمة المدن
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(_l.noResults,
                                  style: const TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              controller: scrollCtrl,
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final city = filtered[i];
                                final isSelected = city == _selectedCity;
                                return ListTile(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    setState(() {
                                      _selectedCity = city;
                                      _filteredCache = null;
                                    });
                                  },
                                  trailing: Icon(
                                    Icons.location_city,
                                    color: isSelected
                                        ? const Color(0xFFFFD600)
                                        : Colors.grey.shade400,
                                  ),
                                  title: Text(
                                    city,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFFFFD600)
                                          : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  leading: isSelected
                                      ? const Icon(Icons.check,
                                          color: Color(0xFFFFD600))
                                      : null,
                                );
                              },
                            ),
                    ),
                  ]),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRadioSheet() {
    final lang = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String? selectedCountry;

        return StatefulBuilder(
          builder: (_, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (_, scrollCtrl) {
                final countryName = selectedCountry != null
                    ? (_radioCountries[selectedCountry]?[lang] ??
                        _radioCountries[selectedCountry]?['ar'] ??
                        selectedCountry!)
                    : _l.chooseRadio;

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SafeArea(
                      top: false,
                      child: Column(children: [
                        // ── مقبض السحب ──
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // ── شريط العنوان ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 10, 16, 6),
                          child: Row(
                            children: [
                              // زر رجوع أو إيقاف
                              SizedBox(
                                width: 40,
                                child: selectedCountry != null
                                    ? IconButton(
                                        onPressed: () => setSheetState(
                                            () => selectedCountry = null),
                                        icon: const Icon(
                                            Icons.arrow_back_ios_new,
                                            size: 18,
                                            color: Color(0xFF374151)),
                                        padding: EdgeInsets.zero,
                                      )
                                    : _selectedRadioName != null
                                        ? IconButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _stopRadio();
                                            },
                                            icon: const Icon(
                                                Icons.stop_circle_outlined,
                                                color: Colors.red,
                                                size: 22),
                                            padding: EdgeInsets.zero,
                                          )
                                        : const SizedBox(),
                              ),
                              // العنوان
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.radio,
                                        color: Color(0xFF3B5BDB), size: 20),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        countryName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // ── المحتوى: شبكة الأعلام أو قائمة المحطات ──
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: child,
                            ),
                            child: selectedCountry == null
                                ? _buildFlagGrid(
                                    key: const ValueKey('flags'),
                                    lang: lang,
                                    scrollCtrl: scrollCtrl,
                                    onSelect: (c) => setSheetState(
                                        () => selectedCountry = c),
                                  )
                                : _buildCountryStations(
                                    key: ValueKey(selectedCountry),
                                    countryKey: selectedCountry!,
                                    ctx: ctx,
                                    scrollCtrl: scrollCtrl,
                                    lang: lang,
                                  ),
                          ),
                        ),
                      ])),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFlagGrid({
    required Key key,
    required String lang,
    required ScrollController scrollCtrl,
    required void Function(String) onSelect,
  }) {
    return GridView.builder(
      key: key,
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: _kCountryOrder.length,
      itemBuilder: (_, i) {
        final ck = _kCountryOrder[i];
        final fullName =
            _radioCountries[ck]?[lang] ?? _radioCountries[ck]?['ar'] ?? ck;
        // الاسم يبدأ بالعلم ثم مسافة ثم الاسم
        final spaceIdx = fullName.indexOf(' ');
        final flag = spaceIdx > 0 ? fullName.substring(0, spaceIdx) : fullName;
        final name = spaceIdx > 0 ? fullName.substring(spaceIdx + 1) : '';
        final hasLive = (_liveStations[ck] ?? []).isNotEmpty;

        return GestureDetector(
          onTap: () => onSelect(ck),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 4,
                    offset: Offset(0, 2))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (ck == 'sy')
                  const _SyrianRevFlag(size: 34)
                else
                  Text(flag, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151)),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasLive) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountryStations({
    required Key key,
    required String countryKey,
    required BuildContext ctx,
    required ScrollController scrollCtrl,
    required String lang,
  }) {
    final live = _liveStations[countryKey] ?? [];
    final stations = (live.isNotEmpty
            ? live
            : _radioStations
                .where((s) => s.countryKey == countryKey)
                .map((s) => {'name': s.nameFor(lang), 'url': s.url})
                .toList())
        .take(30)
        .toList();

    return ListView.separated(
      key: key,
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 76, endIndent: 16),
      itemCount: stations.length,
      itemBuilder: (_, i) {
        final station = stations[i];
        final isPlaying = station['url'] == _selectedRadioUrl;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () {
            Navigator.pop(ctx);
            _playUrl(station['url']!, station['name']!);
          },
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPlaying
                  ? const Color(0xFF3B5BDB).withValues(alpha: 0.1)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPlaying ? Icons.graphic_eq : Icons.radio_outlined,
              color: isPlaying ? const Color(0xFF3B5BDB) : Colors.grey.shade500,
              size: 22,
            ),
          ),
          title: Text(
            station['name']!,
            style: TextStyle(
              fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color:
                  isPlaying ? const Color(0xFF3B5BDB) : const Color(0xFF1F2937),
            ),
          ),
          subtitle: isPlaying
              ? Text(
                  '● جارٍ التشغيل',
                  style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF3B5BDB).withValues(alpha: 0.8)),
                )
              : null,
          trailing: isPlaying
              ? const Icon(Icons.check_circle,
                  color: Color(0xFF3B5BDB), size: 22)
              : const Icon(Icons.play_circle_outline,
                  color: Color(0xFF9CA3AF), size: 26),
        );
      },
    );
  }

  String get _profileLabel {
    final lang = Localizations.localeOf(context).languageCode;
    const labels = {
      'ar': 'الإعدادات',
      'de': 'Einstellungen',
      'fr': 'Paramètres',
      'sv': 'Inställningar',
      'uk': 'Налаштування',
      'tr': 'Ayarlar',
      'ku': 'Mîheng',
      'ckb': 'ڕێکخستنەکان',
    };
    return labels[lang] ?? 'الإعدادات';
  }

  String get _friendsLabel {
    final lang = Localizations.localeOf(context).languageCode;
    const labels = {
      'ar': 'متابعين',
      'de': 'Freunde',
      'fr': 'Amis',
      'sv': 'Vänner',
      'uk': 'Друзі',
      'tr': 'Arkadaşlar',
      'ku': 'Şopîner',
      'ckb': 'شوێنکەوتووان',
    };
    return labels[lang] ?? 'أصدقاء';
  }

  Widget _buildBottomNavBar() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2))
        ]),
        child: SafeArea(
          top: false,
          child: SizedBox(
              height: 80,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(
                        icon: Icons.home_outlined,
                        label: _l.home,
                        index: 4,
                        color: const Color(0xFF3B5BDB)),
                    _navItem(
                        icon: Icons.grid_view_outlined,
                        label: _l.myAds,
                        index: 3,
                        color: const Color(0xFF10B981)),
                    _navItem(
                        icon: Icons.people_outline,
                        label: _friendsLabel,
                        index: 1,
                        color: const Color(0xFFF97316),
                        badge: _totalUnread),
                    _navItem(
                        icon: Icons.settings_outlined,
                        label: _profileLabel,
                        index: 0,
                        color: const Color(0xFF8B5CF6)),
                  ])),
        ),
      ),
    );
  }

  Widget _buildAuctionSection() {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF3B5BDB)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuctionsScreen()),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      l10n.auctionViewAll,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Text(
                  l10n.auctionSectionHome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_auctionsLoading)
            const SizedBox(
              height: 149,
              child: Center(
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          else if (_activeAuctions.isEmpty)
            _buildAuctionEmpty(l10n)
          else
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: _isDesktop ? 680 : double.infinity),
                child: SizedBox(
                  height: 230,
                  child: PageView.builder(
                    controller: PageController(
                        viewportFraction: _isDesktop ? 0.48 : 0.74),
                    itemCount: _activeAuctions.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 9),
                      child: AuctionCard(
                        key: ValueKey(_activeAuctions[i].id),
                        auction: _activeAuctions[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuctionDetailScreen(
                                auction: _activeAuctions[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: GestureDetector(
              onTap: () async {
                if (!AuthService.isLoggedIn) {
                  await _showAuthRequired();
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAuctionScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      l10n.auctionAddYours,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionEmpty(AppLocalizations l10n) {
    return Container(
      height: 120,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔨', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            l10n.auctionNoActive,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddAuctionScreen()),
            ),
            child: Text(
              l10n.auctionBeFirst,
              style: const TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      {required IconData icon,
      required String label,
      required int index,
      Color color = const Color(0xFF3B5BDB),
      int badge = 0}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: SizedBox(
        width: 72,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon,
                    color: isSelected ? color : const Color(0xFF9CA3AF),
                    size: 28),
              ),
              if (badge > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? color : const Color(0xFF9CA3AF),
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

// ── علم سوريا الجديد (الاستقلال) ──
class _SyrianRevFlag extends StatelessWidget {
  final double size;
  const _SyrianRevFlag({this.size = 34});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 1.5, size),
      painter: _SyrianRevFlagPainter(),
    );
  }
}

class _SyrianRevFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 3;
    // الشريط الأخضر
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, h),
        Paint()..color = const Color(0xFF007A3D));
    // الشريط الأبيض
    canvas.drawRect(
        Rect.fromLTWH(0, h, size.width, h), Paint()..color = Colors.white);
    // الشريط الأسود
    canvas.drawRect(
        Rect.fromLTWH(0, h * 2, size.width, h), Paint()..color = Colors.black);
    // ثلاثة نجوم حمراء في الشريط الأبيض
    final cy = h + h / 2;
    final sp = size.width / 5.5;
    for (int i = -1; i <= 1; i++) {
      _drawStar(canvas, Offset(size.width / 2 + i * sp, cy), h * 0.38,
          const Color(0xFFCE1126));
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? r : r * 0.4;
      final pt = Offset(
          c.dx + radius * math.cos(angle), c.dy + radius * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_) => false;
}
