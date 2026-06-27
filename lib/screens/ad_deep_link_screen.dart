import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'ad_detail_screen.dart';

class AdDeepLinkScreen extends StatefulWidget {
  final String docId;
  const AdDeepLinkScreen({super.key, required this.docId});

  @override
  State<AdDeepLinkScreen> createState() => _AdDeepLinkScreenState();
}

class _AdDeepLinkScreenState extends State<AdDeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('ads')
          .doc(widget.docId)
          .get();
      if (!mounted) return;
      if (!doc.exists) {
        Navigator.pop(context);
        return;
      }
      final data = doc.data()!;
      final ad = AdModel(
        id: 0,
        title: data['title'] ?? '',
        category: data['category'] ?? '',
        subCategory: data['subCategory'] ?? '',
        price: data['price'] ?? '',
        city: data['city'] ?? '',
        phone: data['phone'] ?? '',
        description: data['description'] ?? '',
        condition: data['condition'] ?? '',
        date: '',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdDetailScreen(ad: ad, firestoreData: data, docId: widget.docId),
        ),
      );
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
