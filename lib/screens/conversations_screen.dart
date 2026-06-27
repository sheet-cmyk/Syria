import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('الرسائل'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5),
        body: const Center(
            child: Text('سجّل دخولك أولاً',
                style: TextStyle(color: Colors.grey))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('الرسائل',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: me.uid)
            .orderBy('lastTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFFFFD600)));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.chat_bubble_outline,
                  color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 12),
              const Text('لا توجد محادثات بعد',
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
              const SizedBox(height: 6),
              const Text('أضف أصدقاء وابدأ المراسلة',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ]));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final names =
                  data['names'] as Map<String, dynamic>? ?? {};
              final photos =
                  data['photos'] as Map<String, dynamic>? ?? {};
              final lastMsg    = data['lastMessage'] ?? '';
              final lastSender = data['lastSenderId'] ?? '';
              final unreadCounts =
                  data['unreadCounts'] as Map<String, dynamic>? ?? {};
              final unread =
                  (unreadCounts[me.uid] as num?)?.toInt() ?? 0;

              final participants =
                  List<String>.from(data['participants'] ?? []);
              final otherId = participants.firstWhere(
                  (id) => id != me.uid,
                  orElse: () => '');
              final otherName  = names[otherId]  ?? 'مجهول';
              final otherPhoto = photos[otherId] ?? '';
              final isMe       = lastSender == me.uid;

              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatScreen(
                              friendId:    otherId,
                              friendName:  otherName,
                              friendPhoto: otherPhoto,
                            ))),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: unread > 0
                        ? const Color(0xFFEEF2FF) // خلفية مميزة للمحادثات غير المقروءة
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 6)
                    ],
                  ),
                  child: Row(children: [
                    // ── سهم التنقل ──
                    const Icon(Icons.arrow_back_ios,
                        color: Color(0xFF3B5BDB), size: 16),
                    const Spacer(),

                    // ── اسم + آخر رسالة ──
                    Expanded(
                      flex: 6,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(otherName,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: unread > 0
                                        ? FontWeight.w800
                                        : FontWeight.bold,
                                    color: const Color(0xFF1F2937))),
                            const SizedBox(height: 3),
                            Text(
                              isMe ? 'أنت: $lastMsg' : lastMsg,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: unread > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: unread > 0
                                      ? const Color(0xFF3B5BDB)
                                      : Colors.grey.shade500,
                                  overflow: TextOverflow.ellipsis),
                              maxLines: 1,
                              textAlign: TextAlign.right,
                            ),
                          ]),
                    ),
                    const SizedBox(width: 12),

                    // ── صورة + شارة العدد ──
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              const Color(0xFFFFD600).withValues(alpha:0.3),
                          child: otherPhoto.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: otherPhoto,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Text(
                                      otherName.isNotEmpty
                                          ? otherName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    errorWidget: (_, __, ___) => Text(
                                      otherName.isNotEmpty
                                          ? otherName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                )
                              : Text(
                                  otherName.isNotEmpty
                                      ? otherName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                        ),

                        // شارة عدد الرسائل غير المقروءة
                        if (unread > 0)
                          Positioned(
                            top: -4,
                            left: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE53E3E),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
