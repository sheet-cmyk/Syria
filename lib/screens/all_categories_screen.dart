import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/data.dart';
import 'sub_category_screen.dart';
import 'ads_list_screen.dart';
import 'professional_profile_screen.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  String _lang = 'ar';

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lang = prefs.getString('app_language') ?? 'ar');
  }

  // ── اسم "جميع الأقسام" حسب اللغة ──
  String get _title {
    const t = {
      'de': 'Alle Kategorien', 'fr': 'Toutes les catégories',
      'sv': 'Alla kategorier', 'uk': 'Всі категорії', 'tr': 'Tüm Kategoriler',
    };
    return t[_lang] ?? 'جميع الأقسام';
  }

  // ── اسم "أضف مهنتك" حسب اللغة ──
  String get _proLabel {
    const t = {
      'de': 'Beruf hinzufügen', 'fr': 'Ajouter votre métier',
      'sv': 'Lägg till yrke',   'uk': 'Додати професію', 'tr': 'Meslek ekle',
    };
    return t[_lang] ?? 'أضف مهنتك';
  }

  // ── "عرض جميع الإعلانات" حسب اللغة ──
  String get _allAdsLabel {
    const t = {
      'de': 'Alle Anzeigen anzeigen', 'fr': 'Voir toutes les annonces',
      'sv': 'Visa alla annonser',     'uk': 'Показати всі оголошення', 'tr': 'Tüm ilanları göster',
    };
    return t[_lang] ?? 'عرض جميع الإعلانات';
  }

  @override
  Widget build(BuildContext context) {
    final allCats = getCategories(_lang);
    // إجمالي العناصر = الأقسام العادية + بطاقة "أضف مهنتك"
    final totalItems = allCats.length + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_forward, size: 24),
              ),
              Text(_title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 24),
            ]),
          ),
          const Divider(height: 1),

          // ── الشبكة ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: totalItems,
                itemBuilder: (context, index) {

                  // ── آخر عنصر: بطاقة "أضف مهنتك" ──
                  if (index == allCats.length) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ProfessionalProfileScreen())),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.badge, color: Colors.white, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            _proLabel,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]),
                      ),
                    );
                  }

                  // ── بقية الأقسام العادية ──
                  final cat = allCats[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SubCategoryScreen(category: cat))),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(cat.icon, color: cat.color, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          cat.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── زر عرض جميع الإعلانات ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdsListScreen(categoryName: 'جميع الإعلانات'))),
                icon: const Icon(Icons.grid_view, color: Colors.white),
                label: Text(_allAdsLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
