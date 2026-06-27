import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'publisher_screen.dart';

const Map<String, Map<String, String>> _str = {
  'ar': {
    'title':       'متابعين',
    'noFriends':   'لا يوجد متابَعون بعد',
    'friend':      'متابَع',
    'user':        'مستخدم',
    'search':      'بحث في المتابعين...',
    'noResults':   'لا توجد نتائج',
    'deleteTitle': 'حذف',
    'deleteMsg':   'هل تريد إزالة',
    'deleteMsg2':  'من قائمة متابعيك؟',
    'cancel':      'إلغاء',
    'delete':      'حذف',
  },
  'en': {
    'title':       'Following',
    'noFriends':   'Not following anyone yet',
    'friend':      'Following',
    'user':        'User',
    'search':      'Search...',
    'noResults':   'No results',
    'deleteTitle': 'Remove',
    'deleteMsg':   'Remove',
    'deleteMsg2':  'from your following list?',
    'cancel':      'Cancel',
    'delete':      'Remove',
  },
  'de': {
    'title':       'Abonniert',
    'noFriends':   'Noch niemanden abonniert',
    'friend':      'Abonniert',
    'user':        'Benutzer',
    'search':      'Suchen...',
    'noResults':   'Keine Ergebnisse',
    'deleteTitle': 'Entfernen',
    'deleteMsg':   'Entfernen von',
    'deleteMsg2':  'aus deiner Liste?',
    'cancel':      'Abbrechen',
    'delete':      'Entfernen',
  },
  'fr': {
    'title':       'Abonnements',
    'noFriends':   'Pas encore d\'abonnements',
    'friend':      'Abonnement',
    'user':        'Utilisateur',
    'search':      'Rechercher...',
    'noResults':   'Aucun résultat',
    'deleteTitle': 'Supprimer',
    'deleteMsg':   'Supprimer',
    'deleteMsg2':  'de votre liste?',
    'cancel':      'Annuler',
    'delete':      'Supprimer',
  },
  'sv': {
    'title':       'Följer',
    'noFriends':   'Följer ingen ännu',
    'friend':      'Följer',
    'user':        'Användare',
    'search':      'Sök...',
    'noResults':   'Inga resultat',
    'deleteTitle': 'Ta bort',
    'deleteMsg':   'Ta bort',
    'deleteMsg2':  'från din lista?',
    'cancel':      'Avbryt',
    'delete':      'Ta bort',
  },
  'uk': {
    'title':       'Підписки',
    'noFriends':   'Підписок поки немає',
    'friend':      'Підписка',
    'user':        'Користувач',
    'search':      'Пошук...',
    'noResults':   'Немає результатів',
    'deleteTitle': 'Видалити',
    'deleteMsg':   'Видалити',
    'deleteMsg2':  'зі списку?',
    'cancel':      'Скасувати',
    'delete':      'Видалити',
  },
  'tr': {
    'title':       'Takip Edilenler',
    'noFriends':   'Henüz takip edilen yok',
    'friend':      'Takip edilen',
    'user':        'Kullanıcı',
    'search':      'Ara...',
    'noResults':   'Sonuç yok',
    'deleteTitle': 'Kaldır',
    'deleteMsg':   'Kaldır',
    'deleteMsg2':  'listenizden?',
    'cancel':      'İptal',
    'delete':      'Kaldır',
  },
  'ku': {
    'title':       'Tê şopandin',
    'noFriends':   'Hîn kesek nayê şopandin',
    'friend':      'Tê şopandin',
    'user':        'Bikarhêner',
    'search':      'Lêgerîn...',
    'noResults':   'Encam tune',
    'deleteTitle': 'Jêbirin',
    'deleteMsg':   'Jêbirin',
    'deleteMsg2':  'ji lîsteya te?',
    'cancel':      'Betal bike',
    'delete':      'Jêbirin',
  },
  'ckb': {
    'title':       'شوێنکەوتووی',
    'noFriends':   'هێشتا کەس شوێن نەکەوتووە',
    'friend':      'شوێنکەوتووی',
    'user':        'بەکارهێنەر',
    'search':      'گەڕان...',
    'noResults':   'ئەنجام نەدۆزرایەوە',
    'deleteTitle': 'سڕینەوە',
    'deleteMsg':   'سڕینەوەی',
    'deleteMsg2':  'لە لیستەکەت؟',
    'cancel':      'پاشگەزبوونەوە',
    'delete':      'سڕینەوە',
  },
};

String _t(String lang, String key) =>
    _str[lang]?[key] ?? _str['ar']![key] ?? key;

class FriendsScreen extends StatefulWidget {
  final String userId;
  const FriendsScreen({super.key, required this.userId});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _db         = FirebaseFirestore.instance;
  final _searchCtrl = TextEditingController();
  String _query     = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
      BuildContext ctx, String docId, String uid, String name, String l) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(_t(l, 'deleteTitle'), textAlign: TextAlign.right),
        content: Text(
          '${_t(l, 'deleteMsg')} $name ${_t(l, 'deleteMsg2')}',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(_t(l, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(_t(l, 'delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    // حذف من قائمة friends الخاصة بالمستخدم الحالي
    await _db
        .collection('users')
        .doc(widget.userId)
        .collection('friends')
        .doc(docId)
        .delete();

    // حذف من قائمة followers الخاصة بالطرف الآخر
    if (uid.isNotEmpty) {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('followers')
          .where('userId', isEqualTo: widget.userId)
          .get();
      for (final d in snap.docs) {
        await d.reference.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l   = Localizations.localeOf(context).languageCode;
    final myId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(_t(l, 'title'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── شريط البحث الذكي ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: _t(l, 'search'),
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF3B5BDB)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Color(0xFF9CA3AF), size: 20),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFF3B5BDB), width: 1.5),
                ),
              ),
            ),
          ),

          // ── القائمة ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('users')
                  .doc(widget.userId)
                  .collection('friends')
                  .orderBy('addedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFFD600)));
                }

                final allDocs = snapshot.data?.docs ?? [];
                final docs = _query.isEmpty
                    ? allDocs
                    : allDocs.where((d) {
                        final data =
                            d.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] ?? '').toString().toLowerCase();
                        return name.contains(_query);
                      }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            color: Colors.grey.shade300, size: 64),
                        const SizedBox(height: 12),
                        Text(
                          _query.isNotEmpty
                              ? _t(l, 'noResults')
                              : _t(l, 'noFriends'),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc  = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final uid      = data['userId']   ?? '';
                    final name     = data['name']     ?? '';
                    final photoUrl = data['photoUrl'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        if (uid.isEmpty) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PublisherScreen(
                              publisherId:    uid,
                              publisherName:  name,
                              publisherPhoto: photoUrl,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            // زر الحذف
                            GestureDetector(
                              onTap: () => _confirmDelete(
                                  context, doc.id, uid, name, l),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_back_ios,
                                color: Color(0xFF3B5BDB), size: 16),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : _t(l, 'user'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _t(l, 'friend'),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  backgroundColor: const Color(0xFFFFD600)
                                      .withValues(alpha: 0.3),
                                  child: photoUrl.isEmpty
                                      ? Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                                if (myId.isNotEmpty && uid.isNotEmpty)
                                  Positioned(
                                    top: -6,
                                    left: -6,
                                    child: _UnreadBadge(
                                        myId: myId, otherId: uid),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── يعرض عدد الرسائل غير المقروءة من شخص معين ──
class _UnreadBadge extends StatelessWidget {
  final String myId;
  final String otherId;

  const _UnreadBadge({required this.myId, required this.otherId});

  String get _chatId {
    final ids = [myId, otherId]..sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox.shrink();
        final data   = snap.data!.data() as Map<String, dynamic>?;
        final counts = data?['unreadCounts'] as Map<String, dynamic>? ?? {};
        final count  = (counts[myId] as num?)?.toInt() ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          child: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
