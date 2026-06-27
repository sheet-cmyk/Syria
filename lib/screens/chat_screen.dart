import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String friendPhoto;

  const ChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.friendPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _db         = FirebaseFirestore.instance;
  final _auth       = FirebaseAuth.instance;

  bool _isFriend        = false;
  bool _iBlockedThem    = false;
  bool _isBlockedByThem = false;
  bool _sending         = false;
  bool _isTyping        = false;
  int  _myMessageCount  = 0;

  StreamSubscription? _typingSub;
  Timer? _typingDebounce;
  bool  _lastTypingSent    = false;
  String? _lastMarkedReadIds;

  static const int _maxNonFriendMessages = 5;

  String get _chatId {
    final me = _auth.currentUser!.uid;
    final ids = [me, widget.friendId]..sort();
    return ids.join('_');
  }

  bool get _canSend {
    if (_iBlockedThem || _isBlockedByThem) return false;
    if (!_isFriend && _myMessageCount >= _maxNonFriendMessages) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _checkFriendship();
    _checkBlocks();
    _markMessagesRead();
    _listenTyping();
    _msgCtrl.addListener(_onTyping);
  }

  @override
  void dispose() {
    _msgCtrl.removeListener(_onTyping);
    _typingDebounce?.cancel();
    _typingSub?.cancel();
    if (_lastTypingSent) _setTyping(false);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTyping() {
    final typing = _msgCtrl.text.isNotEmpty;
    if (typing == _lastTypingSent) return;
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 400), () {
      _setTyping(typing);
      _lastTypingSent = typing;
    });
  }

  Future<void> _setTyping(bool val) async {
    final me = _auth.currentUser;
    if (me == null) return;
    try {
      await _db.collection('chats').doc(_chatId).set(
          {'typing': {me.uid: val}}, SetOptions(merge: true));
    } catch (_) {}
  }

  void _listenTyping() {
    _typingSub =
        _db.collection('chats').doc(_chatId).snapshots().listen((snap) {
      if (!mounted) return;
      final data   = snap.data() ?? {};
      final typing = data['typing'] as Map<String, dynamic>? ?? {};
      final newTyping = typing[widget.friendId] == true;
      if (newTyping != _isTyping) setState(() => _isTyping = newTyping);
    });
  }

  Future<void> _checkFriendship() async {
    final me = _auth.currentUser;
    if (me == null) return;
    try {
      final doc = await _db
          .collection('users')
          .doc(me.uid)
          .collection('friends')
          .doc(widget.friendId)
          .get();
      if (mounted) setState(() => _isFriend = doc.exists);
    } catch (_) {}
  }

  Future<void> _checkBlocks() async {
    final me = _auth.currentUser;
    if (me == null) return;
    try {
      final myBlock   = await _db
          .collection('users').doc(me.uid)
          .collection('blocked').doc(widget.friendId).get();
      final theirBlock = await _db
          .collection('users').doc(widget.friendId)
          .collection('blocked').doc(me.uid).get();
      if (mounted) {
        setState(() {
          _iBlockedThem    = myBlock.exists;
          _isBlockedByThem = theirBlock.exists;
        });
      }
    } catch (_) {}
  }

  Future<void> _blockUser() async {
    final me = _auth.currentUser;
    if (me == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حجب المستخدم', textAlign: TextAlign.right),
        content: Text(
          'هل تريد حجب ${widget.friendName}؟\nلن يتمكن من مراسلتك.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(_, true),
              child: const Text('حجب', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _db
          .collection('users').doc(me.uid)
          .collection('blocked').doc(widget.friendId)
          .set({'blockedAt': FieldValue.serverTimestamp()});
      if (mounted) setState(() => _iBlockedThem = true);
    } catch (_) {}
  }

  Future<void> _unblockUser() async {
    final me = _auth.currentUser;
    if (me == null) return;
    try {
      await _db
          .collection('users').doc(me.uid)
          .collection('blocked').doc(widget.friendId)
          .delete();
      if (mounted) setState(() => _iBlockedThem = false);
    } catch (_) {}
  }

  Future<void> _markMessagesReadIfNeeded(
      List<QueryDocumentSnapshot> docs) async {
    final me = _auth.currentUser;
    if (me == null) return;
    final unreadIds = <String>[];
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['senderId'] != me.uid && data['read'] != true) {
        unreadIds.add(doc.id);
      }
    }
    if (unreadIds.isEmpty) return;
    final fingerprint = unreadIds.join(',');
    if (fingerprint == _lastMarkedReadIds) return;
    _lastMarkedReadIds = fingerprint;
    try {
      final chatRef = _db.collection('chats').doc(_chatId);
      final batch   = _db.batch();
      final col     = chatRef.collection('messages');
      for (final id in unreadIds) {
        batch.update(col.doc(id), {'read': true});
      }
      await batch.commit();
      await chatRef.update({'unreadCounts.${me.uid}': 0});
    } catch (_) {}
  }

  Future<void> _markMessagesRead() async {
    final me = _auth.currentUser;
    if (me == null) return;
    try {
      final chatRef = _db.collection('chats').doc(_chatId);
      final unread  = await chatRef
          .collection('messages')
          .where('senderId', isNotEqualTo: me.uid)
          .where('read', isEqualTo: false)
          .get();
      if (unread.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in unread.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      }
      await chatRef.update({'unreadCounts.${me.uid}': 0});
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || !_canSend || _sending) return;
    final me = _auth.currentUser;
    if (me == null) return;

    setState(() => _sending = true);
    _msgCtrl.clear();
    _setTyping(false);
    _lastTypingSent = false;

    try {
      final chatRef = _db.collection('chats').doc(_chatId);
      final batch   = _db.batch();
      batch.set(
          chatRef,
          {
            'participants': [me.uid, widget.friendId],
            'lastMessage':  text,
            'lastSenderId': me.uid,
            'lastTime':     FieldValue.serverTimestamp(),
            'names':  {me.uid: me.displayName ?? '', widget.friendId: widget.friendName},
            'photos': {me.uid: me.photoURL ?? '',    widget.friendId: widget.friendPhoto},
          },
          SetOptions(merge: true));
      batch.set(chatRef.collection('messages').doc(), {
        'text':          text,
        'senderId':      me.uid,
        'senderName':    me.displayName ?? '',
        'createdAt':     FieldValue.serverTimestamp(),
        'isLink':        _isLink(text),
        'read':          false,
        'deletedFor':    [],
        'deletedForAll': false,
      });
      await batch.commit();

      unawaited(chatRef.update(
          {'unreadCounts.${widget.friendId}': FieldValue.increment(1)}));
      unawaited(NotificationService.sendMessageNotification(
        toUserId: widget.friendId,
        fromName: me.displayName ?? 'مستخدم',
        message:  text,
      ));

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut);
        }
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteMessageForMe(String docId) async {
    final me = _auth.currentUser;
    if (me == null) return;
    try {
      await _db
          .collection('chats').doc(_chatId)
          .collection('messages').doc(docId)
          .update({'deletedFor': FieldValue.arrayUnion([me.uid])});
    } catch (_) {}
  }

  Future<void> _deleteMessageForAll(String docId) async {
    try {
      await _db
          .collection('chats').doc(_chatId)
          .collection('messages').doc(docId)
          .update({
        'deletedForAll': true,
        'text':          'تم حذف هذه الرسالة',
      });
    } catch (_) {}
  }

  void _showMessageOptions(
      BuildContext ctx, String docId, String text, bool isMe) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFF3B5BDB)),
              title: const Text('نسخ الرسالة', textAlign: TextAlign.right),
              onTap: () {
                Navigator.pop(sheet);
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(ctx)
                    .showSnackBar(const SnackBar(content: Text('تم النسخ')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: const Text('حذف لي فقط',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(sheet);
                _deleteMessageForMe(docId);
              },
            ),
            if (isMe)
              ListTile(
                leading:
                    const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('حذف للجميع',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(sheet);
                  _deleteMessageForAll(docId);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool _isLink(String text) =>
      text.startsWith('http://') ||
      text.startsWith('https://') ||
      text.startsWith('www.');

  String _extractLink(String text) {
    final uri = RegExp(r'https?://\S+|www\.\S+').firstMatch(text);
    return uri?.group(0) ?? '';
  }

  Future<void> _openLink(String url) async {
    String clean = url.trim();
    if (!clean.startsWith('http')) clean = 'https://$clean';
    try {
      await launchUrl(Uri.parse(clean), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  String _formatFullDateTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as dynamic).toDate() as DateTime;
      const days = [
        'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء',
        'الخميس', 'الجمعة', 'السبت'
      ];
      final dayName = days[dt.weekday % 7];
      final day  = dt.day.toString().padLeft(2, '0');
      final mon  = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final h    = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m    = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$dayName $day-$mon-$year $h:$m $ampm';
    } catch (_) {
      return '';
    }
  }

  String get _inputHint {
    if (_isBlockedByThem) return 'لا يمكنك مراسلة هذا المستخدم';
    if (_iBlockedThem)    return 'لقد قمت بحجب هذا المستخدم';
    if (!_isFriend && _myMessageCount >= _maxNonFriendMessages) {
      return 'بلغت الحد الأقصى (5 رسائل) بدون صداقة';
    }
    if (!_isFriend) {
      final remaining = _maxNonFriendMessages - _myMessageCount;
      return 'اكتب رسالة... ($remaining رسائل متبقية)';
    }
    return 'اكتب رسالة أو رابط...';
  }

  @override
  Widget build(BuildContext context) {
    final me = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.friendPhoto.isNotEmpty
                ? NetworkImage(widget.friendPhoto)
                : null,
            backgroundColor:
                const Color(0xFFFFD600).withValues(alpha: 0.3),
            child: widget.friendPhoto.isEmpty
                ? Text(
                    widget.friendName.isNotEmpty
                        ? widget.friendName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text(widget.friendName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
                if (_isTyping)
                  const Text('جاري الكتابة...',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3B5BDB),
                          fontStyle: FontStyle.italic)),
              ])),
        ]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'block')   _blockUser();
              if (val == 'unblock') _unblockUser();
            },
            itemBuilder: (_) => _iBlockedThem
                ? [
                    const PopupMenuItem(
                      value: 'unblock',
                      child: Text('إلغاء الحجب', textAlign: TextAlign.right),
                    ),
                  ]
                : [
                    const PopupMenuItem(
                      value: 'block',
                      child: Text('حجب المستخدم',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
          ),
        ],
      ),
      body: Column(children: [
        // ── شريط الحالة العلوي ──
        if (_isBlockedByThem)
          _StatusBanner(
            color: Colors.red.shade50,
            text: 'لا يمكنك مراسلة هذا المستخدم',
            textColor: Colors.red,
          )
        else if (_iBlockedThem)
          _StatusBanner(
            color: Colors.red.shade50,
            text: 'لقد قمت بحجب هذا المستخدم',
            textColor: Colors.red,
            action: TextButton(
              onPressed: _unblockUser,
              child: const Text('إلغاء الحجب',
                  style: TextStyle(color: Color(0xFF3B5BDB))),
            ),
          )
        else if (!_isFriend)
          _StatusBanner(
            color: Colors.orange.shade50,
            text: _myMessageCount >= _maxNonFriendMessages
                ? 'بلغت الحد الأقصى من الرسائل بدون صداقة (5 رسائل)'
                : 'يمكنك إرسال ${_maxNonFriendMessages - _myMessageCount} رسائل بدون صداقة',
            textColor: Colors.orange,
          ),

        // ── قائمة الرسائل ──
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('chats')
                .doc(_chatId)
                .collection('messages')
                .orderBy('createdAt', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFFFD600)));
              }
              final allDocs = snapshot.data?.docs ?? [];

              // تحديث عدد رسائلي (بعد الـ frame لتجنب setState أثناء build)
              final myCount = allDocs
                  .where((d) =>
                      (d.data() as Map<String, dynamic>)['senderId'] ==
                      me?.uid)
                  .length;
              if (myCount != _myMessageCount) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _myMessageCount = myCount);
                });
              }

              // تصفية الرسائل المحذوفة لي
              final docs = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['deletedForAll'] == true) return true;
                final deletedFor =
                    List<String>.from(data['deletedFor'] ?? []);
                return !deletedFor.contains(me?.uid);
              }).toList();

              if (docs.isEmpty) {
                return const Center(
                    child: Text('لا توجد رسائل بعد',
                        style: TextStyle(color: Colors.grey)));
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _markMessagesReadIfNeeded(allDocs);
              });

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: docs.length,
                cacheExtent: 500,
                itemBuilder: (context, index) {
                  final doc  = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isMe = data['senderId'] == me?.uid;
                  final isDeletedForAll = data['deletedForAll'] == true;
                  return _MessageBubble(
                    data:            data,
                    isMe:            isMe,
                    isDeletedForAll: isDeletedForAll,
                    fullDate:        _formatFullDateTime(data['createdAt']),
                    extractLink:     _extractLink,
                    openLink:        _openLink,
                    onLongPress:     isDeletedForAll
                        ? null
                        : () => _showMessageOptions(
                            context, doc.id, data['text'] ?? '', isMe),
                  );
                },
              );
            },
          ),
        ),

        // ── حقل الإرسال ──
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            GestureDetector(
              onTap: (_canSend && !_sending) ? _sendMessage : null,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _canSend
                      ? const Color(0xFF3B5BDB)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller:    _msgCtrl,
                textDirection: TextDirection.rtl,
                textAlign:     TextAlign.right,
                maxLines:      4,
                minLines:      1,
                enabled:       _canSend,
                onSubmitted:   (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: _inputHint,
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400, fontSize: 14),
                  filled:     true,
                  fillColor:  Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ]),
        ),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2D5A8E)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)
            ],
          ),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('✦',
                    style: TextStyle(
                        color: Color(0xFFFFD600), fontSize: 14)),
                SizedBox(width: 10),
                Text('بسم الله',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                SizedBox(width: 10),
                Text('✦',
                    style: TextStyle(
                        color: Color(0xFFFFD600), fontSize: 14)),
              ]),
        ),
      ]),
    );
  }
}

// ── شريط الإشعار العلوي ──
class _StatusBanner extends StatelessWidget {
  final Color color;
  final String text;
  final Color textColor;
  final Widget? action;

  const _StatusBanner({
    required this.color,
    required this.text,
    required this.textColor,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.w600)),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}

// ── فقاعة الرسالة ──
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final bool isDeletedForAll;
  final String fullDate;
  final String Function(String) extractLink;
  final Future<void> Function(String) openLink;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.data,
    required this.isMe,
    required this.isDeletedForAll,
    required this.fullDate,
    required this.extractLink,
    required this.openLink,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final rawText = data['text'] ?? '';
    final text    = isDeletedForAll ? 'تم حذف هذه الرسالة' : rawText;
    final link    = isDeletedForAll ? '' : extractLink(rawText);
    final hasLink = link.isNotEmpty;
    final isRead  = data['read'] == true;

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: hasLink ? () => openLink(link) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isDeletedForAll
                ? Colors.grey.shade200
                : isMe
                    ? (isRead
                        ? const Color(0xFF3B5BDB)
                        : const Color(0xFF1F2937))
                    : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft:     const Radius.circular(16),
              topRight:    const Radius.circular(16),
              bottomLeft:  Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              text,
              style: TextStyle(
                fontSize:   14,
                fontStyle:  isDeletedForAll
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: isDeletedForAll
                    ? Colors.grey
                    : hasLink
                        ? (isMe
                            ? Colors.white
                            : const Color(0xFF3B5BDB))
                        : (isMe
                            ? Colors.white
                            : const Color(0xFF1F2937)),
                decoration: hasLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 5),
            Text(fullDate,
                style: TextStyle(
                    fontSize: 10,
                    color: isDeletedForAll
                        ? Colors.grey.shade400
                        : isMe
                            ? Colors.white60
                            : Colors.grey.shade400)),
            if (isMe && !isDeletedForAll) ...[
              const SizedBox(height: 2),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Icon(isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead
                        ? Colors.lightBlueAccent
                        : Colors.white60),
                const SizedBox(width: 4),
                Text(isRead ? 'مقروءة' : 'مُرسلة',
                    style: TextStyle(
                        fontSize: 10,
                        color: isRead
                            ? Colors.lightBlueAccent
                            : Colors.white60)),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

void unawaited(Future<void> future) {}
