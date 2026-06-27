import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;

  // تهيئة الإشعارات
  static Future<void> init() async {
    // طلب إذن
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // احفظ الـ token
    await saveToken();

    // استمع للتغييرات في الـ token
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _saveTokenToFirestore(token);
    });
  }

  // احفظ الـ FCM token في Firestore
  static Future<void> saveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final token = await _fcm.getToken();
      if (token != null) await _saveTokenToFirestore(token);
    } catch (_) {}
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'notificationsEnabled': true,
    }, SetOptions(merge: true));
  }

  // تفعيل/إيقاف الإشعارات
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'notificationsEnabled': enabled,
    }, SetOptions(merge: true));
  }

  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  // إرسال إشعار عبر FCM (يُستدعى من chat_screen عند إرسال رسالة)
  static Future<void> sendMessageNotification({
    required String toUserId,
    required String fromName,
    required String message,
  }) async {
    try {
      // جلب token المستلم
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(toUserId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final token = data['fcmToken'] as String?;
      final enabled = data['notificationsEnabled'] as bool? ?? true;

      if (token == null || !enabled) return;

      // حفظ الإشعار في Firestore (لعرضه لاحقاً)
      await FirebaseFirestore.instance
          .collection('users').doc(toUserId)
          .collection('notifications').add({
        'type':      'message',
        'title':     'رسالة من $fromName',
        'body':      message.length > 50 ? '${message.substring(0, 50)}...' : message,
        'fromName':  fromName,
        'createdAt': FieldValue.serverTimestamp(),
        'read':      false,
      });
    } catch (_) {}
  }
}
