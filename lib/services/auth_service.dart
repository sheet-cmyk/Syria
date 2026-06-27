import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: kIsWeb ? null : _webClientId,
  );

  static const _webClientId = '1022310524811-3iv7utb9bst0bm7sv477a2piq5dipk41.apps.googleusercontent.com';
  static final _db = FirebaseFirestore.instance;

  static const _adminEmails = {'hussein1sheet@gmail.com'};

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static bool get isLoggedIn => _auth.currentUser != null;
  static bool get isAdmin => _adminEmails.contains(_auth.currentUser?.email?.toLowerCase());

  static Future<String> _getDeviceId() async {
    if (kIsWeb) return 'unknown';
    try {
      final info = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) { final android = await info.androidInfo; return android.id; }
      else if (defaultTargetPlatform == TargetPlatform.iOS) { final ios = await info.iosInfo; return ios.identifierForVendor ?? 'unknown'; }
    } catch (_) {}
    return 'unknown';
  }

  static Future<String?> _checkDeviceLimit(User user) async {
    final deviceId = await _getDeviceId();
    if (deviceId == 'unknown') return null;
    if (deviceId == 'BP4A.251205.006') return null; // جهاز التطوير - بدون قيود
    final uid = user.uid;
    final deviceRef = _db.collection('devices').doc(deviceId);
    return await _db.runTransaction<String?>((transaction) async {
      final deviceSnap = await transaction.get(deviceRef);
      if (deviceSnap.exists) {
        final accounts = List<String>.from(deviceSnap['accounts'] ?? []);
        if (accounts.contains(uid)) return null;
        if (accounts.length >= 3) return 'device_limit';
        transaction.update(deviceRef, {'accounts': FieldValue.arrayUnion([uid]), 'updatedAt': FieldValue.serverTimestamp()});
      } else {
        transaction.set(deviceRef, {'accounts': [uid], 'createdAt': FieldValue.serverTimestamp()});
      }
      return null;
    });
  }

  static Future<String?> registerWithEmail({required String email, required String password, required String name}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final limitResult = await _checkDeviceLimit(cred.user!);
      if (limitResult == 'device_limit') { await cred.user!.delete(); await _auth.signOut(); return 'device_limit'; }
      await cred.user?.updateDisplayName(name);
      await _saveUserToFirestore(cred.user!, name: name);
      return null;
    } on FirebaseAuthException catch (e) { return _errorMessage(e.code); }
  }

  static Future<String?> loginWithEmail({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final limitResult = await _checkDeviceLimit(cred.user!);
      if (limitResult == 'device_limit') { await _auth.signOut(); return 'device_limit'; }
      final banResult = await _checkBanStatus(cred.user!);
      if (banResult != null) { await _auth.signOut(); return banResult; }
      await _saveUserToFirestore(cred.user!);
      return null;
    } on FirebaseAuthException catch (e) { return _errorMessage(e.code); }
  }

  static Future<String?> _checkBanStatus(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      if (data['banned'] != true) return null;
      final until = data['bannedUntil'] as Timestamp?;
      if (until == null) return 'account_banned_permanent';
      if (until.toDate().isAfter(DateTime.now())) return 'account_banned_temporary';
      // الحظر انتهى — رفعه تلقائياً
      await _db.collection('users').doc(user.uid).update({'banned': false, 'bannedUntil': null});
      return null;
    } catch (_) { return null; }
  }

  static Future<String?> loginWithGoogle() async {
    try {
      UserCredential cred;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        cred = await _auth.signInWithPopup(provider);
      } else {
        // الموبايل: الطريقة العادية
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return 'cancelled';
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }
      final limitResult = await _checkDeviceLimit(cred.user!);
      if (limitResult == 'device_limit') {
        try { await cred.user!.delete(); } catch (_) {}
        if (!kIsWeb) await _googleSignIn.signOut();
        await _auth.signOut();
        return 'device_limit';
      }
      final banResult = await _checkBanStatus(cred.user!);
      if (banResult != null) {
        if (!kIsWeb) await _googleSignIn.signOut();
        await _auth.signOut();
        return banResult;
      }
      await _saveUserToFirestore(cred.user!);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        return 'cancelled';
      }
      return _errorMessage(e.code);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('popup-closed') || msg.contains('cancelled')) return 'cancelled';
      return 'خطأ: $msg';
    }
  }

  static Future<void> resetPassword(String email) async => await _auth.sendPasswordResetEmail(email: email);

  static Future<void> signOut() async { await _googleSignIn.signOut(); await _auth.signOut(); }

  static Future<void> _saveUserToFirestore(User user, {String? name}) async {
    final doc = _db.collection('users').doc(user.uid);
    final snap = await doc.get();
    final isAdminUser = _adminEmails.contains(user.email?.toLowerCase());
    if (!snap.exists) {
      await doc.set({
        'uid': user.uid, 'name': name ?? user.displayName ?? '',
        'email': user.email ?? '', 'photoUrl': user.photoURL ?? '',
        'phone': '', 'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': isAdminUser,
      });
    } else if (isAdminUser && snap.data()?['isAdmin'] != true) {
      await doc.update({'isAdmin': true});
    }
  }

  // ── تحديث الملف الشخصي مع socialLinks ──
  static Future<String?> updateProfile({
    required String name,
    String? phone,
    String? photoUrl,
    Map<String, String>? socialLinks,
  }) async {
    try {
      final user = _auth.currentUser!;
      await user.updateDisplayName(name);
      final Map<String, dynamic> updateData = {
        'name': name,
        'phone': phone ?? '',
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (socialLinks != null) 'socialLinks': socialLinks,
      };
      await _db.collection('users').doc(user.uid).update(updateData);
      return null;
    } catch (e) { return 'حدث خطأ أثناء التحديث'; }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  static String _errorMessage(String code) {
    switch (code) {
      case 'user-not-found':      return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':      return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':return 'البريد الإلكتروني مسجل مسبقاً';
      case 'weak-password':       return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':       return 'البريد الإلكتروني غير صحيح';
      default:                    return 'حدث خطأ، حاول مجدداً';
    }
  }
}
