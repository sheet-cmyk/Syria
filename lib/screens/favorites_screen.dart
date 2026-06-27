import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../utils/category_helper.dart';
import '../widgets/cached_ad_image.dart';
import 'ad_detail_screen.dart';
import 'auth_screen.dart';

const Map<String, Map<String, String>> _favStr = {
  'ar': {
    'title': 'مفضلتي',
    'loginRequired': 'يجب تسجيل الدخول أولاً',
    'login': 'تسجيل دخول',
    'noFavorites': 'لا توجد مفضلة بعد',
    'tapHeart': 'اضغط على القلب لحفظ الإعلانات',
  },
  'en': {
    'title': 'My Favorites',
    'loginRequired': 'Please log in first',
    'login': 'Log in',
    'noFavorites': 'No favorites yet',
    'tapHeart': 'Tap the heart to save ads',
  },
  'de': {
    'title': 'Favoriten',
    'loginRequired': 'Bitte zuerst einloggen',
    'login': 'Anmelden',
    'noFavorites': 'Noch keine Favoriten',
    'tapHeart': 'Tippe das Herz, um Anzeigen zu speichern',
  },
  'fr': {
    'title': 'Favoris',
    'loginRequired': 'Veuillez vous connecter d\'abord',
    'login': 'Connexion',
    'noFavorites': 'Aucun favori pour l\'instant',
    'tapHeart': 'Appuyez sur le cœur pour sauvegarder',
  },
  'sv': {
    'title': 'Favoriter',
    'loginRequired': 'Vänligen logga in först',
    'login': 'Logga in',
    'noFavorites': 'Inga favoriter än',
    'tapHeart': 'Tryck på hjärtat för att spara annonser',
  },
  'uk': {
    'title': 'Обране',
    'loginRequired': 'Будь ласка, увійдіть спочатку',
    'login': 'Увійти',
    'noFavorites': 'Обраних поки немає',
    'tapHeart': 'Натисніть серце, щоб зберегти',
  },
  'tr': {
    'title': 'Favorilerim',
    'loginRequired': 'Lütfen önce giriş yapın',
    'login': 'Giriş yap',
    'noFavorites': 'Henüz favori yok',
    'tapHeart': 'Kaydetmek için kalbe dokunun',
  },
  'ku': {
    'title': 'Bijartîyên min',
    'loginRequired': 'Divê pêşî têkevî',
    'login': 'Têkeve',
    'noFavorites': 'Hîn bijartî tune',
    'tapHeart': 'Ji bo tozekirinê li dil bixin',
  },
  'ckb': {
    'title': 'دڵخوازەکانم',
    'loginRequired': 'پێویستە سەریان بکەیتەوە',
    'login': 'چوونەژوورەوە',
    'noFavorites': 'هێشتا دڵخواز نییە',
    'tapHeart': 'بۆ پاشەکەوتکردن کلیکی دڵ بکە',
  },
};

String _f(String lang, String key) =>
    _favStr[lang]?[key] ?? _favStr['ar']![key] ?? key;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<void> _removeFavorite(String adId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(adId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final l = Localizations.localeOf(context).languageCode;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_forward, size: 24),
                  ),
                  Text(_f(l, 'title'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // ── المحتوى ──
            Expanded(
              child: user == null
                  ? _buildNotLoggedIn(l)
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('favorites')
                          .orderBy('savedAt', descending: true)
                          .snapshots(),
                      builder: (context, favSnap) {
                        if (favSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFFFD600)));
                        }

                        final favDocs = favSnap.data?.docs ?? [];
                        if (favDocs.isEmpty) return _buildEmpty(l);

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: favDocs.length,
                          itemBuilder: (context, index) {
                            final favData =
                                favDocs[index].data() as Map<String, dynamic>;
                            final adId = favDocs[index].id;
                            return _buildFavItem(favData, adId);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(String l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 70, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 12),
          Text(_f(l, 'loginRequired'),
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AuthScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD600),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_f(l, 'login')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String l) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.favorite_border, size: 70, color: Color(0xFF9CA3AF)),
        const SizedBox(height: 12),
        Text(_f(l, 'noFavorites'),
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
        const SizedBox(height: 6),
        Text(_f(l, 'tapHeart'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
      ],
    );
  }

  Widget _buildFavItem(Map<String, dynamic> favData, String adId) {
    final title = favData['title'] ?? '';
    final price = favData['price'] ?? '';
    final city = favData['city'] ?? '';
    final category = favData['category'] ?? '';
    final images = (favData['images'] as List?)?.cast<String>() ?? [];
    final firestoreDocId = favData['adId'] ?? adId;
    final found = CategoryHelper.find(category);

    return GestureDetector(
      onTap: () {
        final ad = AdModel(
          id: 0,
          title: title,
          category: category,
          subCategory: favData['subCategory'] ?? '',
          price: price,
          city: city,
          phone: favData['phone'] ?? '',
          description: favData['description'] ?? '',
          condition: favData['condition'] ?? '',
          date: '',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdDetailScreen(
              ad: ad,
              firestoreData: favData,
              docId: firestoreDocId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(14)),
              child: CachedAdImage(
                url: images.isNotEmpty ? images.first : null,
                category: found,
                height: 90,
                width: 90,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937)),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('$price ل.س',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFD600))),
                    const SizedBox(height: 3),
                    Text('📍 $city',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _removeFavorite(adId),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.favorite, color: Color(0xFFEF4444), size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
