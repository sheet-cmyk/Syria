import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/category_helper.dart';
import '../widgets/cached_ad_image.dart';
import 'add_ad_screen.dart';
import 'edit_ad_screen.dart';
import 'favorites_screen.dart';

const Map<String, Map<String, String>> _myAdsStrings = {
  'ar': {
    'myAds': 'إعلاناتي',
    'add': '+ إضافة',
    'loginFirst': 'يجب تسجيل الدخول أولاً',
    'error': 'خطأ',
    'noAds': 'لا توجد إعلانات بعد',
    'startFirst': 'ابدأ بنشر إعلانك الأول!',
    'addNew': 'إضافة إعلان جديد',
    'active': 'نشط',
    'deleteTitle': 'حذف الإعلان',
    'deleteMsg': 'هل تريد حذف هذا الإعلان؟',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'deleted': 'تم حذف الإعلان ✓',
    'edit': 'تعديل',
    'favorites': 'مفضلتي',
    'minsAgo': 'منذ {n} دقيقة',
    'hoursAgo': 'منذ {n} ساعة',
    'daysAgo': 'منذ {n} يوم',
  },
  'en': {
    'myAds': 'My Ads',
    'add': '+ Add',
    'loginFirst': 'Please log in first',
    'error': 'Error',
    'noAds': 'No ads yet',
    'startFirst': 'Post your first ad!',
    'addNew': 'Add new ad',
    'active': 'Active',
    'deleteTitle': 'Delete Ad',
    'deleteMsg': 'Do you want to delete this ad?',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'deleted': 'Ad deleted ✓',
    'edit': 'Edit',
    'favorites': 'My Favorites',
    'minsAgo': '{n} min ago',
    'hoursAgo': '{n} hrs ago',
    'daysAgo': '{n} days ago',
  },
  'de': {
    'myAds': 'Meine Anzeigen',
    'add': '+ Hinzufügen',
    'loginFirst': 'Bitte zuerst einloggen',
    'error': 'Fehler',
    'noAds': 'Noch keine Anzeigen',
    'startFirst': 'Erstelle deine erste Anzeige!',
    'addNew': 'Neue Anzeige erstellen',
    'active': 'Aktiv',
    'deleteTitle': 'Anzeige löschen',
    'deleteMsg': 'Möchtest du diese Anzeige löschen?',
    'cancel': 'Abbrechen',
    'delete': 'Löschen',
    'deleted': 'Anzeige gelöscht ✓',
    'edit': 'Bearbeiten',
    'favorites': 'Favoriten',
    'minsAgo': 'Vor {n} Minuten',
    'hoursAgo': 'Vor {n} Stunden',
    'daysAgo': 'Vor {n} Tagen',
  },
  'fr': {
    'myAds': 'Mes annonces',
    'add': '+ Ajouter',
    'loginFirst': 'Veuillez vous connecter d\'abord',
    'error': 'Erreur',
    'noAds': 'Aucune annonce pour l\'instant',
    'startFirst': 'Publiez votre première annonce !',
    'addNew': 'Ajouter une annonce',
    'active': 'Actif',
    'deleteTitle': 'Supprimer l\'annonce',
    'deleteMsg': 'Voulez-vous supprimer cette annonce ?',
    'cancel': 'Annuler',
    'delete': 'Supprimer',
    'deleted': 'Annonce supprimée ✓',
    'edit': 'Modifier',
    'favorites': 'Favoris',
    'minsAgo': 'Il y a {n} min',
    'hoursAgo': 'Il y a {n} h',
    'daysAgo': 'Il y a {n} j',
  },
  'sv': {
    'myAds': 'Mina annonser',
    'add': '+ Lägg till',
    'loginFirst': 'Vänligen logga in först',
    'error': 'Fel',
    'noAds': 'Inga annonser ännu',
    'startFirst': 'Lägg upp din första annons!',
    'addNew': 'Lägg upp ny annons',
    'active': 'Aktiv',
    'deleteTitle': 'Ta bort annons',
    'deleteMsg': 'Vill du ta bort den här annonsen?',
    'cancel': 'Avbryt',
    'delete': 'Ta bort',
    'deleted': 'Annons borttagen ✓',
    'edit': 'Redigera',
    'favorites': 'Favoriter',
    'minsAgo': 'För {n} min sedan',
    'hoursAgo': 'För {n} tim sedan',
    'daysAgo': 'För {n} dagar sedan',
  },
  'uk': {
    'myAds': 'Мої оголошення',
    'add': '+ Додати',
    'loginFirst': 'Будь ласка, увійдіть спочатку',
    'error': 'Помилка',
    'noAds': 'Оголошень поки немає',
    'startFirst': 'Створіть своє перше оголошення!',
    'addNew': 'Додати оголошення',
    'active': 'Активне',
    'deleteTitle': 'Видалити оголошення',
    'deleteMsg': 'Ви хочете видалити це оголошення?',
    'cancel': 'Скасувати',
    'delete': 'Видалити',
    'deleted': 'Оголошення видалено ✓',
    'edit': 'Редагувати',
    'favorites': 'Вибране',
    'minsAgo': '{n} хв тому',
    'hoursAgo': '{n} год тому',
    'daysAgo': '{n} дн тому',
  },
  'tr': {
    'myAds': 'İlanlarım',
    'add': '+ Ekle',
    'loginFirst': 'Lütfen önce giriş yapın',
    'error': 'Hata',
    'noAds': 'Henüz ilan yok',
    'startFirst': 'İlk ilanınızı yayınlayın!',
    'addNew': 'Yeni ilan ekle',
    'active': 'Aktif',
    'deleteTitle': 'İlanı Sil',
    'deleteMsg': 'Bu ilanı silmek istiyor musunuz?',
    'cancel': 'İptal',
    'delete': 'Sil',
    'deleted': 'İlan silindi ✓',
    'edit': 'Düzenle',
    'favorites': 'Favorilerim',
    'minsAgo': '{n} dk önce',
    'hoursAgo': '{n} sa önce',
    'daysAgo': '{n} gün önce',
  },
  'ku': {
    'myAds': 'Reklamên min',
    'add': '+ Zêde bike',
    'loginFirst': 'Divê pêşî têkevî',
    'error': 'Çewtî',
    'noAds': 'Hîn reklam tune',
    'startFirst': 'Reklamê xwe yê yekem biweşîne!',
    'addNew': 'Reklamek nû zêde bike',
    'active': 'Çalak',
    'deleteTitle': 'Reklamê jê bibe',
    'deleteMsg': 'Tu dixwazî vê reklamê jê bibî?',
    'cancel': 'Betal bike',
    'delete': 'Jê bibe',
    'deleted': 'Reklam hate jêbirin ✓',
    'edit': 'Biguherîne',
    'favorites': 'Bijartîyên min',
    'minsAgo': 'Berî {n} xulekan',
    'hoursAgo': 'Berî {n} saetan',
    'daysAgo': 'Berî {n} rojan',
  },
  'ckb': {
    'myAds': 'ئەعلانەکانم',
    'add': '+ زیادکردن',
    'loginFirst': 'پێویستە سەریان بکەیتەوە',
    'error': 'هەڵە',
    'noAds': 'هێشتا ئەعلان نییە',
    'startFirst': 'یەکەم ئەعلانەکەت بڵاو بکەرەوە!',
    'addNew': 'ئەعلانی نوێ زیاد بکە',
    'active': 'چالاک',
    'deleteTitle': 'ئەعلان بسڕەوە',
    'deleteMsg': 'دەتەوێت ئەم ئەعلانە بسڕیتەوە؟',
    'cancel': 'هەڵوەشاندنەوە',
    'delete': 'سڕینەوە',
    'deleted': 'ئەعلان سڕایەوە ✓',
    'edit': 'دەستکاری',
    'favorites': 'دڵخوازەکانم',
    'minsAgo': '{n} خولەک لەمەوبەر',
    'hoursAgo': '{n} کاتژمێر لەمەوبەر',
    'daysAgo': '{n} ڕۆژ لەمەوبەر',
  },
};

String _t(String lang, String key, {int? n}) {
  String text = _myAdsStrings[lang]?[key] ?? _myAdsStrings['ar']![key] ?? key;
  if (n != null) text = text.replaceAll('{n}', '$n');
  return text;
}

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});
  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _edit(BuildContext ctx, String id, Map<String, dynamic> data) =>
      Navigator.push(
          ctx,
          MaterialPageRoute(
              builder: (_) => EditAdScreen(docId: id, adData: data)));

  void _delete(BuildContext ctx, String id, String lang) {
    final l = lang;
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(_t(l, 'deleteTitle'),
                  textAlign: l == 'ar' ? TextAlign.right : TextAlign.left),
              content: Text(_t(l, 'deleteMsg'),
                  textAlign: l == 'ar' ? TextAlign.right : TextAlign.left),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(_t(l, 'cancel'))),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await FirebaseFirestore.instance
                        .collection('ads')
                        .doc(id)
                        .delete();
                if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(_t(l, 'deleted')),
                          backgroundColor: Colors.red));
                }
                  },
                  child: Text(_t(l, 'delete'),
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ));
  }

  String _fmtDate(DateTime d, String lang) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return _t(lang, 'minsAgo', n: diff.inMinutes);
    if (diff.inHours < 24) return _t(lang, 'hoursAgo', n: diff.inHours);
    if (diff.inDays < 30) return _t(lang, 'daysAgo', n: diff.inDays);
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    // قراءة اللغة من الـ context مباشرة — يتحدث تلقائياً عند تغيير اللغة
    final l = Localizations.localeOf(context).languageCode;
    final rtl = l == 'ar' || l == 'ckb';
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          child: Column(children: [
            // ── Header ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                            rtl ? Icons.arrow_forward : Icons.arrow_back,
                            size: 24)),
                    Text(_t(l, 'myAds'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddAdScreen())),
                        child: Text(_t(l, 'add'),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFFFD600),
                                fontWeight: FontWeight.w600))),
                  ]),
            ),

            // ── TabBar ──
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: const Color(0xFF3B5BDB),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFFFD600),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: _t(l, 'myAds')),
                  Tab(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      text: _t(l, 'favorites')),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // ── تاب إعلاناتي ──
                  user == null
                      ? Center(child: Text(_t(l, 'loginFirst')))
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('ads')
                              .where('userId', isEqualTo: user.uid)
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFFFFD600)));
                        }
                        if (snap.hasError) {
                              return Center(
                                  child:
                                      Text('${_t(l, "error")}: ${snap.error}'));
                        }

                            final docs = (snap.data?.docs ?? []).where((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              return d['isProfessional'] != true;
                            }).toList();

                        if (docs.isEmpty) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.article_outlined,
                                      size: 70, color: Color(0xFF9CA3AF)),
                                  const SizedBox(height: 12),
                                  Text(_t(l, 'noAds'),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF6B7280))),
                                  const SizedBox(height: 6),
                                  Text(_t(l, 'startFirst'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF9CA3AF))),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const AddAdScreen())),
                                    icon: const Icon(Icons.add,
                                        color: Colors.black),
                                    label: Text(_t(l, 'addNew'),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFD600),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                  ),
                                ],
                              );
                        }

                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: docs.length,
                              itemBuilder: (ctx, i) {
                                final doc = docs[i];
                                final data = doc.data() as Map<String, dynamic>;
                                final cat = data['category'] ?? '';
                                final imgs =
                                    (data['images'] as List?)?.cast<String>() ??
                                        [];
                                final ts = data['createdAt'] as Timestamp?;
                                final date =
                                    ts != null ? _fmtDate(ts.toDate(), l) : '';

                                // ✅ A1: CategoryHelper.find مرة واحدة فقط
                                final found = CategoryHelper.find(cat);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 6)
                                    ],
                                  ),
                                  child: Row(children: [
                                    // أزرار التعديل والحذف
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                              onTap: () =>
                                                  _edit(ctx, doc.id, data),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEFF6FF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: const Icon(
                                                      Icons.edit_outlined,
                                                      color: Color(0xFF3B82F6),
                                                      size: 20))),
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                              onTap: () =>
                                                  _delete(ctx, doc.id, l),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFFEE2E2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: const Icon(
                                                      Icons.delete_outline,
                                                      color: Color(0xFFEF4444),
                                                      size: 20))),
                                        ]),
                                    const SizedBox(width: 10),

                                    // التفاصيل
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: rtl
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(data['title'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937)),
                                              textAlign: rtl
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 3),
                                          Text(
                                              (data['currency'] ?? 'SYP') ==
                                                      'USD'
                                                  ? '\$${data["price"] ?? ""}'
                                                  : '${data["price"] ?? ""} ل.س',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFFFD600))),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: rtl
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            children: [
                                              Text(date,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          Color(0xFF9CA3AF))),
                                              const SizedBox(width: 8),
                                              Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFDCFCE7),
                                                      borderRadius: BorderRadius
                                                          .circular(20)),
                                                  child: Text(
                                                      _t(l, 'active'),
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                              0xFF166534)))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // ✅ A4: CachedAdImage بدلاً من Image.network
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedAdImage(
                                        url:
                                            imgs.isNotEmpty ? imgs.first : null,
                                        category: found,
                                        height: 64,
                                        width: 64,
                                      ),
                                    ),
                                  ]),
                                );
                              },
                            );
                          }),

                  // ── تاب المفضلة ──
                  const FavoritesScreen(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
