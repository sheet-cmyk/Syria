import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'language_screen.dart';
import 'admin_panel_screen.dart';

// ── ترجمات صفحة ملفي ──
const Map<String, Map<String, String>> _str = {
  'ar': {
    'myProfile': 'ملفي',
    'editProfile': 'تعديل الملف الشخصي',
    'friends': 'الأصدقاء والمتابعون',
    'language': 'اللغة',
    'notifications': 'الإشعارات',
    'about': 'عن التطبيق',
    'logout': 'تسجيل خروج',
    'deleteAccount': 'حذف الحساب',
    'login': 'تسجيل دخول',
    'logoutConfirm': 'هل تريد تسجيل الخروج؟',
    'deleteConfirm':
        'سيتم حذف حسابك وجميع إعلاناتك نهائياً.\nهذا الإجراء لا يمكن التراجع عنه.',
    'deleteConfirm2': 'هل أنت متأكد تماماً؟ لا يمكن استرداد حسابك.',
    'deleteTitle': 'حذف الحساب',
    'deleteTitle2': 'تأكيد الحذف',
    'deleteFinal': 'حذف نهائي',
    'deleteYes': 'نعم، احذف',
    'deleteNo': 'لا، تراجع',
    'cancel': 'إلغاء',
    'ok': 'حسناً',
    'deleteFailed': 'فشل الحذف',
    'tapToLogin': 'اضغط لتسجيل الدخول',
    'aboutText':
        'هذا التطبيق 📱 مخصص للبيع والشراء 🛒، سواء جديد أو مستعمل، وأيضاً للبحث عن عمل 💼 وتقديم الخدمات في ألمانيا 🇩🇪.\n\nيمكنك مشاركة الفيديوهات 🎥 عبر يوتيوب، فيسبوك، وإنستغرام، وأيضاً رفع رابط PDF لسيرتك الذاتية 📄.\n\nفقط ضع الرابط في إعلانك، سواء من يوتيوب 🎬 أو فيسبوك 📘 أو إنستغرام 📸، حتى يتمكن الجميع من مشاهدة عملك بسهولة 🔗',
  },
  'en': {
    'myProfile': 'My Profile',
    'editProfile': 'Edit Profile',
    'friends': 'Friends & Followers',
    'language': 'Language',
    'notifications': 'Notifications',
    'about': 'About',
    'logout': 'Logout',
    'deleteAccount': 'Delete Account',
    'login': 'Log in',
    'logoutConfirm': 'Do you want to log out?',
    'deleteConfirm':
        'Your account and all your ads will be permanently deleted.\nThis action cannot be undone.',
    'deleteConfirm2':
        'Are you absolutely sure? Your account cannot be recovered.',
    'deleteTitle': 'Delete Account',
    'deleteTitle2': 'Confirm Deletion',
    'deleteFinal': 'Delete Permanently',
    'deleteYes': 'Yes, delete',
    'deleteNo': 'No, cancel',
    'cancel': 'Cancel',
    'ok': 'OK',
    'deleteFailed': 'Deletion failed',
    'tapToLogin': 'Tap to log in',
    'aboutText':
        'This app 📱 is for buying & selling 🛒, job search 💼, and services in Germany 🇩🇪.\n\nShare videos 🎥 via YouTube, Facebook, and Instagram, or upload a PDF link to your CV 📄.',
  },
  'de': {
    'myProfile': 'Mein Profil',
    'editProfile': 'Profil bearbeiten',
    'friends': 'Freunde & Follower',
    'language': 'Sprache',
    'notifications': 'Benachrichtigungen',
    'about': 'Über die App',
    'logout': 'Abmelden',
    'deleteAccount': 'Konto löschen',
    'login': 'Anmelden',
    'logoutConfirm': 'Möchtest du dich abmelden?',
    'deleteConfirm': 'Dein Konto und alle Anzeigen werden dauerhaft gelöscht.',
    'deleteConfirm2':
        'Bist du sicher? Das Konto kann nicht wiederhergestellt werden.',
    'deleteTitle': 'Konto löschen',
    'deleteTitle2': 'Löschung bestätigen',
    'deleteFinal': 'Endgültig löschen',
    'deleteYes': 'Ja, löschen',
    'deleteNo': 'Nein, abbrechen',
    'cancel': 'Abbrechen',
    'ok': 'OK',
    'deleteFailed': 'Löschen fehlgeschlagen',
    'tapToLogin': 'Tippen zum Anmelden',
    'aboutText':
        'Diese App 📱 ist für Kauf & Verkauf 🛒, Jobsuche 💼 und Dienstleistungen in Deutschland 🇩🇪.\n\nTeile Videos 🎥 über YouTube, Facebook und Instagram oder lade einen PDF-Link deines Lebenslaufs hoch 📄.',
  },
  'fr': {
    'myProfile': 'Mon profil',
    'editProfile': 'Modifier le profil',
    'friends': 'Amis & abonnés',
    'language': 'Langue',
    'notifications': 'Notifications',
    'about': "À propos",
    'logout': 'Déconnexion',
    'deleteAccount': 'Supprimer le compte',
    'login': 'Connexion',
    'logoutConfirm': 'Voulez-vous vous déconnecter?',
    'deleteConfirm':
        'Votre compte et toutes vos annonces seront supprimés définitivement.',
    'deleteConfirm2': 'Êtes-vous sûr? Le compte ne peut pas être récupéré.',
    'deleteTitle': 'Supprimer le compte',
    'deleteTitle2': 'Confirmer la suppression',
    'deleteFinal': 'Supprimer définitivement',
    'deleteYes': 'Oui, supprimer',
    'deleteNo': 'Non, annuler',
    'cancel': 'Annuler',
    'ok': 'OK',
    'deleteFailed': 'Échec de la suppression',
    'tapToLogin': 'Appuyer pour se connecter',
    'aboutText':
        'Cette application 📱 est dédiée à l\'achat et à la vente 🛒, à la recherche d\'emploi 💼 et aux services en Allemagne 🇩🇪.',
  },
  'sv': {
    'myProfile': 'Min profil',
    'editProfile': 'Redigera profil',
    'friends': 'Vänner & följare',
    'language': 'Språk',
    'notifications': 'Notifikationer',
    'about': 'Om appen',
    'logout': 'Logga ut',
    'deleteAccount': 'Radera konto',
    'login': 'Logga in',
    'logoutConfirm': 'Vill du logga ut?',
    'deleteConfirm': 'Ditt konto och alla annonser raderas permanent.',
    'deleteConfirm2': 'Är du säker? Kontot kan inte återställas.',
    'deleteTitle': 'Radera konto',
    'deleteTitle2': 'Bekräfta radering',
    'deleteFinal': 'Radera permanent',
    'deleteYes': 'Ja, radera',
    'deleteNo': 'Nej, avbryt',
    'cancel': 'Avbryt',
    'ok': 'OK',
    'deleteFailed': 'Radering misslyckades',
    'tapToLogin': 'Tryck för att logga in',
    'aboutText':
        'Den här appen 📱 är avsedd för köp och försäljning 🛒, jobbsökning 💼 och tjänster i Tyskland 🇩🇪.',
  },
  'uk': {
    'myProfile': 'Мій профіль',
    'editProfile': 'Редагувати профіль',
    'friends': 'Друзі та підписники',
    'language': 'Мова',
    'notifications': 'Сповіщення',
    'about': 'Про додаток',
    'logout': 'Вийти',
    'deleteAccount': 'Видалити акаунт',
    'login': 'Увійти',
    'logoutConfirm': 'Ви хочете вийти?',
    'deleteConfirm': 'Ваш акаунт та всі оголошення будуть видалені назавжди.',
    'deleteConfirm2': 'Ви впевнені? Акаунт не можна відновити.',
    'deleteTitle': 'Видалити акаунт',
    'deleteTitle2': 'Підтвердити видалення',
    'deleteFinal': 'Видалити назавжди',
    'deleteYes': 'Так, видалити',
    'deleteNo': 'Ні, скасувати',
    'cancel': 'Скасувати',
    'ok': 'OK',
    'deleteFailed': 'Помилка видалення',
    'tapToLogin': 'Натисніть для входу',
    'aboutText':
        'Цей додаток 📱 призначений для купівлі та продажу 🛒, пошуку роботи 💼 та послуг у Німеччині 🇩🇪.',
  },
  'tr': {
    'myProfile': 'Profilim',
    'editProfile': 'Profili düzenle',
    'friends': 'Arkadaşlar & takipçiler',
    'language': 'Dil',
    'notifications': 'Bildirimler',
    'about': 'Uygulama hakkında',
    'logout': 'Çıkış yap',
    'deleteAccount': 'Hesabı sil',
    'login': 'Giriş yap',
    'logoutConfirm': 'Çıkış yapmak istiyor musunuz?',
    'deleteConfirm': 'Hesabınız ve tüm ilanlarınız kalıcı olarak silinecek.',
    'deleteConfirm2': 'Emin misiniz? Hesap kurtarılamaz.',
    'deleteTitle': 'Hesabı sil',
    'deleteTitle2': 'Silmeyi onayla',
    'deleteFinal': 'Kalıcı olarak sil',
    'deleteYes': 'Evet, sil',
    'deleteNo': 'Hayır, iptal',
    'cancel': 'İptal',
    'ok': 'Tamam',
    'deleteFailed': 'Silme başarısız',
    'tapToLogin': 'Giriş yapmak için dokunun',
    'aboutText':
        'Bu uygulama 📱 Almanya\'da alım satım 🛒, iş arama 💼 ve hizmetler için tasarlanmıştır 🇩🇪.',
  },
  'ku': {
    'myProfile': 'Profîla min',
    'editProfile': 'Profîlê biguherîne',
    'friends': 'Heval û şopîner',
    'language': 'Ziman',
    'notifications': 'Agahdarî',
    'about': 'Derbarê serlêdanê',
    'logout': 'Derkeve',
    'deleteAccount': 'Hesabê jê bibe',
    'login': 'Têkeve',
    'logoutConfirm': 'Tu dixwazî derkevî?',
    'deleteConfirm':
        'Hesabê te û hemû reklamên te dê bêne jêbirin.\nEv çalakî nayê vegerandin.',
    'deleteConfirm2': 'Tu bi rastî piştrast î? Hesab nayê vegerandin.',
    'deleteTitle': 'Hesabê jê bibe',
    'deleteTitle2': 'Jêbirinê piştrast bike',
    'deleteFinal': 'Bi dawî jê bibe',
    'deleteYes': 'Erê, jê bibe',
    'deleteNo': 'Na, vegerê',
    'cancel': 'Betal bike',
    'ok': 'Baş e',
    'deleteFailed': 'Jêbirin têk çû',
    'tapToLogin': 'Ji bo têketinê bixin',
    'aboutText':
        'Ev serlêdan 📱 ji bo kirrûbirr 🛒, lêgerîna kar 💼 û xizmetên li Almanyayê 🇩🇪 hatiye çêkirin.',
  },
  'ckb': {
    'myProfile': 'پرۆفایلەکەم',
    'editProfile': 'پرۆفایل دەستکاری بکە',
    'friends': 'هاوڕێ و شوێنکەوتووان',
    'language': 'زمان',
    'notifications': 'ئاگادارکردنەوە',
    'about': 'دەربارەی ئەپ',
    'logout': 'دەرچوون',
    'deleteAccount': 'ئەکاونت بسڕەوە',
    'login': 'چوونەژوورەوە',
    'logoutConfirm': 'دەتەوێت دەربچیت؟',
    'deleteConfirm':
        'ئەکاونتەکەت و هەموو ئەعلانەکانت بە هەمیشەیی دەسڕێنەوە.\nئەم کارە ناگەڕێتەوە.',
    'deleteConfirm2': 'دڵنیایت؟ ئەکاونتەکە ناگەڕێتەوە.',
    'deleteTitle': 'ئەکاونت بسڕەوە',
    'deleteTitle2': 'سڕینەوە دڵنیا بکەرەوە',
    'deleteFinal': 'بە هەمیشەیی بسڕەوە',
    'deleteYes': 'بەڵێ، بسڕەوە',
    'deleteNo': 'نەخێر، بگەڕێوە',
    'cancel': 'هەڵوەشاندنەوە',
    'ok': 'باشە',
    'deleteFailed': 'سڕینەوە سەرکەوتوو نەبوو',
    'tapToLogin': 'بۆ چوونەژوورەوە کلیک بکە',
    'aboutText':
        'ئەم ئەپە 📱 بۆ کڕین و فرۆشتن 🛒، گەڕانی کار 💼 و خزمەتگوزاری لە ئەڵمانیا 🇩🇪 دروست کراوە.',
  },
};

String _t(String lang, String key) =>
    _str[lang]?[key] ?? _str['ar']![key] ?? key;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});
  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final enabled = await NotificationService.isNotificationsEnabled();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _openLanguage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
  }

  void _showAboutDialog() {
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

  Future<void> _deleteAccount() async {
    final l = Localizations.localeOf(context).languageCode;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_t(l, 'deleteTitle'),
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
        content: Text(_t(l, 'deleteConfirm'),
            textAlign: TextAlign.right, style: const TextStyle(height: 1.6)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_t(l, 'cancel'),
                  style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white),
              child: Text(_t(l, 'deleteFinal'))),
        ],
      ),
    );
    if (confirm != true) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_t(l, 'deleteTitle2'),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(_t(l, 'deleteConfirm2'), textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_t(l, 'deleteNo'))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white),
              child: Text(_t(l, 'deleteYes'))),
        ],
      ),
    );
    if (confirm2 != true) return;

    if (!mounted) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD600))));

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
              '${_t(Localizations.localeOf(context).languageCode, "deleteFailed")}: ${e.toString().substring(0, e.toString().length.clamp(0, 80))}'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Localizations.localeOf(context).languageCode;
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;
        final photoUrl = user?.photoURL ?? '';
        final name = user?.displayName ?? _t(l, 'tapToLogin');
        final email = user?.email ?? '';

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: SafeArea(child: LayoutBuilder(builder: (_, c) {
            final hPad = c.maxWidth > 640 ? (c.maxWidth - 640) / 2 : 0.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(children: [
                // هيدر
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFFFFD600)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Share.share(
                                  'حمل تطبيقنا الآن للايفون من هنا:\nhttps://syria-51312.web.app/');
                            },
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.apple,
                                  size: 45,
                                  color: Color(0xFFD1D5DB), // لون فضي
                                  shadows: [
                                    Shadow(
                                        color: Colors.black45,
                                        offset: Offset(2, 3),
                                        blurRadius: 4),
                                    Shadow(
                                        color: Colors.white,
                                        offset: Offset(-1, -1),
                                        blurRadius: 2),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text('مشاركة للايفون',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.black, size: 24)),
                        ]),
                    const SizedBox(height: 10),
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
                        backgroundImage:
                            photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
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
                    if (isLoggedIn)
                      Text(email,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                  ]),
                ),

                // القائمة
                Expanded(
                    child:
                        ListView(padding: const EdgeInsets.all(16), children: [
                  _item(Icons.person_outline, _t(l, 'editProfile'), onTap: () {
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

                  _item(Icons.language, _t(l, 'language'),
                      onTap: _openLanguage),

                  // الإشعارات
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4)
                        ]),
                    child: ListTile(
                      trailing: const Icon(Icons.notifications_outlined,
                          color: Color(0xFF6B7280), size: 22),
                      title: Text(_t(l, 'notifications'),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.w500)),
                      leading: Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: _notificationsEnabled,
                            onChanged: (val) async {
                              setState(() => _notificationsEnabled = val);
                              await NotificationService.setNotificationsEnabled(
                                  val);
                            },
                            activeColor: const Color(0xFFFFD600),
                            activeTrackColor:
                                const Color(0xFFFFD600).withOpacity(0.3),
                          )),
                    ),
                  ),

                  _item(Icons.info_outline, _t(l, 'about'),
                      onTap: _showAboutDialog),

                  if (AuthService.isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6)
                        ],
                      ),
                      child: ListTile(
                        trailing: const Icon(Icons.admin_panel_settings,
                            color: Color(0xFFFFD600), size: 22),
                        title: const Text('لوحة التحكم',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.chevron_left,
                            color: Colors.white54, size: 20),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AdminPanelScreen())),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  if (isLoggedIn) ...[
                    _item(Icons.logout, _t(l, 'logout'), isRed: true,
                        onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title:
                              Text(_t(l, 'logout'), textAlign: TextAlign.right),
                          content: Text(_t(l, 'logoutConfirm'),
                              textAlign: TextAlign.right),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(_t(l, 'cancel'))),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white),
                                child: Text(_t(l, 'logout'))),
                          ],
                        ),
                      );
                      if (confirm == true) await AuthService.signOut();
                    }),
                    _item(Icons.delete_forever_outlined, _t(l, 'deleteAccount'),
                        isRed: true, onTap: _deleteAccount),
                  ] else
                    _item(Icons.login, _t(l, 'login'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AuthScreen()))),

                  const SizedBox(height: 20),
                ])),
              ]),
            );
          })),
        );
      },
    );
  }

  Widget _item(IconData icon, String label,
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
