import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../gen_l10n/app_localizations.dart';
import '../gen_l10n/app_localizations_ar.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'language_screen.dart';
import 'friends_screen.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final enabled = await NotificationService.isNotificationsEnabled();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  // ── نفس زر المشاركة من profile_screen ──
  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () => Share.share(
        'حمل تطبيقنا الآن للبيع والشراء 🛒\n'
        'https://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.android, color: Color(0xFF3DDC84), size: 26),
            ),
            const SizedBox(height: 3),
            const Text(
              'مشاركة مع',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            const Text(
              'الأصدقاء',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    const instagramUrl = 'https://www.instagram.com/alzain.2012?igsh=eTRlbmkyN2U2OWd0';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('عن التطبيق',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 8),
            Icon(Icons.info_outline, color: Color(0xFFFFD600)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'مرحبًا بك في سوق مستعمل سوريا، منصة مجانية 100% لبيع وشراء المستعمل بكل سهولة وأمان.\n\n'
                'يمكنك نشر إعلاناتك مجانًا، والبحث عن المنتجات التي تحتاجها، والتواصل مباشرة مع البائع أو المشتري دون أي رسوم.\n\n'
                'تم إنشاء هذا التطبيق وتطويره في سبيل الله، بهدف تقديم خدمة مجانية ومفيدة لجميع المستخدمين.',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, height: 1.8, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'تطوير التطبيق:',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 4),
              const Text(
                'المهندس حسين المصلاوي',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.6),
              ),
              const SizedBox(height: 12),
              const Text(
                'للمساعدة أو أي استفسار:',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 4),
              const Text(
                'يمكنك مراسلتي على انستغرام، وسأكون سعيدًا بمساعدتك والإجابة على جميع استفساراتك.',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.6),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse(instagramUrl),
                  mode: LaunchMode.externalApplication,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE1306C), Color(0xFFF77737), Color(0xFF833AB4)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'alzain.2012@',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('Instagram',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('حسناً',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, AppLocalizations l) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الحساب',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
        content: const Text(
            'سيتم حذف حسابك وجميع إعلاناتك نهائياً.\nهذا الإجراء لا يمكن التراجع عنه.',
            textAlign: TextAlign.right,
            style: TextStyle(height: 1.6)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأكيد الحذف',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد تماماً؟ لا يمكن استرداد حسابك.',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا، تراجع')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white),
            child: const Text('نعم، احذف'),
          ),
        ],
      ),
    );
    if (confirm2 != true) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD600))),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final providerIds = user.providerData.map((p) => p.providerId).toList();
      if (providerIds.contains('google.com')) {
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          if (mounted) Navigator.pop(context);
          return;
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        await user.reauthenticateWithCredential(credential);
      }

      final uid = user.uid;
      final db = FirebaseFirestore.instance;
      final adsDocs =
          await db.collection('ads').where('userId', isEqualTo: uid).get();
      final batch = db.batch();
      for (final doc in adsDocs.docs) {
        batch.delete(doc.reference);
      }
      final favDocs =
          await db.collection('users').doc(uid).collection('favorites').get();
      for (final doc in favDocs.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(db.collection('users').doc(uid));
      await batch.commit();
      await user.delete();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'فشل الحذف: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _importAdsFromJson(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD600))),
      );

      final String jsonString = await rootBundle.loadString('assets/ads.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      for (var item in jsonList) {
        final docRef = db.collection('ads').doc(item['id']?.toString());
        final Map<String, dynamic> data = Map<String, dynamic>.from(item);
        // تحويل التاريخ لنوع Timestamp الذي يقبله الفايربيس
        if (data['createdAt'] != null) {
          data['createdAt'] =
              Timestamp.fromDate(DateTime.parse(data['createdAt']));
        } else {
          data['createdAt'] = FieldValue.serverTimestamp();
        }
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      if (!mounted) return;
      Navigator.pop(context); // إغلاق اللودينغ
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم رفع الإعلانات بنجاح!'),
          backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // إغلاق اللودينغ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ أثناء الرفع: $e'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: StreamBuilder<User?>(
        stream: AuthService.authStateChanges,
        builder: (context, snapshot) {
          final l = AppLocalizations.of(context) ?? AppLocalizationsAr('ar');
          final user = snapshot.data;
          final isLoggedIn = user != null;
          final photoUrl = user?.photoURL ?? '';
          final name = user?.displayName ?? l.guestUser;
          final email = user?.email ?? '';

          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            // ── AppBar بنفس ستايل profile_screen مع أيقونة المشاركة ──
            appBar: AppBar(
              toolbarHeight: 0,
              backgroundColor: const Color(0xFFFFD600),
              elevation: 0,
            ),
            body: Column(
              children: [
                // ── هيدر أصفر ──
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFD600),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      // صف العلوي
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // أيقونة المشاركة — يمين
                          _buildShareButton(),

                          // زر الرجوع — يسار
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_forward,
                                color: Colors.black, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // صورة البروفايل
                      GestureDetector(
                        onTap: () {
                          if (!isLoggedIn) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AuthScreen()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileScreen()));
                          }
                        },
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl.isEmpty
                              ? const Icon(Icons.person,
                                  size: 42, color: Color(0xFFFFD600))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(isLoggedIn ? email : l.tapToLogin,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                ),

                // ── القائمة ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _settingItem(context, Icons.person_outline, l.editProfile,
                          onTap: () {
                        if (!isLoggedIn) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AuthScreen()));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileScreen()));
                        }
                      }),
                      if (isLoggedIn)
                        _settingItem(context, Icons.people_outline,
                            'الأصدقاء والمتابعون',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        FriendsScreen(userId: user.uid)))),
                      _settingItem(context, Icons.language, l.language,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LanguageScreen()))),
                      _notificationToggleItem(context),
                      _settingItem(context, Icons.info_outline, 'عن التطبيق',
                          onTap: () => _showAboutDialog(context)),
                      const SizedBox(height: 8),
                      if (isLoggedIn)
                        _settingItem(context, Icons.cloud_upload_outlined,
                            'استيراد الإعلانات من JSON',
                            onTap: () => _importAdsFromJson(context)),
                      const SizedBox(height: 8),
                      if (isLoggedIn) ...[
                        _settingItem(context, Icons.logout, l.logout,
                            isRed: true, onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: Text(l.logout, textAlign: TextAlign.right),
                              content: Text(l.logoutConfirm,
                                  textAlign: TextAlign.right),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(l.cancel)),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white),
                                  child: Text(l.logout),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) await AuthService.signOut();
                        }),
                        _settingItem(context, Icons.delete_forever_outlined,
                            'حذف الحساب',
                            isRed: true,
                            onTap: () => _deleteAccount(context, l)),
                      ] else
                        _settingItem(context, Icons.login, l.login,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AuthScreen()))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _notificationToggleItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)
          ]),
      child: ListTile(
        trailing: const Icon(Icons.notifications_outlined,
            color: Color(0xFF6B7280), size: 22),
        title: const Text('الإشعارات',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500)),
        leading: Transform.scale(
          scale: 0.85,
          child: Switch(
            value: _notificationsEnabled,
            onChanged: (val) async {
              setState(() => _notificationsEnabled = val);
              await NotificationService.setNotificationsEnabled(val);
            },
            activeColor: const Color(0xFFFFD600),
            activeTrackColor: const Color(0xFFFFD600).withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _settingItem(BuildContext context, IconData icon, String label,
      {bool isRed = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)
          ]),
      child: ListTile(
        trailing: Icon(icon,
            color: isRed ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
            size: 22),
        title: Text(label,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 14,
                color:
                    isRed ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
                fontWeight: FontWeight.w500)),
        leading: const Icon(Icons.chevron_left, color: Color(0xFFD1D5DB)),
        onTap: onTap ?? () {},
      ),
    );
  }
}
