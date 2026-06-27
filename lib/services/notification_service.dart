import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// قناة الإشعارات — يجب أن تطابق channel_id في كل مكان
const String kChannelId   = 'messages_channel';
const String kChannelName = 'رسائل المحادثة';
const String kChannelDesc = 'إشعارات الرسائل الجديدة من المستخدمين';

/// المكوّن الوحيد للإشعارات المحلية (singleton)
final FlutterLocalNotificationsPlugin localNotif =
    FlutterLocalNotificationsPlugin();

/// تفاصيل الإشعار لأندرويد
const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
  kChannelId,
  kChannelName,
  channelDescription: kChannelDesc,
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/launcher_icon',
  playSound: true,
  enableVibration: true,
);

const NotificationDetails _notifDetails =
    NotificationDetails(android: _androidDetails);

// ─── خدمة الإشعارات ─────────────────────────────────────────────────────────

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static StreamSubscription? _firestoreSub;
  static int _notifId = 0;

  // ── تهيئة كاملة (تُستدعى في main) ─────────────────────────────────────────
  static Future<void> init() async {
    if (!kIsWeb) await _initLocalNotifications();
    await _requestPermissions();
    await saveToken();
    _fcm.onTokenRefresh.listen(_saveTokenToFirestore);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);
  }

  // ── إعداد flutter_local_notifications (موبايل فقط) ────────────────────────
  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidInit);
    await localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotifTap,
    );
    const channel = AndroidNotificationChannel(
      kChannelId, kChannelName,
      description: kChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ── طلب الأذونات ────────────────────────────────────────────────────────────
  static Future<void> _requestPermissions() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
  }

  // ── عرض إشعار محلي (موبايل فقط — الويب لا يدعمه) ──────────────────────────
  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    try {
      await localNotif.show(_notifId++, title, body, _notifDetails);
    } catch (_) {}
  }

  // ── رسالة FCM في الأمام ─────────────────────────────────────────────────────
  static void _onForegroundMessage(RemoteMessage msg) {
    final title = msg.notification?.title ?? msg.data['title'] ?? 'رسالة جديدة';
    final body  = msg.notification?.body  ?? msg.data['body']  ?? '';
    showLocalNotification(title: title, body: body);
  }

  // مفتاح التنقل — يُسجَّل في main.dart
  static GlobalKey<NavigatorState>? navigatorKey;

  // ── نقر على إشعار FCM (خلفية) ──────────────────────────────────────────────
  static void _onNotificationOpened(RemoteMessage msg) {
    _handleNotificationNavigation(msg.data);
  }

  // ── نقر على إشعار محلي ─────────────────────────────────────────────────────
  static void _onLocalNotifTap(NotificationResponse response) {}

  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final auctionId = data['auctionId'] as String?;
    if (auctionId == null) return;
    if (type == 'auction_won' || type == 'auction_sold') {
      navigatorKey?.currentState?.pushNamed('/auction/$auctionId');
    }
  }

  // ── حفظ FCM token ───────────────────────────────────────────────────────────
  // احصل على VAPID key من: Firebase Console → Project Settings → Cloud Messaging → Web Push certificates
  static const _vapidKey =
      'BIFdMHIJ_YOUR_VAPID_KEY_HERE';

  static Future<void> saveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final token = kIsWeb
          ? await _fcm.getToken(vapidKey: _vapidKey)
          : await _fcm.getToken();
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

  // ── مستمع Firestore: يعرض إشعاراً عند كل رسالة جديدة ──────────────────────
  static Future<void> startListening() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _firestoreSub?.cancel();

    final startTime = Timestamp.now();

    _firestoreSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('createdAt', isGreaterThan: startTime)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() ?? {};
          final type  = data['type']  as String? ?? '';
          final title = data['title'] as String? ?? 'إشعار جديد';
          String body = data['body']  as String? ?? '';

          // أضف بيانات التواصل لإشعارات المزاد
          final contactLines = data['contactLines'] as String? ?? '';
          if (contactLines.isNotEmpty &&
              (type == 'auction_won' || type == 'auction_sold')) {
            body = '$body\n\n📋 معلومات التواصل:\n$contactLines';
          }

          showLocalNotification(title: title, body: body);
        }
      }
    });
  }

  /// يُستدعى عند تسجيل الخروج
  static void stopListening() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  // ── إرسال إشعار (يحفظ في Firestore للمستلم) ────────────────────────────────
  static Future<void> sendMessageNotification({
    required String toUserId,
    required String fromName,
    required String message,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(toUserId)
          .get();
      if (!doc.exists) return;

      final data    = doc.data()!;
      final enabled = data['notificationsEnabled'] as bool? ?? true;
      if (!enabled) return;

      final body = message.length > 60
          ? '${message.substring(0, 60)}...'
          : message;

      // حفظ الإشعار في Firestore — سيلتقطه _firestoreSub لدى المستلم
      await FirebaseFirestore.instance
          .collection('users')
          .doc(toUserId)
          .collection('notifications')
          .add({
        'type':      'message',
        'title':     'رسالة من $fromName',
        'body':      body,
        'fromName':  fromName,
        'createdAt': FieldValue.serverTimestamp(),
        'read':      false,
      });
    } catch (_) {}
  }

  // ── تفعيل / إيقاف الإشعارات ─────────────────────────────────────────────────
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
}
