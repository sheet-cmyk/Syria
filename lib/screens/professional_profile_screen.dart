import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ══════════════════════════════════════════════════════════════
const Map<String, Map<String, String>> _str = {
  'ar': {
    'title':        'ملفي المهني',       'publish':    'حفظ ونشر',
    'publishing':   'جاري النشر...',     'uploading':  'جاري رفع الصور...',
    'success':      'تم نشر ملفك المهني ✓',
    'photo':        'الصورة الشخصية',    'tapToAdd':   'اضغط لإضافة صورة',
    'basicInfo':    'المعلومات الأساسية',
    'fullName':     'الاسم الكامل *',    'nameHint':   'مثال: محمد أحمد',
    'profession':   'اسم المهنة *',      'profHint':   'مثال: نجار، كهربائي...',
    'city':         'المدينة *',         'cityHint':   'مثال: Berlin',
    'phone':        'رقم التواصل *',     'phoneHint':  '+49123456789',
    'bio':          'نبذة تعريفية',      'bioHint':    'اكتب نبذة مختصرة عن نفسك...',
    'experience':   'سنوات الخبرة',      'expHint':    'مثال: 5',
    'services':     'الخدمات التي أقدمها','srvHint':   'صف خدماتك بإيجاز...',
    'workPhotos':   'صور الأعمال السابقة','addPhoto':  'إضافة صورة',
    'maxPhotos':    'الحد الأقصى 8 صور',
    'links':        'الروابط',
    'video':        'رابط فيديو (YouTube / TikTok)', 'videoHint':'https://youtube.com/...',
    'extLink':      'رابط خارجي (اختياري)',           'extHint':  'مثال: موقعك الإلكتروني',
    'social':       'التواصل الاجتماعي',
    'nameErr':      'الاسم مطلوب',       'profErr':    'اسم المهنة مطلوب',
    'cityErr':      'المدينة مطلوبة',    'phoneErr':   'رقم التواصل مطلوب',
    'loginErr':     'يجب تسجيل الدخول أولاً',
    'savedDraft':   'تم حفظ البيانات تلقائياً',
    'republish':    'إعادة النشر',
    'published':    'منشور',            'notPublished':'غير منشور',
  },
  'de': {
    'title':        'Mein Berufsprofil',  'publish':   'Speichern & Veröffentlichen',
    'publishing':   'Wird veröffentlicht...','uploading':'Fotos werden hochgeladen...',
    'success':      'Profil erfolgreich veröffentlicht ✓',
    'photo':        'Profilbild',         'tapToAdd':  'Tippen zum Hinzufügen',
    'basicInfo':    'Grundlegende Informationen',
    'fullName':     'Vollständiger Name *','nameHint':  'Beispiel: Max Müller',
    'profession':   'Berufsbezeichnung *','profHint':  'Beispiel: Schreiner...',
    'city':         'Stadt *',            'cityHint':  'Beispiel: Berlin',
    'phone':        'Kontaktnummer *',    'phoneHint': '+49123456789',
    'bio':          'Über mich',          'bioHint':   'Kurze Beschreibung...',
    'experience':   'Jahre Erfahrung',    'expHint':   'Beispiel: 5',
    'services':     'Meine Dienstleistungen','srvHint': 'Beschreibe deine Leistungen...',
    'workPhotos':   'Fotos früherer Arbeiten','addPhoto':'Foto hinzufügen',
    'maxPhotos':    'Maximal 8 Fotos',
    'links':        'Links',
    'video':        'Video-Link (YouTube / TikTok)','videoHint':'https://youtube.com/...',
    'extLink':      'Externer Link (optional)',    'extHint':  'Beispiel: deine Website',
    'social':       'Soziale Medien',
    'nameErr':      'Name ist erforderlich',       'profErr':  'Beruf ist erforderlich',
    'cityErr':      'Stadt ist erforderlich',      'phoneErr': 'Nummer ist erforderlich',
    'loginErr':     'Bitte zuerst einloggen',
    'savedDraft':   'Daten automatisch gespeichert',
    'republish':    'Neu veröffentlichen',
    'published':    'Veröffentlicht',     'notPublished':'Nicht veröffentlicht',
  },
  'fr': {
    'title':        'Mon profil pro',    'publish':    'Enregistrer & Publier',
    'publishing':   'Publication...',    'uploading':  'Téléchargement...',
    'success':      'Profil publié avec succès ✓',
    'photo':        'Photo de profil',   'tapToAdd':   'Appuyer pour ajouter',
    'basicInfo':    'Informations de base',
    'fullName':     'Nom complet *',     'nameHint':   'Exemple: Jean Dupont',
    'profession':   'Métier *',          'profHint':   'Exemple: Menuisier...',
    'city':         'Ville *',           'cityHint':   'Exemple: Paris',
    'phone':        'Numéro de contact *','phoneHint': '+33123456789',
    'bio':          'À propos de moi',   'bioHint':    'Courte description...',
    'experience':   'Années d\'expérience','expHint':  'Exemple: 5',
    'services':     'Mes services',      'srvHint':    'Décrivez vos services...',
    'workPhotos':   'Photos de travaux', 'addPhoto':   'Ajouter une photo',
    'maxPhotos':    'Maximum 8 photos',
    'links':        'Liens',
    'video':        'Lien vidéo (YouTube / TikTok)','videoHint':'https://youtube.com/...',
    'extLink':      'Lien externe (optionnel)',     'extHint':  'Exemple: votre site',
    'social':       'Réseaux sociaux',
    'nameErr':      'Le nom est requis',  'profErr':   'Le métier est requis',
    'cityErr':      'La ville est requise','phoneErr': 'Le numéro est requis',
    'loginErr':     'Veuillez vous connecter',
    'savedDraft':   'Données sauvegardées automatiquement',
    'republish':    'Republier',
    'published':    'Publié',            'notPublished':'Non publié',
  },
  'sv': {
    'title':        'Min yrkesprofil',   'publish':    'Spara & Publicera',
    'publishing':   'Publicerar...',     'uploading':  'Laddar upp...',
    'success':      'Profilen publicerades ✓',
    'photo':        'Profilbild',        'tapToAdd':   'Tryck för att lägga till',
    'basicInfo':    'Grundläggande information',
    'fullName':     'Fullständigt namn *','nameHint':  'Exempel: Anna Svensson',
    'profession':   'Yrke *',            'profHint':  'Exempel: Snickare...',
    'city':         'Stad *',            'cityHint':  'Exempel: Stockholm',
    'phone':        'Kontaktnummer *',   'phoneHint': '+46123456789',
    'bio':          'Om mig',            'bioHint':   'Kort beskrivning...',
    'experience':   'År erfarenhet',     'expHint':   'Exempel: 5',
    'services':     'Mina tjänster',     'srvHint':   'Beskriv dina tjänster...',
    'workPhotos':   'Foton av tidigare arbeten','addPhoto':'Lägg till foto',
    'maxPhotos':    'Maximalt 8 foton',
    'links':        'Länkar',
    'video':        'Videolänk (YouTube / TikTok)','videoHint':'https://youtube.com/...',
    'extLink':      'Extern länk (valfritt)',      'extHint': 'Exempel: din webbplats',
    'social':       'Sociala medier',
    'nameErr':      'Namn krävs',        'profErr':   'Yrke krävs',
    'cityErr':      'Stad krävs',        'phoneErr':  'Nummer krävs',
    'loginErr':     'Vänligen logga in',
    'savedDraft':   'Data sparad automatiskt',
    'republish':    'Publicera igen',
    'published':    'Publicerad',        'notPublished':'Inte publicerad',
  },
  'uk': {
    'title':        'Мій профіль',       'publish':   'Зберегти та опублікувати',
    'publishing':   'Публікація...',     'uploading': 'Завантаження...',
    'success':      'Профіль опубліковано ✓',
    'photo':        'Фото профілю',      'tapToAdd':  'Натисніть, щоб додати',
    'basicInfo':    'Основна інформація',
    'fullName':     'Повне ім\'я *',     'nameHint':  'Приклад: Іван Петренко',
    'profession':   'Назва професії *',  'profHint':  'Приклад: Тесля...',
    'city':         'Місто *',           'cityHint':  'Приклад: Berlin',
    'phone':        'Номер телефону *',  'phoneHint': '+49123456789',
    'bio':          'Про мене',          'bioHint':   'Коротко про себе...',
    'experience':   'Роки досвіду',      'expHint':   'Приклад: 5',
    'services':     'Мої послуги',       'srvHint':   'Опишіть свої послуги...',
    'workPhotos':   'Фото попередніх робіт','addPhoto':'Додати фото',
    'maxPhotos':    'Максимум 8 фото',
    'links':        'Посилання',
    'video':        'Відео (YouTube / TikTok)','videoHint':'https://youtube.com/...',
    'extLink':      'Зовнішнє посилання',      'extHint':  'Приклад: ваш сайт',
    'social':       'Соціальні мережі',
    'nameErr':      'Ім\'я обов\'язкове', 'profErr':  'Професія обов\'язкова',
    'cityErr':      'Місто обов\'язкове', 'phoneErr': 'Номер обов\'язковий',
    'loginErr':     'Будь ласка, увійдіть',
    'savedDraft':   'Дані збережено автоматично',
    'republish':    'Опублікувати знову',
    'published':    'Опубліковано',       'notPublished':'Не опубліковано',
  },
  'tr': {
    'title':        'Profesyonel Profilim','publish':  'Kaydet & Yayınla',
    'publishing':   'Yayınlanıyor...',   'uploading': 'Fotoğraflar yükleniyor...',
    'success':      'Profil başarıyla yayınlandı ✓',
    'photo':        'Profil Fotoğrafı',  'tapToAdd':  'Eklemek için dokunun',
    'basicInfo':    'Temel Bilgiler',
    'fullName':     'Tam Ad *',          'nameHint':  'Örnek: Ahmet Yılmaz',
    'profession':   'Meslek Adı *',      'profHint':  'Örnek: Marangoz...',
    'city':         'Şehir *',           'cityHint':  'Örnek: Berlin',
    'phone':        'İletişim Numarası *','phoneHint': '+49123456789',
    'bio':          'Hakkımda',          'bioHint':   'Kısa bir tanıtım...',
    'experience':   'Yıl Deneyim',       'expHint':   'Örnek: 5',
    'services':     'Sunduğum Hizmetler','srvHint':   'Hizmetlerinizi açıklayın...',
    'workPhotos':   'Önceki İş Fotoğrafları','addPhoto':'Fotoğraf Ekle',
    'maxPhotos':    'Maksimum 8 fotoğraf',
    'links':        'Bağlantılar',
    'video':        'Video (YouTube / TikTok)','videoHint':'https://youtube.com/...',
    'extLink':      'Harici Bağlantı (isteğe bağlı)','extHint':'Örnek: web siteniz',
    'social':       'Sosyal Medya',
    'nameErr':      'Ad gereklidir',     'profErr':   'Meslek gereklidir',
    'cityErr':      'Şehir gereklidir',  'phoneErr':  'Numara gereklidir',
    'loginErr':     'Lütfen önce giriş yapın',
    'savedDraft':   'Veriler otomatik kaydedildi',
    'republish':    'Yeniden Yayınla',
    'published':    'Yayında',           'notPublished':'Yayında değil',
  },
};

String _s(String l, String k) => _str[l]?[k] ?? _str['ar']![k] ?? k;

// ══════════════════════════════════════════════════════════════
class ProfessionalProfileScreen extends StatefulWidget {
  const ProfessionalProfileScreen({super.key});
  @override
  State<ProfessionalProfileScreen> createState() => _State();
}

class _State extends State<ProfessionalProfileScreen> {
  // controllers
  final _nameCtrl = TextEditingController();
  final _profCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl= TextEditingController();
  final _bioCtrl  = TextEditingController();
  final _expCtrl  = TextEditingController();
  final _srvCtrl  = TextEditingController();
  final _vidCtrl  = TextEditingController();
  final _extCtrl  = TextEditingController();
  final _fbCtrl   = TextEditingController();
  final _igCtrl   = TextEditingController();
  final _ttCtrl   = TextEditingController();
  final _waCtrl   = TextEditingController();

  String  _lang      = 'ar';
  bool    _publishing= false;
  bool    _uploading = false;
  bool    _loading   = true;

  // الصور
  String  _profileUrl= '';   // رابط الصورة الشخصية المحفوظة
  XFile?  _newProfileImg;
  Uint8List? _newProfileImgBytes;
  List<String> _savedWorkUrls = []; // روابط صور الأعمال المحفوظة
  final List<XFile> _newWorkImgs = [];
  final List<Uint8List> _newWorkImgBytes = [];

  // حالة النشر
  String? _publishedAdId; // docId الإعلان المنشور حالياً (null = غير منشور)

  final _picker = ImagePicker();
  static const _cloud  = 'doddemkpy';
  static const _preset = 'alzain';

  @override
  void initState() { super.initState(); _init(); }

  // ── تحميل البيانات المحفوظة ──
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lang = prefs.getString('app_language') ?? 'ar');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { setState(() => _loading = false); return; }

    try {
      // نجيب البيانات من users/{uid}/professional_profile
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .collection('professional_profile').doc('data').get();

      if (doc.exists) {
        final d = doc.data()!;
        _nameCtrl.text  = d['name']       ?? '';
        _profCtrl.text  = d['profession'] ?? '';
        _cityCtrl.text  = d['city']       ?? '';
        _phoneCtrl.text = d['phone']      ?? '';
        _bioCtrl.text   = d['bio']        ?? '';
        _expCtrl.text   = d['experience'] ?? '';
        _srvCtrl.text   = d['services']   ?? '';
        _vidCtrl.text   = d['video']      ?? '';
        _extCtrl.text   = d['extLink']    ?? '';
        final social = d['social'] as Map<String,dynamic>? ?? {};
        _fbCtrl.text = social['facebook']  ?? '';
        _igCtrl.text = social['instagram'] ?? '';
        _ttCtrl.text = social['tiktok']    ?? '';
        _waCtrl.text = social['whatsapp']  ?? '';
        _profileUrl      = d['profileImage'] ?? '';
        _savedWorkUrls   = List<String>.from(d['workImages'] ?? []);
        _publishedAdId   = d['publishedAdId'];
      }
    } catch (_) {}

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl,_profCtrl,_cityCtrl,_phoneCtrl,_bioCtrl,
        _expCtrl,_srvCtrl,_vidCtrl,_extCtrl,_fbCtrl,_igCtrl,_ttCtrl,_waCtrl])
      c.dispose();
    super.dispose();
  }

  bool get _rtl => _lang == 'ar';
  TextAlign     get _ta => _rtl ? TextAlign.right  : TextAlign.left;
  TextDirection get _td => _rtl ? TextDirection.rtl : TextDirection.ltr;

  // ── رفع صورة لـ Cloudinary ──
  Future<String?> _upload(Uint8List bytes, {String filename = 'image.jpg'}) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloud/image/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _preset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final res  = await req.send();
    final body = await res.stream.bytesToString();
    final json = jsonDecode(body);
    if (res.statusCode == 200) return json['secure_url'] as String?;
    return null;
  }

  // ── حفظ البيانات دائماً في users/{uid}/professional_profile ──
  Future<void> _saveDraft({String? adId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users').doc(user.uid)
        .collection('professional_profile').doc('data').set({
      'name':          _nameCtrl.text.trim(),
      'profession':    _profCtrl.text.trim(),
      'city':          _cityCtrl.text.trim(),
      'phone':         _phoneCtrl.text.trim(),
      'bio':           _bioCtrl.text.trim(),
      'experience':    _expCtrl.text.trim(),
      'services':      _srvCtrl.text.trim(),
      'video':         _vidCtrl.text.trim(),
      'extLink':       _extCtrl.text.trim(),
      'social': {
        'facebook':  _fbCtrl.text.trim(),
        'instagram': _igCtrl.text.trim(),
        'tiktok':    _ttCtrl.text.trim(),
        'whatsapp':  _waCtrl.text.trim(),
      },
      'profileImage':  _profileUrl,
      'workImages':    _savedWorkUrls,
      'publishedAdId': adId ?? _publishedAdId,
      'updatedAt':     FieldValue.serverTimestamp(),
    });
  }

  // ── اختيار الصورة الشخصية ──
  Future<void> _pickProfile() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() { _newProfileImg = img; _newProfileImgBytes = bytes; });
    }
  }

  // ── اختيار صور الأعمال ──
  Future<void> _pickWork() async {
    final total = _savedWorkUrls.length + _newWorkImgs.length;
    if (total >= 8) { _snack(_s(_lang,'maxPhotos')); return; }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.camera_alt, color: Color(0xFF0EA5E9)),
          title: const Text('التقاط صورة'),
          onTap: () async {
            Navigator.pop(context);
            final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
            if (img != null) {
              final bytes = await img.readAsBytes();
              setState(() { _newWorkImgs.add(img); _newWorkImgBytes.add(bytes); });
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library, color: Color(0xFF0EA5E9)),
          title: const Text('من المعرض'),
          onTap: () async {
            Navigator.pop(context);
            final remaining = 8 - _savedWorkUrls.length - _newWorkImgs.length;
            final imgs = await _picker.pickMultiImage(imageQuality: 80, limit: remaining);
            if (imgs.isNotEmpty) {
              final bytesList = await Future.wait(imgs.map((i) => i.readAsBytes()));
              setState(() { _newWorkImgs.addAll(imgs); _newWorkImgBytes.addAll(bytesList); });
            }
          },
        ),
        const SizedBox(height: 8),
      ])),
    );
  }

  // ── النشر الذكي ──
  Future<void> _publish() async {
    final l = _lang;
    if (_nameCtrl.text.trim().isEmpty)  { _snack(_s(l,'nameErr'));  return; }
    if (_profCtrl.text.trim().isEmpty)  { _snack(_s(l,'profErr'));  return; }
    if (_cityCtrl.text.trim().isEmpty)  { _snack(_s(l,'cityErr'));  return; }
    if (_phoneCtrl.text.trim().isEmpty) { _snack(_s(l,'phoneErr')); return; }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { _snack(_s(l,'loginErr')); return; }

    setState(() { _publishing = true; _uploading = true; });

    try {
      // 1. رفع الصورة الشخصية الجديدة إن وجدت
      if (_newProfileImgBytes != null) {
        _profileUrl = await _upload(_newProfileImgBytes!, filename: _newProfileImg!.name) ?? _profileUrl;
        _newProfileImg = null;
        _newProfileImgBytes = null;
      }

      // 2. رفع صور الأعمال الجديدة
      for (int i = 0; i < _newWorkImgBytes.length; i++) {
        final url = await _upload(_newWorkImgBytes[i], filename: _newWorkImgs[i].name);
        if (url != null) _savedWorkUrls.add(url);
      }
      _newWorkImgs.clear();
      _newWorkImgBytes.clear();
      setState(() => _uploading = false);

      // 3. حذف الإعلان القديم إن وجد
      if (_publishedAdId != null) {
        try {
          await FirebaseFirestore.instance.collection('ads').doc(_publishedAdId).delete();
        } catch (_) {}
      }

      // 4. نشر إعلان جديد
      final ref = await FirebaseFirestore.instance.collection('ads').add({
        'isProfessional': true,
        'type':           'professional_profile',
        'category':       'الملفات المهنية',
        'subCategory':    _profCtrl.text.trim(),
        'title':          _nameCtrl.text.trim(),
        'profession':     _profCtrl.text.trim(),
        'city':           _cityCtrl.text.trim(),
        'phone':          _phoneCtrl.text.trim(),
        'price':          '',
        'description':    _bioCtrl.text.trim(),
        'experience':     _expCtrl.text.trim(),
        'services':       _srvCtrl.text.trim(),
        'profileImage':   _profileUrl,
        'images':         List<String>.from(_savedWorkUrls),
        'videoUrl':       _vidCtrl.text.trim(),
        'externalLink':   _extCtrl.text.trim(),
        'social': {
          'facebook':  _fbCtrl.text.trim(),
          'instagram': _igCtrl.text.trim(),
          'tiktok':    _ttCtrl.text.trim(),
          'whatsapp':  _waCtrl.text.trim(),
        },
        'userId':    user.uid,
        'userName':  user.displayName ?? '',
        'userPhoto': user.photoURL    ?? '',
        'lang':      l,
        'status':    'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. حفظ دائم في ملف المستخدم مع الـ adId الجديد
      _publishedAdId = ref.id;
      await _saveDraft(adId: ref.id);

      if (!mounted) return;
      setState(() => _publishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_s(l,'success')), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() { _publishing = false; _uploading = false; });
      _snack('Error: ${e.toString().substring(0, e.toString().length.clamp(0,80))}');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l    = _lang;
    final busy = _publishing || _uploading;
    final totalPhotos = _savedWorkUrls.length + _newWorkImgs.length;

    if (_loading) return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9))));

    return Directionality(
      textDirection: _td,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9FF),
        appBar: AppBar(
          title: Text(_s(l,'title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // حفظ تلقائي عند الخروج
              await _saveDraft();
              if (mounted) Navigator.pop(context);
            },
          ),
          actions: [
            // مؤشر حالة النشر
            Center(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _publishedAdId != null
                    ? const Color(0xFF10B981).withOpacity(0.12)
                    : Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  _publishedAdId != null ? Icons.check_circle : Icons.circle_outlined,
                  size: 12,
                  color: _publishedAdId != null ? const Color(0xFF10B981) : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _publishedAdId != null ? _s(l,'published') : _s(l,'notPublished'),
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: _publishedAdId != null ? const Color(0xFF10B981) : Colors.grey,
                  ),
                ),
              ]),
            )),
            // زر حفظ ونشر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: ElevatedButton(
                onPressed: busy ? null : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: busy
                    ? const SizedBox(width:16,height:16,
                        child: CircularProgressIndicator(color:Colors.white,strokeWidth:2))
                    : Text(
                        _publishedAdId != null ? _s(l,'republish') : _s(l,'publish'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(children: [

            // 1. الصورة الشخصية
            _sec(Icons.person, const Color(0xFF0EA5E9), _s(l,'photo'),
              Center(child: GestureDetector(
                onTap: _pickProfile,
                child: Stack(children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0EA5E9).withOpacity(0.1),
                      border: Border.all(color: const Color(0xFF0EA5E9), width: 2),
                    ),
                    child: _newProfileImgBytes != null
                        ? ClipOval(child: Image.memory(_newProfileImgBytes!, fit: BoxFit.cover))
                        : _profileUrl.isNotEmpty
                            ? ClipOval(child: Image.network(_profileUrl, fit: BoxFit.cover,
                                errorBuilder:(_,__,___)=>const Icon(Icons.person,size:38,color:Color(0xFF0EA5E9))))
                            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Icon(Icons.person, size: 38, color: Color(0xFF0EA5E9)),
                                Text(_s(l,'tapToAdd'),
                                    style: const TextStyle(fontSize: 9, color: Color(0xFF0EA5E9)),
                                    textAlign: TextAlign.center),
                              ]),
                  ),
                  Positioned(bottom:0,right:0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color:Color(0xFF0EA5E9),shape:BoxShape.circle),
                      child: const Icon(Icons.camera_alt,color:Colors.white,size:13))),
                ]),
              )),
            ),

            const SizedBox(height: 10),

            // 2. المعلومات الأساسية
            _sec(Icons.badge, const Color(0xFF0EA5E9), _s(l,'basicInfo'),
              Column(children: [
                _f(_nameCtrl,  _s(l,'fullName'),   _s(l,'nameHint')),
                _f(_profCtrl,  _s(l,'profession'), _s(l,'profHint')),
                _f(_cityCtrl,  _s(l,'city'),       _s(l,'cityHint')),
                _f(_phoneCtrl, _s(l,'phone'),      _s(l,'phoneHint'),
                    keyboard: TextInputType.phone, dir: TextDirection.ltr),
              ]),
            ),

            const SizedBox(height: 10),

            // 3. نبذة
            _sec(Icons.info_outline, const Color(0xFF6366F1), _s(l,'bio'),
              _f(_bioCtrl, _s(l,'bio'), _s(l,'bioHint'), lines: 3)),

            const SizedBox(height: 10),

            // 4. الخبرة
            _sec(Icons.workspace_premium, const Color(0xFFF59E0B), _s(l,'experience'),
              _f(_expCtrl, _s(l,'experience'), _s(l,'expHint'),
                  keyboard: TextInputType.number)),

            const SizedBox(height: 10),

            // 5. الخدمات
            _sec(Icons.handshake, const Color(0xFF10B981), _s(l,'services'),
              _f(_srvCtrl, _s(l,'services'), _s(l,'srvHint'), lines: 3)),

            const SizedBox(height: 10),

            // 6. صور الأعمال
            _sec(Icons.photo_library, const Color(0xFF8B5CF6),
              '${_s(l,"workPhotos")} ($totalPhotos/8)',
              Column(children: [
                // الصور المحفوظة
                if (_savedWorkUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _savedWorkUrls.length,
                      itemBuilder: (_, i) => Stack(children: [
                        Container(
                          width:85,height:85,
                          margin:const EdgeInsets.only(left:8),
                          decoration: BoxDecoration(
                            borderRadius:BorderRadius.circular(10),
                            image:DecorationImage(
                                image:NetworkImage(_savedWorkUrls[i]),fit:BoxFit.cover),
                          ),
                        ),
                        Positioned(top:2,right:10,
                          child:GestureDetector(
                            onTap:()=>setState(()=>_savedWorkUrls.removeAt(i)),
                            child:Container(
                              width:20,height:20,
                              decoration:const BoxDecoration(color:Colors.red,shape:BoxShape.circle),
                              child:const Icon(Icons.close,color:Colors.white,size:13)))),
                      ]),
                    ),
                  ),
                  const SizedBox(height:8),
                ],
                // الصور الجديدة
                if (_newWorkImgs.isNotEmpty) ...[
                  SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newWorkImgs.length,
                      itemBuilder: (_, i) => Stack(children: [
                        Container(
                          width:85,height:85,
                          margin:const EdgeInsets.only(left:8),
                          decoration:BoxDecoration(
                            borderRadius:BorderRadius.circular(10),
                            border:Border.all(color:const Color(0xFF8B5CF6),width:2),
                            image:DecorationImage(
                                image:MemoryImage(_newWorkImgBytes[i]),fit:BoxFit.cover),
                          ),
                        ),
                        Positioned(top:2,right:10,
                          child:GestureDetector(
                            onTap:()=>setState((){_newWorkImgs.removeAt(i);_newWorkImgBytes.removeAt(i);}),
                            child:Container(
                              width:20,height:20,
                              decoration:const BoxDecoration(color:Colors.red,shape:BoxShape.circle),
                              child:const Icon(Icons.close,color:Colors.white,size:13)))),
                      ]),
                    ),
                  ),
                  const SizedBox(height:8),
                ],
                // زر الإضافة
                GestureDetector(
                  onTap: _pickWork,
                  child:Container(
                    width:double.infinity,
                    padding:const EdgeInsets.symmetric(vertical:12),
                    decoration:BoxDecoration(
                      color:const Color(0xFF8B5CF6).withOpacity(0.06),
                      borderRadius:BorderRadius.circular(10),
                      border:Border.all(color:const Color(0xFF8B5CF6).withOpacity(0.3)),
                    ),
                    child:Column(children:[
                      const Icon(Icons.add_photo_alternate_outlined,color:Color(0xFF8B5CF6),size:26),
                      const SizedBox(height:4),
                      Text(_s(l,'addPhoto'),
                          style:const TextStyle(color:Color(0xFF8B5CF6),fontWeight:FontWeight.w600,fontSize:13)),
                    ]),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 10),

            // 7. الروابط
            _sec(Icons.link, const Color(0xFFEF4444), _s(l,'links'),
              Column(children: [
                _f(_vidCtrl, _s(l,'video'),   _s(l,'videoHint'),
                    dir: TextDirection.ltr, keyboard: TextInputType.url),
                _f(_extCtrl, _s(l,'extLink'), _s(l,'extHint'),
                    dir: TextDirection.ltr, keyboard: TextInputType.url),
              ]),
            ),

            const SizedBox(height: 10),

            // 8. التواصل الاجتماعي
            _sec(Icons.share, const Color(0xFF1877F2), _s(l,'social'),
              Column(children: [
                _soc(_fbCtrl,'Facebook', Icons.facebook,   const Color(0xFF1877F2)),
                _soc(_igCtrl,'Instagram',Icons.camera_alt, const Color(0xFFE1306C)),
                _soc(_ttCtrl,'TikTok',   Icons.music_note, const Color(0xFF374151)),
                _soc(_waCtrl,'WhatsApp', Icons.chat,       const Color(0xFF25D366)),
              ]),
            ),

            const SizedBox(height: 20),

            // زر النشر السفلي
            SizedBox(
              width:double.infinity, height:54,
              child:ElevatedButton(
                onPressed: busy ? null : _publish,
                style:ElevatedButton.styleFrom(
                  backgroundColor:const Color(0xFF0EA5E9),
                  foregroundColor:Colors.white,
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
                  elevation:0,
                ),
                child: busy
                    ? Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                        const SizedBox(width:20,height:20,
                            child:CircularProgressIndicator(color:Colors.white,strokeWidth:2.5)),
                        const SizedBox(width:10),
                        Text(_uploading?_s(l,'uploading'):_s(l,'publishing'),
                            style:const TextStyle(fontWeight:FontWeight.bold)),
                      ])
                    : Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                        const Icon(Icons.verified_user,size:20),
                        const SizedBox(width:8),
                        Text(
                          _publishedAdId != null ? _s(l,'republish') : _s(l,'publish'),
                          style:const TextStyle(fontWeight:FontWeight.bold,fontSize:15)),
                      ]),
              ),
            ),

            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _sec(IconData icon, Color color, String title, Widget child) => Container(
    decoration:BoxDecoration(
      color:Colors.white,
      borderRadius:BorderRadius.circular(14),
      boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.04),blurRadius:6)],
    ),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(
        padding:const EdgeInsets.symmetric(horizontal:14,vertical:11),
        decoration:BoxDecoration(
          color:color.withOpacity(0.07),
          borderRadius:const BorderRadius.vertical(top:Radius.circular(14)),
        ),
        child:Row(children:[
          Icon(icon,color:color,size:18),
          const SizedBox(width:8),
          Expanded(child:Text(title,
              style:TextStyle(fontSize:13,fontWeight:FontWeight.w700,color:color))),
        ]),
      ),
      Padding(padding:const EdgeInsets.all(12),child:child),
    ]),
  );

  Widget _f(TextEditingController ctrl, String label, String hint,
      {int lines=1, TextInputType keyboard=TextInputType.text, TextDirection? dir}) =>
    Padding(
      padding:const EdgeInsets.only(bottom:10),
      child:Column(crossAxisAlignment:_rtl?CrossAxisAlignment.end:CrossAxisAlignment.start,children:[
        Text(label,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w600,color:Color(0xFF374151))),
        const SizedBox(height:5),
        TextField(
          controller:ctrl, maxLines:lines,
          textAlign:_ta, textDirection:dir??_td, keyboardType:keyboard,
          decoration:InputDecoration(
            hintText:hint,
            hintStyle:TextStyle(color:Colors.grey.shade400,fontSize:13),
            filled:true,fillColor:Colors.grey.shade50,
            border:        OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:const BorderSide(color:Color(0xFF0EA5E9),width:2)),
            contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:11),
          ),
        ),
      ]),
    );

  Widget _soc(TextEditingController ctrl, String name, IconData icon, Color color) =>
    Padding(
      padding:const EdgeInsets.only(bottom:10),
      child:TextField(
        controller:ctrl, textDirection:TextDirection.ltr, keyboardType:TextInputType.url,
        decoration:InputDecoration(
          hintText:'https://$name.com/...',
          hintStyle:TextStyle(color:Colors.grey.shade400,fontSize:13),
          prefixIcon:Container(
            margin:const EdgeInsets.all(7),
            padding:const EdgeInsets.all(5),
            decoration:BoxDecoration(color:color.withOpacity(0.1),borderRadius:BorderRadius.circular(7)),
            child:Icon(icon,color:color,size:17)),
          filled:true,fillColor:Colors.grey.shade50,
          border:        OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:color,width:2)),
          contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:11),
        ),
      ),
    );
}
