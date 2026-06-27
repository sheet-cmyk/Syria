import 'package:flutter/material.dart';
import '../models/models.dart';
import 'ads_list_screen.dart';

class SubCategoryScreen extends StatelessWidget {
  final Category category;
  const SubCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_forward, size: 24),
                  ),
                  Text(
                    'اختر من ${category.name}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: category.subCategories.isEmpty
                  ? const Center(
                      child: Text('لا توجد أقسام فرعية',
                          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: category.subCategories.length,
                        itemBuilder: (context, index) {
                          final sub = category.subCategories[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdsListScreen(
                                  categoryName: category.name,
                                  subCategoryName: sub.name,
                                ),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(sub.icon, color: sub.color, size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    sub.name,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
