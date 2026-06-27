import 'package:flutter/material.dart';
import '../data/data.dart';
import '../models/models.dart';

/// كاش للـ category lookup عبر جميع اللغات.
class CategoryHelper {
  static const _supportedLangs = ['ar', 'de', 'fr', 'sv', 'uk', 'tr'];
  static Map<String, Category>? _cache;

  static Map<String, Category> _buildCache() {
    final map = <String, Category>{};
    for (final lang in _supportedLangs) {
      for (final cat in getCategories(lang)) {
        map[cat.name] = cat;
      }
    }
    return map;
  }

  /// يبحث عن قسم بالاسم في كل اللغات (O(1) بعد الكاش)
  static Category find(String name) {
    _cache ??= _buildCache();
    return _cache![name] ??
        Category(
          name: name,
          icon: Icons.category,
          color: Colors.grey,
          subCategories: [],
        );
  }

  /// يرجع كل أقسام لغة معيّنة (مماثل لـ getCategories من data.dart)
  static List<Category> forLang(String langCode) {
    return getCategories(langCode);
  }

  static IconData icon(String name) => find(name).icon;
  static Color color(String name) => find(name).color;
}
