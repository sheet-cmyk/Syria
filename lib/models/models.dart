import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  final List<SubCategory> subCategories;
  final bool isProfessional; // ✅ مضاف

  const Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.subCategories,
    this.isProfessional = false, // ✅ افتراضي false
  });
}

class SubCategory {
  final String name;
  final IconData icon;
  final Color color;

  const SubCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AdModel {
  final int id;
  final String title;
  final String category;
  final String subCategory;
  final String price;
  final String city;
  final String phone;
  final String description;
  final String condition;
  final String date;
  final double? latitude;
  final double? longitude;
  bool isMyAd;
  bool isFavorite;

  AdModel({
    required this.id,
    required this.title,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.city,
    required this.phone,
    required this.description,
    required this.condition,
    required this.date,
    this.latitude,
    this.longitude,
    this.isMyAd = false,
    this.isFavorite = false,
  });
}
