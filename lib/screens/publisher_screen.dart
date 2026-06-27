import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'ad_detail_screen.dart';
import 'chat_screen.dart';

class PublisherScreen extends StatefulWidget {
  final String publisherId;
  final String publisherName;
  final String publisherPhoto;

  const PublisherScreen({
    super.key,
    required this.publisherId,
    required this.publisherName,
    required this.publisherPhoto,
  });

  @override
  State<PublisherScreen> createState() => _PublisherScreenState();
}

class _PublisherScreenState extends State<PublisherScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isFriend = false;
  bool _loadingFriend = false;
  int _friendsCount = 0;
  int _followersCount = 0;
  int _adsCount = 0;
  Map<String, dynamic> _publisherData = {};

  @override
  void initState() {
    super.initState();
    _loadPublisherData();
    _checkFriendship();
  }

  Future<void> _loadPublisherData() async {
    try {
      final doc = await _db.collection('users').doc(widget.publisherId).get();
      if (doc.exists && mounted) {
        setState(() => _publisherData = doc.data() ?? {});
      }
      final ads = await _db
          .collection('ads')
          .where('userId', isEqualTo: widget.publisherId)
          .get();
      final friends = await _db
          .collection('users')
          .doc(widget.publisherId)
          .collection('friends')
          .get();
      final followers = await _db
          .collection('users')
          .doc(widget.publisherId)
          .collection('followers')
          .get();
      if (mounted) {
        setState(() {
          _adsCount =
              ads.docs.where((d) => d.data()['status'] != 'deleted').length;
          _friendsCount = friends.size;
          _followersCount = followers.size;
        });
      }
    } catch (_) {}
  }

  Future<void> _checkFriendship() async {
    final me = _auth.currentUser;
    if (me == null) return;
    try {
      final doc = await _db
          .collection('users')
          .doc(me.uid)
          .collection('friends')
          .doc(widget.publisherId)
          .get();
      if (mounted) setState(() => _isFriend = doc.exists);
    } catch (_) {}
  }

  Future<void> _toggleFriend() async {
    final me = _auth.currentUser;
    if (me == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      return;
    }
    if (me.uid == widget.publisherId) return;
    setState(() => _loadingFriend = true);
    try {
      final myFriendRef = _db
          .collection('users')
          .doc(me.uid)
          .collection('friends')
          .doc(widget.publisherId);
      final theirFollowerRef = _db
          .collection('users')
          .doc(widget.publisherId)
          .collection('followers')
          .doc(me.uid);
      if (_isFriend) {
        await myFriendRef.delete();
        await theirFollowerRef.delete();
        setState(() {
          _isFriend = false;
          _friendsCount = (_friendsCount - 1).clamp(0, 9999);
          _followersCount = (_followersCount - 1).clamp(0, 9999);
        });
      } else {
        final meData = await _db.collection('users').doc(me.uid).get();
        await myFriendRef.set({
          'userId': widget.publisherId,
          'name': widget.publisherName,
          'photoUrl': widget.publisherPhoto,
          'addedAt': FieldValue.serverTimestamp(),
        });
        await theirFollowerRef.set({
          'userId': me.uid,
          'name': meData.data()?['name'] ?? me.displayName ?? '',
          'photoUrl': me.photoURL ?? '',
          'addedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isFriend = true;
          _friendsCount++;
          _followersCount++;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    }
    setState(() => _loadingFriend = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = _auth.currentUser;
    final isMyProfile = me?.uid == widget.publisherId;
    final photoUrl = widget.publisherPhoto;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(children: [
            // AppBar
            SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_forward, size: 24)),
                const Spacer(),
                Text(widget.publisherName,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                const SizedBox(width: 24),
              ]),
            )),

            // صورة
            const SizedBox(height: 8),
            Stack(alignment: Alignment.center, children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFFFD600).withOpacity(0.3),
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? Text(
                        widget.publisherName.isNotEmpty
                            ? widget.publisherName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold))
                    : null,
              ),
              Positioned(
                  bottom: 2,
                  right: 0,
                  child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)))),
            ]),
            const SizedBox(height: 10),
            Text(widget.publisherName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if ((_publisherData['email'] ?? '').isNotEmpty)
              Text(_publisherData['email'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),

            // إحصائيات
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _statItem('$_adsCount', 'إعلان'),
              _divider(),
              _statItem('$_friendsCount', 'صديق'),
              _divider(),
              _statItem('$_followersCount', 'متابع'),
            ]),
            const SizedBox(height: 16),

            // ── أزرار إضافة/إزالة صديق + مراسلة ──
            if (!isMyProfile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  // زر مراسلة (يظهر فقط إذا كانا أصدقاء)
                  if (_isFriend) ...[
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                        friendId: widget.publisherId,
                                        friendName: widget.publisherName,
                                        friendPhoto: widget.publisherPhoto,
                                      ))),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('مراسلة',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B5BDB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  // زر إضافة/إزالة صديق
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _loadingFriend ? null : _toggleFriend,
                        icon: _loadingFriend
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : Icon(
                                _isFriend
                                    ? Icons.person_remove_outlined
                                    : Icons.person_add_outlined,
                                size: 18),
                        label: Text(
                          _isFriend ? 'إزالة صديق' : 'إضافة صديق',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFriend
                              ? Colors.red.shade400
                              : const Color(0xFFFFD600),
                          foregroundColor:
                              _isFriend ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

            const SizedBox(height: 16),
            const Divider(height: 1),
          ]),
        )),

        // قائمة الإعلانات
        StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('ads')
              .where('userId', isEqualTo: widget.publisherId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFFD600)))));
            }
            final docs = (snapshot.data?.docs ?? [])
                .where((d) => (d.data() as Map)['status'] != 'deleted')
                .toList();
            if (docs.isEmpty) {
              return const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: Text('لا توجد إعلانات',
                              style: TextStyle(color: Colors.grey)))));
            }
            return SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final images =
                      (data['images'] as List?)?.cast<String>() ?? [];
                  final category = data['category'] ?? '';
                  Category found = Category(
                      name: category,
                      icon: Icons.category,
                      color: Colors.grey,
                      subCategories: []);
                  for (final lang in ['ar', 'de', 'fr', 'sv', 'uk', 'tr']) {
                    final match = getCategories(lang)
                        .where((c) => c.name == category)
                        .toList();
                    if (match.isNotEmpty) {
                      found = match.first;
                      break;
                    }
                  }
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
                              child: images.isNotEmpty
                                  ? Image.network(images.first,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _iconBox(found, 120))
                                  : _iconBox(found, 120),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(data['title'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1F2937)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right),
                                      const SizedBox(height: 3),
                                      Text('${data['price'] ?? ''} ل.س',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFFFD600))),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Flexible(
                                                child: Text(data['city'] ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xFF6B7280)),
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            const SizedBox(width: 2),
                                            const Text('📍',
                                                style: TextStyle(fontSize: 10)),
                                          ]),
                                    ])),
                          ]),
                    ),
                  );
                }, childCount: docs.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ]),
    );
  }

  Widget _statItem(String value, String label) => Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]);

  Widget _divider() =>
      Container(width: 1, height: 36, color: Colors.grey.shade200);

  Widget _iconBox(Category cat, double height) => Container(
      height: height,
      width: double.infinity,
      color: cat.color.withOpacity(0.12),
      child: Icon(cat.icon, color: cat.color, size: 32));
}
