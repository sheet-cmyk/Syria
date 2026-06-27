import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';

// ── ترجمات صفحة تعديل الملف الشخصي ──
const Map<String, Map<String, String>> _profileStr = {
  'ar': {
    'title': 'تعديل الملف الشخصي',
    'fullName': 'الاسم الكامل',
    'nameHint': 'أدخل اسمك الكامل',
    'email': 'البريد الإلكتروني',
    'phone': 'رقم الهاتف',
    'phoneHint': 'أدخل رقم الهاتف بدون الرمز',
    'socialTitle': 'أضف مهنتك / روابط التواصل',
    'socialSub': 'تظهر في إعلاناتك للتواصل المباشر',
    'chooseCountry': 'اختر الدولة',
    'saveBtn': 'حفظ التغييرات',
    'savedOk': 'تم الحفظ بنجاح ✓',
    'shareApp': 'مشاركة التطبيق\nمع الأصدقاء',
    'shareMsg': 'حمل تطبيقنا الآن للبيع والشراء:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'en': {
    'title': 'Edit Profile',
    'fullName': 'Full Name',
    'nameHint': 'Enter your full name',
    'email': 'Email Address',
    'phone': 'Phone Number',
    'phoneHint': 'Enter number without country code',
    'socialTitle': 'Add profession / social links',
    'socialSub': 'Appears in your ads for direct contact',
    'chooseCountry': 'Choose Country',
    'saveBtn': 'Save Changes',
    'savedOk': 'Saved successfully ✓',
    'shareApp': 'Share App\nwith Friends',
    'shareMsg': 'Download our app now:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'de': {
    'title': 'Profil bearbeiten',
    'fullName': 'Vollständiger Name',
    'nameHint': 'Gib deinen vollständigen Namen ein',
    'email': 'E-Mail-Adresse',
    'phone': 'Telefonnummer',
    'phoneHint': 'Nummer ohne Vorwahl eingeben',
    'socialTitle': 'Beruf / Social-Media-Links hinzufügen',
    'socialSub': 'Erscheint in deinen Anzeigen für direkten Kontakt',
    'chooseCountry': 'Land wählen',
    'saveBtn': 'Änderungen speichern',
    'savedOk': 'Erfolgreich gespeichert ✓',
    'shareApp': 'App teilen\nmit Freunden',
    'shareMsg': 'Lade unsere App jetzt herunter:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'fr': {
    'title': 'Modifier le profil',
    'fullName': 'Nom complet',
    'nameHint': 'Entrez votre nom complet',
    'email': 'Adresse e-mail',
    'phone': 'Numéro de téléphone',
    'phoneHint': 'Numéro sans indicatif',
    'socialTitle': 'Ajouter métier / liens sociaux',
    'socialSub': 'Apparaît dans vos annonces pour contact direct',
    'chooseCountry': 'Choisir un pays',
    'saveBtn': 'Enregistrer les modifications',
    'savedOk': 'Enregistré avec succès ✓',
    'shareApp': 'Partager\nl\'application',
    'shareMsg': 'Téléchargez notre application:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'sv': {
    'title': 'Redigera profil',
    'fullName': 'Fullständigt namn',
    'nameHint': 'Ange ditt fullständiga namn',
    'email': 'E-postadress',
    'phone': 'Telefonnummer',
    'phoneHint': 'Nummer utan riktnummer',
    'socialTitle': 'Lägg till yrke / sociala länkar',
    'socialSub': 'Visas i dina annonser för direktkontakt',
    'chooseCountry': 'Välj land',
    'saveBtn': 'Spara ändringar',
    'savedOk': 'Sparades framgångsrikt ✓',
    'shareApp': 'Dela appen\nmed vänner',
    'shareMsg': 'Ladda ner vår app nu:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'uk': {
    'title': 'Редагувати профіль',
    'fullName': 'Повне ім\'я',
    'nameHint': 'Введіть своє повне ім\'я',
    'email': 'Електронна пошта',
    'phone': 'Номер телефону',
    'phoneHint': 'Номер без коду країни',
    'socialTitle': 'Додати професію / соціальні посилання',
    'socialSub': 'Відображається у ваших оголошеннях',
    'chooseCountry': 'Вибрати країну',
    'saveBtn': 'Зберегти зміни',
    'savedOk': 'Збережено успішно ✓',
    'shareApp': 'Поділитися\nдодатком',
    'shareMsg': 'Завантажте наш додаток:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'tr': {
    'title': 'Profili düzenle',
    'fullName': 'Tam ad',
    'nameHint': 'Tam adınızı girin',
    'email': 'E-posta adresi',
    'phone': 'Telefon numarası',
    'phoneHint': 'Numara kodu olmadan girin',
    'socialTitle': 'Meslek / sosyal medya bağlantısı ekle',
    'socialSub': 'İlanlarınızda doğrudan iletişim için görünür',
    'chooseCountry': 'Ülke seç',
    'saveBtn': 'Değişiklikleri kaydet',
    'savedOk': 'Başarıyla kaydedildi ✓',
    'shareApp': 'Uygulamayı\npaylaş',
    'shareMsg': 'Uygulamamızı indirin:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'ku': {
    'title': 'Profîlê biguherîne',
    'fullName': 'Navê tam',
    'nameHint': 'Navê xwe yê tam binivîse',
    'email': 'E-posta',
    'phone': 'Hejmara telefon',
    'phoneHint': 'Jimarê bê koda welêt binivîse',
    'socialTitle': 'Pisporiya xwe / girêdanên civakî zêde bike',
    'socialSub': 'Di reklamên xwe de ji bo têkiliya rasterast xuya dibe',
    'chooseCountry': 'Welat hilbijêre',
    'saveBtn': 'Guhartinan toze bike',
    'savedOk': 'Bi serkeftî toze bû ✓',
    'shareApp': 'Sepanê\nbiparvêze',
    'shareMsg': 'Sepana me dakêşin:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
  'ckb': {
    'title': 'پرۆفایل دەستکاری بکە',
    'fullName': 'ناوی تەواو',
    'nameHint': 'ناوی تەواوەکەت بنووسە',
    'email': 'ئیمەیڵ',
    'phone': 'ژمارەی تەلەفۆن',
    'phoneHint': 'ژمارە بەبێ کۆدی وڵات بنووسە',
    'socialTitle': 'پیشە / لینکی کۆمەڵایەتی زیاد بکە',
    'socialSub': 'لە ئەعلانەکانت بۆ پەیوەندی ڕاستەوخۆ دەردەکەوێت',
    'chooseCountry': 'وڵات هەڵبژێرە',
    'saveBtn': 'گۆڕانکاریەکان پاشەکەوت بکە',
    'savedOk': 'بە سەرکەوتوویی پاشەکەوت کرا ✓',
    'shareApp': 'ئەپەکە\nبڵاو بکەرەوە',
    'shareMsg': 'ئەپەکەمان داگرە:\nhttps://play.google.com/store/apps/details?id=com.hussein.syriaadsapp',
  },
};

String _p(String lang, String key) =>
    _profileStr[lang]?[key] ?? _profileStr['ar']![key] ?? key;

class _Country {
  final String name;
  final String flag;
  final String code;
  const _Country(this.name, this.flag, this.code);
}

const List<_Country> _countries = [
  _Country('ألمانيا', '🇩🇪', '+49'),
  _Country('سوريا', 'SY', '+963'),
  _Country('السعودية', '🇸🇦', '+966'),
  _Country('الإمارات', '🇦🇪', '+971'),
  _Country('الأردن', '🇯🇴', '+962'),
  _Country('لبنان', '🇱🇧', '+961'),
  _Country('العراق', '🇮🇶', '+964'),
  _Country('مصر', '🇪🇬', '+20'),
  _Country('تركيا', '🇹🇷', '+90'),
  _Country('هولندا', '🇳🇱', '+31'),
  _Country('السويد', '🇸🇪', '+46'),
  _Country('النمسا', '🇦🇹', '+43'),
  _Country('بلجيكا', '🇧🇪', '+32'),
  _Country('فرنسا', '🇫🇷', '+33'),
  _Country('المملكة المتحدة', '🇬🇧', '+44'),
  _Country('الولايات المتحدة', '🇺🇸', '+1'),
  _Country('كندا', '🇨🇦', '+1'),
  _Country('أستراليا', '🇦🇺', '+61'),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _tiktokCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _success;
  Map<String, dynamic>? _userData;

  late _Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.firstWhere((c) => c.name == 'سوريا',
        orElse: () => _countries[0]);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    final data = await AuthService.getUserData();
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        _userData = data;
        _nameCtrl.text = data?['name'] ?? user?.displayName ?? '';

        final savedPhone = data?['phone'] ?? '';
        if (savedPhone.isNotEmpty) {
          bool found = false;
          for (final c in _countries) {
            if (savedPhone.startsWith(c.code)) {
              _selectedCountry = c;
              _phoneCtrl.text = savedPhone.substring(c.code.length).trim();
              found = true;
              break;
            }
          }
          if (!found) _phoneCtrl.text = savedPhone;
        }

        _facebookCtrl.text = prefs.getString('social_facebook') ??
            data?['socialLinks']?['facebook'] ?? '';
        _instagramCtrl.text = prefs.getString('social_instagram') ??
            data?['socialLinks']?['instagram'] ?? '';
        _tiktokCtrl.text = prefs.getString('social_tiktok') ??
            data?['socialLinks']?['tiktok'] ?? '';
      });
    }
  }

  Future<void> _save(String l) async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    final fullPhone = _phoneCtrl.text.trim().isEmpty
        ? ''
        : '${_selectedCountry.code} ${_phoneCtrl.text.trim()}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('social_facebook', _facebookCtrl.text.trim());
    await prefs.setString('social_instagram', _instagramCtrl.text.trim());
    await prefs.setString('social_tiktok', _tiktokCtrl.text.trim());

    final error = await AuthService.updateProfile(
      name: _nameCtrl.text.trim(),
      phone: fullPhone,
      socialLinks: {
        'facebook': _facebookCtrl.text.trim(),
        'instagram': _instagramCtrl.text.trim(),
        'tiktok': _tiktokCtrl.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (error != null)
        _error = error;
      else
        _success = _p(l, 'savedOk');
    });
  }

  void _showCountryPicker(String l) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(children: [
        const SizedBox(height: 12),
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        Text(_p(l, 'chooseCountry'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(),
        Expanded(
            child: ListView.builder(
          itemCount: _countries.length,
          itemBuilder: (_, i) {
            final c = _countries[i];
            final isSelected = c.code == _selectedCountry.code &&
                c.name == _selectedCountry.name;
            return ListTile(
              leading: isSelected
                  ? const Icon(Icons.check, color: Color(0xFFFFD600), size: 18)
                  : const SizedBox(width: 18),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(c.name, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                c.name == 'سوريا'
                    ? _SyriaFlag(size: 28)
                    : Text(c.flag, style: const TextStyle(fontSize: 24)),
              ]),
              subtitle: Text(c.code,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.grey)),
              title: const SizedBox.shrink(),
              tileColor: isSelected ? const Color(0xFFFFFDE7) : null,
              onTap: () {
                setState(() => _selectedCountry = c);
                Navigator.pop(context);
              },
            );
          },
        )),
      ]),
    );
  }

  // ── زر المشاركة في AppBar ──
  Widget _buildShareButton(String l) {
    final isAr = l == 'ar' || l == 'ckb' || l == 'ku';
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: GestureDetector(
        onTap: () => Share.share(_p(l, 'shareMsg')),
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
              child: const Icon(Icons.android, color: Color(0xFF3DDC84), size: 26),
            ),
            const SizedBox(height: 3),
            Text(
              isAr ? 'مشاركة مع' : 'Share with',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            Text(
              isAr ? 'الأصدقاء' : 'Friends',
              style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final l = Localizations.localeOf(context).languageCode;
    final isRtl = l == 'ar' || l == 'ckb';
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = _userData?['photoUrl'] ?? user?.photoURL ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text(_p(l, 'title'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFD600),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        // ── الأيقونة في الجهة اليمنى دائماً ──
        actions: [
          _buildShareButton(l),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── صورة ──
          Center(
              child: Stack(children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: const Color(0xFFFFD600),
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 52, color: Colors.white)
                  : null,
            ),
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFFD600), width: 2)),
                    child: const Icon(Icons.camera_alt,
                        size: 18, color: Colors.black54))),
          ])),
          const SizedBox(height: 8),
          Text(user?.email ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 28),

          // ── الاسم ──
          _buildLabel(_p(l, 'fullName'), isRtl),
          const SizedBox(height: 6),
          _buildField(
              controller: _nameCtrl, hint: _p(l, 'nameHint'), isRtl: isRtl),
          const SizedBox(height: 16),

          // ── البريد (قراءة فقط) ──
          _buildLabel(_p(l, 'email'), isRtl),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14)),
            child: Text(user?.email ?? '',
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),

          // ── رقم الهاتف ──
          _buildLabel(_p(l, 'phone'), isRtl),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 6)
                ]),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: _p(l, 'phoneHint'),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              )),
              GestureDetector(
                onTap: () => _showCountryPicker(l),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: const BoxDecoration(
                      border:
                          Border(left: BorderSide(color: Color(0xFFE5E7EB)))),
                  child: Row(children: [
                    _selectedCountry.name == 'سوريا'
                        ? _SyriaFlag(size: 24)
                        : Text(_selectedCountry.flag,
                            style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Text(_selectedCountry.code,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.grey, size: 20),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── روابط المنصات ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 6)
                ]),
            child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(_p(l, 'socialTitle'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  Text(_p(l, 'socialSub'),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  _buildSocialField(
                      controller: _facebookCtrl,
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      hint: 'Facebook'),
                  const SizedBox(height: 10),
                  _buildSocialField(
                      controller: _instagramCtrl,
                      icon: Icons.camera_alt,
                      color: const Color(0xFFE1306C),
                      hint: 'Instagram'),
                  const SizedBox(height: 10),
                  _buildSocialField(
                      controller: _tiktokCtrl,
                      icon: Icons.music_note,
                      color: const Color(0xFF010101),
                      hint: 'TikTok'),
                ]),
          ),
          const SizedBox(height: 16),

          // ── رسائل ──
          if (_error != null) ...[
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13))),
                ])),
            const SizedBox(height: 12),
          ],
          if (_success != null) ...[
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_success!,
                          style: const TextStyle(
                              color: Colors.green, fontSize: 13))),
                ])),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : () => _save(l),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2.5))
                  : Text(_p(l, 'saveBtn'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildLabel(String text, bool isRtl) {
    return Align(
      alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1F2937))),
    );
  }

  Widget _buildField(
      {required TextEditingController controller,
      required String hint,
      bool isRtl = true,
      TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ]),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
      ),
    );
  }

  Widget _buildSocialField(
      {required TextEditingController controller,
      required IconData icon,
      required Color color,
      required String hint}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: controller,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(12)),
            border: Border(left: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ]),
    );
  }
}

// ── علم سوريا ──
class _SyriaFlag extends StatelessWidget {
  final double size;
  const _SyriaFlag({this.size = 32});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size * 1.5,
        height: size,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CustomPaint(painter: _SyriaFlagPainter())));
  }
}

class _SyriaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stripe = h / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, stripe),
        Paint()..color = const Color(0xFF009000));
    canvas.drawRect(
        Rect.fromLTWH(0, stripe, w, stripe), Paint()..color = Colors.white);
    canvas.drawRect(
        Rect.fromLTWH(0, stripe * 2, w, stripe), Paint()..color = Colors.black);
    final starPaint = Paint()..color = const Color(0xFFCE1126);
    _drawStar(canvas, Offset(w * 0.35, h * 0.5), h * 0.18, starPaint);
    _drawStar(canvas, Offset(w * 0.65, h * 0.5), h * 0.18, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    const pi = 3.14159265358979;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 4 * pi / 5) - pi / 2;
      final innerAngle = outerAngle + 2 * pi / 5;
      final ox = center.dx + r * _cos(outerAngle);
      final oy = center.dy + r * _sin(outerAngle);
      final ix = center.dx + r * 0.4 * _cos(innerAngle);
      final iy = center.dy + r * 0.4 * _sin(innerAngle);
      if (i == 0)
        path.moveTo(ox, oy);
      else
        path.lineTo(ox, oy);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double a) {
    const pi = 3.14159265358979;
    a = a % (2 * pi);
    double r = 1, t = 1;
    for (int i = 1; i <= 8; i++) {
      t *= -a * a / ((2 * i - 1) * (2 * i));
      r += t;
    }
    return r;
  }

  double _sin(double a) {
    double r = a, t = a;
    for (int i = 1; i <= 8; i++) {
      t *= -a * a / ((2 * i) * (2 * i + 1));
      r += t;
    }
    return r;
  }

  @override
  bool shouldRepaint(_) => false;
}
