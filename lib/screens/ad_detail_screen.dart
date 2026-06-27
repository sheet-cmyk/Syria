import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ جديد
import '../models/models.dart';
import '../utils/category_helper.dart'; // ✅ جديد
import '../widgets/cached_ad_image.dart'; // ✅ جديد
import '../gen_l10n/app_localizations.dart';
import '../gen_l10n/app_localizations_ar.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import 'admin_panel_screen.dart';
import 'publisher_screen.dart';

// ── شاشة إعلانات المستخدم ──
class UserAdsScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String userPhoto;

  const UserAdsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title:
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ads')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD600)));
          }
          final docs = (snapshot.data?.docs ?? [])
              .where((d) => (d.data() as Map)['status'] != 'deleted')
              .toList();
          if (docs.isEmpty) {
            return const Center(
                child: Text('لا توجد إعلانات',
                    style: TextStyle(color: Colors.grey)));
          }
          return Column(children: [
            // هيدر المستخدم
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // ✅ A4: CachedNetworkImage بدلاً من NetworkImage
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade300,
                  child: userPhoto.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userPhoto,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        )
                      : Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(userName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${docs.length} إعلان',
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ]),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final images =
                      (data['images'] as List?)?.cast<String>() ?? [];
                  final category = data['category'] ?? '';
                  // ✅ A1: CategoryHelper بدلاً من حلقة O(N×6)
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
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6)
                          ]),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14)),
                              // ✅ A4: CachedAdImage بدلاً من Image.network
                              child: CachedAdImage(
                                url: images.isNotEmpty ? images.first : null,
                                category: found,
                                height: 130,
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(10),
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
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Flexible(
                                                child: Text(data['city'] ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Color(0xFF6B7280)),
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            const SizedBox(width: 3),
                                            const Text('📍',
                                                style: TextStyle(fontSize: 11)),
                                          ]),
                                    ])),
                          ]),
                    ),
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
class AdDetailScreen extends StatefulWidget {
  final AdModel ad;
  final Map<String, dynamic>? firestoreData;
  final String? docId;

  const AdDetailScreen(
      {super.key, required this.ad, this.firestoreData, this.docId});

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  int _viewCount = 0;
  String _publisherPhone = '';
  Map<String, String> _publisherSocialLinks = {};
  Map<String, dynamic> _publisherData = {};
  int _publisherAdsCount = 0;
  late AppLocalizations _l;

  String _t(String key) {
    final code = _l.localeName;
    const Map<String, Map<String, String>> strings = {
      'adDetails': {
        'ar': 'تفاصيل الإعلان',
        'en': 'Ad Details',
        'de': 'Anzeigendetails',
        'fr': "Détails de l'annonce",
        'sv': 'Annonsdetaljer',
        'uk': 'Деталі оголошення',
        'tr': 'İlan Detayları'
      },
      'category': {
        'ar': 'القسم',
        'en': 'Category',
        'de': 'Kategorie',
        'fr': 'Catégorie',
        'sv': 'Kategori',
        'uk': 'Категорія',
        'tr': 'Kategori'
      },
      'city': {
        'ar': 'المدينة',
        'en': 'City',
        'de': 'Stadt',
        'fr': 'Ville',
        'sv': 'Stad',
        'uk': 'Місто',
        'tr': 'Şehir'
      },
      'zip': {
        'ar': 'الرمز البريدي',
        'en': 'Postal Code',
        'de': 'Postleitzahl',
        'fr': 'Code postal',
        'sv': 'Postnummer',
        'uk': 'Поштовий індекс',
        'tr': 'Posta Kodu'
      },
      'street': {
        'ar': 'الشارع',
        'en': 'Street',
        'de': 'Straße',
        'fr': 'Rue',
        'sv': 'Gata',
        'uk': 'Вулиця',
        'tr': 'Sokak'
      },
      'condition': {
        'ar': 'الحالة',
        'en': 'Condition',
        'de': 'Zustand',
        'fr': 'État',
        'sv': 'Skick',
        'uk': 'Стан',
        'tr': 'Durum'
      },
      'publishDate': {
        'ar': 'تاريخ النشر',
        'en': 'Published Date',
        'de': 'Veröffentlicht am',
        'fr': 'Date de publication',
        'sv': 'Publiceringsdatum',
        'uk': 'Дата публікації',
        'tr': 'Yayın Tarihi'
      },
      'description': {
        'ar': 'الوصف',
        'en': 'Description',
        'de': 'Beschreibung',
        'fr': 'Description',
        'sv': 'Beskrivning',
        'uk': 'Опис',
        'tr': 'Açıklama'
      },
      'noDesc': {
        'ar': 'لا يوجد وصف',
        'en': 'No description',
        'de': 'Keine Beschreibung',
        'fr': 'Aucune description',
        'sv': 'Ingen beskrivning',
        'uk': 'Немає опису',
        'tr': 'Açıklama yok'
      },
      'watchVideo': {
        'ar': 'مشاهدة فيديو الإعلان',
        'en': 'Watch Ad Video',
        'de': 'Video ansehen',
        'fr': 'Voir la vidéo',
        'sv': 'Se video',
        'uk': 'Переглянути відео',
        'tr': 'Videoyu İzle'
      },
      'contactVia': {
        'ar': 'تواصل عبر',
        'en': 'Contact via',
        'de': 'Kontakt über',
        'fr': 'Contacter via',
        'sv': 'Kontakta via',
        'uk': "Зв'язатись через",
        'tr': 'İletişim'
      },
      'contactNow': {
        'ar': 'تواصل الآن',
        'en': 'Contact Now',
        'de': 'Jetzt kontaktieren',
        'fr': 'Contacter maintenant',
        'sv': 'Kontakta nu',
        'uk': "Зв'яжіться зараз",
        'tr': 'Şimdi İletişim'
      },
      'whatsapp': {
        'ar': 'تواصل عبر واتساب',
        'en': 'Contact via WhatsApp',
        'de': 'WhatsApp kontaktieren',
        'fr': 'Contacter via WhatsApp',
        'sv': 'Kontakta via WA',
        'uk': 'Написати у WhatsApp',
        'tr': 'WhatsApp ile İletişim'
      },
      'inFav': {
        'ar': 'في المفضلة',
        'en': 'In Favorites',
        'de': 'In Favoriten',
        'fr': 'En favoris',
        'sv': 'I favoriter',
        'uk': 'У вибраному',
        'tr': 'Favorilerde'
      },
      'addFav': {
        'ar': 'أضف للمفضلة',
        'en': 'Add to Favorites',
        'de': 'Zu Favoriten',
        'fr': 'Ajouter aux favoris',
        'sv': 'Lägg till favoriter',
        'uk': 'Додати до вибраного',
        'tr': 'Favorilere Ekle'
      },
      'views': {
        'ar': 'مشاهدة',
        'en': 'views',
        'de': 'Aufrufe',
        'fr': 'vues',
        'sv': 'visningar',
        'uk': 'переглядів',
        'tr': 'görüntüleme'
      },
      'loginFirst': {
        'ar': 'سجّل دخولك لإضافة للمفضلة',
        'en': 'Log in to add to favorites',
        'de': 'Bitte einloggen',
        'fr': "Connectez-vous d'abord",
        'sv': 'Logga in först',
        'uk': 'Спочатку увійдіть',
        'tr': 'Önce giriş yapın'
      },
      'noPhone': {
        'ar': 'رقم التواصل غير متوفر',
        'en': 'Contact not available',
        'de': 'Nicht verfügbar',
        'fr': 'Numéro non disponible',
        'sv': 'Ej tillgängligt',
        'uk': 'Номер недоступний',
        'tr': 'Telefon numarası yok'
      },
      'waError': {
        'ar': 'تعذر فتح واتساب',
        'en': 'Could not open WhatsApp',
        'de': 'WhatsApp konnte nicht geöffnet werden',
        'fr': "Impossible d'ouvrir WhatsApp",
        'sv': 'Kunde inte öppna WhatsApp',
        'uk': 'Не вдалося відкрити WhatsApp',
        'tr': 'WhatsApp açılamadı'
      },
      'linkError': {
        'ar': 'تعذر فتح الرابط',
        'en': 'Could not open link',
        'de': 'Link nicht verfügbar',
        'fr': 'Lien non disponible',
        'sv': 'Länk ej tillgänglig',
        'uk': 'Посилання недоступне',
        'tr': 'Bağlantı açılamadı'
      },
      'copied': {
        'ar': 'تم نسخ الإعلان',
        'en': 'Ad copied',
        'de': 'Anzeige kopiert',
        'fr': 'Annonce copiée',
        'sv': 'Annons kopierad',
        'uk': 'Оголошення скопійовано',
        'tr': 'İlan kopyalandı'
      },
      'shareText': {
        'ar': 'شاهد الإعلان في تطبيقنا',
        'en': 'Check out this ad',
        'de': 'Sieh dir die Anzeige an',
        'fr': "Voir l'annonce",
        'sv': 'Se annonsen',
        'uk': 'Переглянь оголошення',
        'tr': 'İlanı gör'
      },
      'new': {
        'ar': 'جديد',
        'en': 'New',
        'de': 'Neu',
        'fr': 'Neuf',
        'sv': 'Ny',
        'uk': 'Новий',
        'tr': 'Yeni'
      },
      'used': {
        'ar': 'مستعمل',
        'en': 'Used',
        'de': 'Gebraucht',
        'fr': 'Occasion',
        'sv': 'Begagnad',
        'uk': 'Вживаний',
        'tr': 'Kullanılmış'
      },
      'seller': {
        'ar': 'البائع',
        'en': 'Seller',
        'de': 'Verkäufer',
        'fr': 'Vendeur',
        'sv': 'Säljare',
        'uk': 'Продавець',
        'tr': 'Satıcı'
      },
      'allAds': {
        'ar': 'كل الإعلانات',
        'en': 'All Ads',
        'de': 'Alle Anzeigen',
        'fr': 'Toutes les annonces',
        'sv': 'Alla annonser',
        'uk': 'Всі оголошення',
        'tr': 'Tüm İlanlar'
      },
      'ads': {
        'ar': 'إعلان',
        'en': 'ad',
        'de': 'Anzeige',
        'fr': 'annonce',
        'sv': 'annons',
        'uk': 'оголошення',
        'tr': 'ilan'
      },
      'memberSince': {
        'ar': 'عضو منذ',
        'en': 'Member since',
        'de': 'Mitglied seit',
        'fr': 'Membre depuis',
        'sv': 'Medlem sedan',
        'uk': 'Учасник з',
        'tr': 'Üye'
      },
    };
    return strings[key]?[code] ?? strings[key]?['ar'] ?? key;
  }

  String _conditionLabel(String raw) {
    if (raw == 'جديد' || raw == 'new' || raw == 'Neu') return _t('new');
    return _t('used');
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.ad.isFavorite;
    _incrementViews();
    _loadPublisherData();
    _loadFavoriteStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l = AppLocalizations.of(context) ?? AppLocalizationsAr('ar');
  }

  Future<void> _loadPublisherData() async {
    final userId = widget.firestoreData?['userId'] ?? '';
    if (userId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        final adsSnap = await FirebaseFirestore.instance
            .collection('ads')
            .where('userId', isEqualTo: userId)
            .get();
        final activeCount =
            adsSnap.docs.where((d) => (d.data())['status'] != 'deleted').length;
        setState(() {
          _publisherData = data;
          _publisherPhone = data['phone'] ?? '';
          _publisherAdsCount = activeCount;
          final social = data['socialLinks'];
          if (social is Map) {
            _publisherSocialLinks = {
              'facebook': social['facebook'] ?? '',
              'instagram': social['instagram'] ?? '',
              'tiktok': social['tiktok'] ?? '',
            };
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.docId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.docId)
          .get();
      if (mounted) setState(() => _isFavorite = doc.exists);
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack(_t('loginFirst'));
      return;
    }
    if (widget.docId == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.docId);
    if (_isFavorite) {
      await ref.delete();
    } else {
      await ref.set({
        'adId': widget.docId,
        'title': widget.ad.title,
        'price': widget.ad.price,
        'city': widget.firestoreData?['city'] ?? widget.ad.city,
        'category': widget.ad.category,
        'subCategory': widget.ad.subCategory,
        'description': widget.ad.description,
        'condition': widget.ad.condition,
        'phone': widget.firestoreData?['phone'] ?? widget.ad.phone,
        'images': widget.firestoreData?['images'] ?? [],
        'userId': widget.firestoreData?['userId'] ?? '',
        'currency': widget.firestoreData?['currency'] ?? 'SYP',
        'shareLinks': widget.firestoreData?['shareLinks'] ?? {},
        'videoUrl': widget.firestoreData?['videoUrl'] ?? '',
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  // ✅ C4: دمج update + get في عملية واحدة باستخدام transaction
  Future<void> _incrementViews() async {
    if (widget.docId == null) return;
    try {
      final ref =
          FirebaseFirestore.instance.collection('ads').doc(widget.docId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = (snap.data()?['views'] ?? 0) as int;
        tx.update(ref, {'views': current + 1});
        if (mounted) setState(() => _viewCount = current + 1);
      });
    } catch (_) {}
  }

  List<String> get _images {
    final imgs = widget.firestoreData?['images'];
    if (imgs is List) return imgs.cast<String>();
    return [];
  }

  Map<String, String> get _adShareLinks {
    final links = widget.firestoreData?['shareLinks'];
    if (links is Map) return links.cast<String, String>();
    return {};
  }

  String get _videoUrl => widget.firestoreData?['videoUrl'] ?? '';

  String get _effectivePhone {
    if (_publisherPhone.isNotEmpty) return _publisherPhone;
    return widget.firestoreData?['phone'] ?? widget.ad.phone;
  }

  // ✅ A1: CategoryHelper بدلاً من _getCategoryIcon/_getCategoryColor المكررتين
  Future<void> _contactNow() async {
    String phone = _effectivePhone;
    if (phone.isEmpty) {
      _showSnack(_t('noPhone'));
      return;
    }
    phone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!phone.startsWith('+') && !phone.startsWith('00')) phone = '+$phone';
    try {
      await launchUrl(Uri.parse('tel:$phone'));
    } catch (_) {
      try {
        await launchUrl(Uri.parse('https://wa.me/$phone'),
            mode: LaunchMode.externalApplication);
      } catch (_) {
        _showSnack(_t('noPhone'));
      }
    }
  }

  Future<void> _openWhatsApp() async {
    final waLink = _adShareLinks['واتساب'] ?? '';
    if (waLink.isNotEmpty) {
      await _openLink(waLink);
      return;
    }
    String phone = _effectivePhone;
    phone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (phone.isEmpty) {
      _showSnack(_t('noPhone'));
      return;
    }
    if (!phone.startsWith('+') && !phone.startsWith('00')) phone = '+$phone';
    try {
      await launchUrl(Uri.parse('https://wa.me/$phone'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack(_t('waError'));
    }
  }

  Future<void> _openLink(String url) async {
    if (url.isEmpty) return;
    try {
      String cleanUrl = url.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://'))
        cleanUrl = 'https://$cleanUrl';
      await launchUrl(Uri.parse(cleanUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack(_t('linkError'));
    }
  }

  Future<void> _shareAd() async {
    final docId = widget.docId ?? '';
    final adUrl =
        docId.isNotEmpty ? 'https://syria-51312.web.app/#/ad/$docId' : '';
    final city = widget.firestoreData?['city'] ?? widget.ad.city;
    const appTitle = 'سوق مستعمل سوريا';

    final currency = widget.firestoreData?['currency'] ?? 'SYP';
    final formattedPrice =
        currency == 'USD' ? '\$${widget.ad.price}' : '${widget.ad.price} ل.س';

    final text = '🛍️ $appTitle\n${widget.ad.title}\n$formattedPrice\n📍 $city'
        '${adUrl.isNotEmpty ? '\n\n$adUrl' : '\n\n${_t('shareText')}'}';
    await Clipboard.setData(ClipboardData(text: text));
    try {
      await launchUrl(
          Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack(_t('copied'));
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showAdminSheet(BuildContext ctx) {
    final docId = widget.docId!;
    final data = widget.firestoreData ?? {};
    final hidden = data['hidden'] == true;
    final userId = data['userId'] ?? '';

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Row(children: [
                Icon(Icons.admin_panel_settings, color: Color(0xFFFFD600)),
                SizedBox(width: 8),
                Text('إجراءات المشرف',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              _adminTile(
                  Icons.visibility_off,
                  hidden ? 'إظهار الإعلان' : 'إخفاء الإعلان',
                  Colors.orange, () async {
                Navigator.pop(_);
                final err =
                    await AdminService.toggleAdVisibility(docId, !hidden);
                _showSnack(
                    err ?? (hidden ? 'تم إظهار الإعلان' : 'تم إخفاء الإعلان'));
              }),
              _adminTile(Icons.edit, 'تعديل الإعلان', const Color(0xFF3B5BDB),
                  () {
                Navigator.pop(_);
                showModalBottomSheet(
                  context: ctx,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (__) => AdminEditAdSheet(docId: docId, data: data),
                );
              }),
              _adminTile(
                  Icons.photo_camera, 'إدارة الصور', const Color(0xFF059669),
                  () {
                Navigator.pop(_);
                final images = List<String>.from(data['images'] ?? []);
                showModalBottomSheet(
                  context: ctx,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (__) =>
                      AdminImagesSheet(docId: docId, images: images),
                );
              }),
              if (userId.isNotEmpty)
                _adminTile(Icons.block, 'حظر صاحب الإعلان', Colors.deepOrange,
                    () {
                  Navigator.pop(_);
                  showModalBottomSheet(
                    context: ctx,
                    backgroundColor: Colors.transparent,
                    builder: (__) => BanDialog(
                      title: 'حظر صاحب الإعلان',
                      onBan: (until) async =>
                          AdminService.banUser(userId, until: until),
                    ),
                  );
                }),
              _adminTile(
                  Icons.delete_forever, 'حذف الإعلان نهائياً', Colors.red,
                  () async {
                Navigator.pop(_);
                final ok = await showDialog<bool>(
                  context: ctx,
                  builder: (__) => AlertDialog(
                    title: const Text('حذف الإعلان نهائياً',
                        textAlign: TextAlign.right),
                    content: const Text('لا يمكن التراجع عن هذه العملية.',
                        textAlign: TextAlign.right),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(__, false),
                          child: const Text('إلغاء')),
                      TextButton(
                        onPressed: () => Navigator.pop(__, true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('حذف نهائي'),
                      ),
                    ],
                  ),
                );
                if (ok == true && ctx.mounted) {
                  await AdminService.deleteAdPermanently(docId);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminTile(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14, color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    );
  }

  String get _tiktokLink {
    final fromAd = _adShareLinks['تيك توك'] ?? '';
    if (fromAd.isNotEmpty) return fromAd;
    return _publisherSocialLinks['tiktok'] ?? '';
  }

  String get _facebookLink {
    final fromAd = _adShareLinks['فيسبوك'] ?? '';
    if (fromAd.isNotEmpty) return fromAd;
    return _publisherSocialLinks['facebook'] ?? '';
  }

  String get _instagramLink {
    final fromAd = _adShareLinks['إنستغرام'] ?? '';
    if (fromAd.isNotEmpty) return fromAd;
    return _publisherSocialLinks['instagram'] ?? '';
  }

  // ── بطاقة صاحب الإعلان ──
  Widget _buildSellerCard() {
    final userId = widget.firestoreData?['userId'] ?? '';
    final userName =
        _publisherData['name'] ?? widget.firestoreData?['userName'] ?? '';
    final userPhoto =
        _publisherData['photoUrl'] ?? widget.firestoreData?['userPhoto'] ?? '';
    if (userId.isEmpty && userName.isEmpty) return const SizedBox();

    return GestureDetector(
      onTap: () {
        if (userId.isEmpty) return;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublisherScreen(
                publisherId: userId,
                publisherName: userName,
                publisherPhoto: userPhoto,
              ),
            ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ],
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.grid_view_rounded,
                    size: 14, color: Color(0xFFB8860B)),
                const SizedBox(width: 4),
                // ✅ B2: إصلاح '\$_publisherAdsCount' → '$_publisherAdsCount'
                Text('$_publisherAdsCount ${_t('ads')}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB8860B))),
              ]),
            ),
            const SizedBox(height: 6),
            Row(children: [
              Text(_t('allAds'),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B5BDB),
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_back_ios,
                  size: 12, color: Color(0xFF3B5BDB)),
            ]),
          ]),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(userName.isNotEmpty ? userName : _t('seller'),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 2),
              Text(_t('seller'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            const SizedBox(width: 12),
            Stack(children: [
              // ✅ A4: CachedNetworkImage في صورة البائع
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFFD600).withOpacity(0.3),
                child: userPhoto.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: userPhoto,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black54),
                          ),
                        ),
                      )
                    : Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black54)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _l = AppLocalizations.of(context) ?? AppLocalizationsAr('ar');
    final ad = widget.ad;
    final hasImages = _images.isNotEmpty;
    final hasPhone = _effectivePhone.isNotEmpty;
    final hasSocialLinks = _facebookLink.isNotEmpty ||
        _instagramLink.isNotEmpty ||
        _tiktokLink.isNotEmpty;

    // ✅ A1: CategoryHelper مرة واحدة للـ build
    final categoryFound = CategoryHelper.find(ad.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: AuthService.isAdmin && widget.docId != null
          ? FloatingActionButton.small(
              backgroundColor: const Color(0xFF1F2937),
              tooltip: 'إجراءات المشرف',
              onPressed: () => _showAdminSheet(context),
              child: const Icon(Icons.admin_panel_settings,
                  color: Color(0xFFFFD600), size: 20),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(builder: (_, c) {
          final hPad = c.maxWidth > 640 ? (c.maxWidth - 640) / 2 : 0.0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(children: [
              // AppBar
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_forward, size: 24)),
                      Text(_t('adDetails'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(children: [
                        GestureDetector(
                            onTap: _shareAd,
                            child: const Icon(Icons.share,
                                size: 26, color: Color(0xFF6B7280))),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: _toggleFavorite,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(_isFavorite),
                                color: _isFavorite ? Colors.red : Colors.grey,
                                size: 28),
                          ),
                        ),
                      ]),
                    ]),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    // ── الصور ──
                    Stack(children: [
                      if (hasImages)
                        SizedBox(
                          height: 280,
                          child: PageView.builder(
                            itemCount: _images.length,
                            onPageChanged: (i) =>
                                setState(() => _currentImageIndex = i),
                            itemBuilder: (_, i) => CachedNetworkImage(
                              // ✅ A4: CachedNetworkImage للصور الكبيرة
                              imageUrl: _images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (_, __) => Container(
                                color: categoryFound.color.withOpacity(0.1),
                                child: Icon(categoryFound.icon,
                                    size: 60, color: categoryFound.color),
                              ),
                              errorWidget: (_, __, ___) =>
                                  _iconPlaceholder(categoryFound),
                            ),
                          ),
                        )
                      else
                        _iconPlaceholder(categoryFound),
                      if (hasImages && _images.length > 1)
                        Positioned(
                          bottom: 50,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                _images.length,
                                (i) => AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      width: _currentImageIndex == i ? 20 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: _currentImageIndex == i
                                              ? Colors.white
                                              : Colors.white54,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                    )),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.remove_red_eye_outlined,
                                    color: Colors.grey.shade500, size: 16),
                                const SizedBox(width: 4),
                                Text('$_viewCount ${_t('views')}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13)),
                              ]),
                              Row(children: [
                                GestureDetector(
                                    onTap: _shareAd,
                                    child: Icon(Icons.share,
                                        color: Colors.grey.shade600, size: 20)),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _toggleFavorite,
                                  child: Row(children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Icon(
                                          _isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          key: ValueKey(_isFavorite),
                                          color: _isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 22),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isFavorite ? _t('inFav') : _t('addFav'),
                                      style: TextStyle(
                                          color: _isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ]),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ]),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  color: ad.condition == 'جديد'
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(_conditionLabel(ad.condition),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ad.condition == 'جديد'
                                          ? const Color(0xFF166534)
                                          : const Color(0xFF92400E)))),
                          const SizedBox(height: 10),
                          Text(ad.title,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F2937)),
                              textAlign: TextAlign.right),
                          const SizedBox(height: 6),
                          Text(
                              (widget.firestoreData?['currency'] ?? 'SYP') ==
                                      'USD'
                                  ? '\$${ad.price}'
                                  : '${ad.price} ل.س',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFD600))),
                          const SizedBox(height: 14),

                          // جدول التفاصيل
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(children: [
                              _detailRow(_t('category'),
                                  '${ad.category} › ${ad.subCategory}'),
                              _detailRow(_t('city'),
                                  '📍 ${widget.firestoreData?['city'] ?? ad.city}'),
                              if ((widget.firestoreData?['zip'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                _detailRow(_t('zip'),
                                    widget.firestoreData!['zip'].toString()),
                              if ((widget.firestoreData?['street'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                _detailRow(_t('street'),
                                    widget.firestoreData!['street'].toString()),
                              _detailRow(_t('condition'),
                                  _conditionLabel(ad.condition)),
                              _detailRow(_t('publishDate'), ad.date),
                            ]),
                          ),
                          const SizedBox(height: 14),

                          _buildSellerCard(),
                          const SizedBox(height: 14),

                          // الوصف
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_t('description'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF374151))),
                                  const SizedBox(height: 8),
                                  Text(
                                      ad.description.isEmpty
                                          ? _t('noDesc')
                                          : ad.description,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF4B5563),
                                          height: 1.7),
                                      textAlign: TextAlign.right),
                                ]),
                          ),

                          // فيديو
                          if (_videoUrl.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () => _openLink(_videoUrl),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: Colors.red.shade100)),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(_t('watchVideo'),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.play_circle_filled,
                                          color: Colors.red, size: 28),
                                    ]),
                              ),
                            ),
                          ],

                          // روابط المنصات
                          if (hasSocialLinks) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_t('contactVia'),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF374151))),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        if (_facebookLink.isNotEmpty)
                                          _socialBtn(
                                              'Facebook',
                                              Icons.facebook,
                                              const Color(0xFF1877F2),
                                              () => _openLink(_facebookLink)),
                                        if (_instagramLink.isNotEmpty)
                                          _socialBtn(
                                              'Instagram',
                                              Icons.camera_alt,
                                              const Color(0xFFE1306C),
                                              () => _openLink(_instagramLink)),
                                        if (_tiktokLink.isNotEmpty)
                                          _socialBtn(
                                              'TikTok',
                                              Icons.music_note,
                                              const Color(0xFF010101),
                                              () => _openLink(_tiktokLink)),
                                      ],
                                    ),
                                  ]),
                            ),
                          ],

                          const SizedBox(height: 16),

                          if (hasPhone) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: _contactNow,
                                icon: const Icon(Icons.phone,
                                    color: Colors.white),
                                label: Text(_t('contactNow'),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B5BDB),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    elevation: 0),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _openWhatsApp,
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: Text(_t('whatsapp'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 0),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }

  // ✅ A1: استخدام categoryFound الممرر بدلاً من _getCategoryIcon/_getCategoryColor
  Widget _iconPlaceholder(Category cat) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        cat.color.withOpacity(0.2),
        cat.color.withOpacity(0.4),
      ])),
      child: Center(child: Icon(cat.icon, size: 80, color: cat.color)),
    );
  }

  Widget _socialBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 6),
          Icon(icon, color: color, size: 18),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ]),
    );
  }
}
