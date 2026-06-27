import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../utils/category_helper.dart'; // ✅ جديد
import '../widgets/cached_ad_image.dart'; // ✅ جديد
import 'ad_detail_screen.dart';

class AdsListScreen extends StatefulWidget {
  final String categoryName;
  final String? subCategoryName;
  final String? searchQuery;
  final String? filterCity;

  const AdsListScreen({
    super.key,
    required this.categoryName,
    this.subCategoryName,
    this.searchQuery,
    this.filterCity,
  });

  @override
  State<AdsListScreen> createState() => _AdsListScreenState();
}

class _AdsListScreenState extends State<AdsListScreen> {
  // ── بناء الـ query حسب الفلتر ──
  Query<Map<String, dynamic>> get _query {
    Query<Map<String, dynamic>> q =
        FirebaseFirestore.instance.collection('ads');

    if (widget.categoryName != 'جميع الإعلانات' && widget.searchQuery == null) {
      q = q.where('category', isEqualTo: widget.categoryName);
      if (widget.subCategoryName != null) {
        q = q.where('subCategory', isEqualTo: widget.subCategoryName);
      }
    }
    q = q.orderBy('createdAt', descending: true);
    // ✅ D1: إضافة limit لمنع سحب آلاف الإعلانات دفعة واحدة
    q = q.limit(100);
    return q;
  }

  // ── فلترة نتائج البحث محلياً ──
  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    var result = docs;
    if (widget.filterCity != null && widget.filterCity!.isNotEmpty) {
      final fc = widget.filterCity!.toLowerCase();
      result = result.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final city = (data['city'] ?? '').toString().toLowerCase();
        return city.contains(fc) || fc.contains(city);
      }).toList();
    }
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      final q = widget.searchQuery!.toLowerCase();
      result = result.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '').toString().toLowerCase();
        final desc = (data['description'] ?? '').toString().toLowerCase();
        final cat = (data['category'] ?? '').toString().toLowerCase();
        final city = (data['city'] ?? '').toString().toLowerCase();
        return title.contains(q) ||
            desc.contains(q) ||
            cat.contains(q) ||
            city.contains(q);
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.searchQuery != null
        ? 'نتائج: ${widget.searchQuery}'
        : widget.subCategoryName ?? widget.categoryName;

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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),

            // ── القائمة من Firestore ──
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFFFD600)));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('خطأ: ${snapshot.error}',
                            textAlign: TextAlign.center));
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final docs = _filterDocs(allDocs);

                  if (docs.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 70, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 12),
                        Text(
                          widget.searchQuery != null
                              ? 'لا توجد نتائج لـ "${widget.searchQuery}"'
                              : 'لا توجد إعلانات في هذا القسم',
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      // عداد النتائج
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${docs.length} إعلان',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final category = data['category'] ?? '';
                            final images =
                                (data['images'] as List?)?.cast<String>() ?? [];
                            final createdAt = data['createdAt'] as Timestamp?;
                            final date = createdAt != null
                                ? _formatDate(createdAt.toDate())
                                : '';

                            final rawPrice = data['price'] ?? '';
                            final isSpecialPrice =
                                data['isSpecialPrice'] == true ||
                                    rawPrice == 'سعر خاص';
                            final currency = data['currency'] ?? 'SYP';
                            final priceStr = isSpecialPrice
                                ? 'سعر خاص'
                                : (currency == 'USD'
                                    ? '\$$rawPrice'
                                    : '$rawPrice ل.س');

                            // ✅ A1: CategoryHelper بدلاً من firstWhere مكرر
                            final found = CategoryHelper.find(category);

                            return GestureDetector(
                              onTap: () {
                                final ad = AdModel(
                                  id: index,
                                  title: data['title'] ?? '',
                                  category: data['category'] ?? '',
                                  subCategory: data['subCategory'] ?? '',
                                  price: isSpecialPrice ? 'سعر خاص' : rawPrice,
                                  city: data['city'] ?? '',
                                  phone: data['phone'] ?? '',
                                  description: data['description'] ?? '',
                                  condition: data['condition'] ?? '',
                                  date: date,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AdDetailScreen(
                                            ad: ad,
                                            firestoreData: data,
                                            docId: doc.id,
                                          )),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 6)
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // ✅ A4: CachedAdImage بدلاً من Image.network
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                              right: Radius.circular(14)),
                                      child: CachedAdImage(
                                        url: images.isNotEmpty
                                            ? images.first
                                            : null,
                                        category: found,
                                        height: 90,
                                        width: 90,
                                      ),
                                    ),

                                    // التفاصيل
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              data['title'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937)),
                                              textAlign: TextAlign.right,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              priceStr,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFFFD600)),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text('📍 ${data['city'] ?? ''}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF6B7280))),
                                                const SizedBox(width: 8),
                                                Text(date,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Color(0xFF9CA3AF))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
    return '${date.day}/${date.month}/${date.year}';
  }
}
