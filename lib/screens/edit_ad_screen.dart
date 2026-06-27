import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../data/data.dart';
import '../utils/thousands_formatter.dart';

// ═══════════════════════════════════════════════════════════════
//  متغيرات الدول والمحافظات
// ═══════════════════════════════════════════════════════════════
const int _maxPhotos = 5;

class _WaCountry {
  final String name;
  final String flag;
  final String code;
  const _WaCountry(this.name, this.flag, this.code);
}

const List<_WaCountry> _waCountries = [
  _WaCountry('ألمانيا', '🇩🇪', '+49'),
  _WaCountry('سوريا', '🇸🇾', '+963'),
  _WaCountry('العراق', '🇮🇶', '+964'),
  _WaCountry('السعودية', '🇸🇦', '+966'),
  _WaCountry('الإمارات', '🇦🇪', '+971'),
  _WaCountry('الأردن', '🇯🇴', '+962'),
  _WaCountry('لبنان', '🇱🇧', '+961'),
  _WaCountry('مصر', '🇪🇬', '+20'),
  _WaCountry('تركيا', '🇹🇷', '+90'),
  _WaCountry('هولندا', '🇳🇱', '+31'),
  _WaCountry('السويد', '🇸🇪', '+46'),
  _WaCountry('النمسا', '🇦🇹', '+43'),
  _WaCountry('بلجيكا', '🇧🇪', '+32'),
  _WaCountry('فرنسا', '🇫🇷', '+33'),
  _WaCountry('المملكة المتحدة', '🇬🇧', '+44'),
  _WaCountry('الولايات المتحدة', '🇺🇸', '+1'),
  _WaCountry('كندا', '🇨🇦', '+1'),
  _WaCountry('أستراليا', '🇦🇺', '+61'),
  _WaCountry('سويسرا', '🇨🇭', '+41'),
  _WaCountry('الدنمارك', '🇩🇰', '+45'),
  _WaCountry('النرويج', '🇳🇴', '+47'),
  _WaCountry('فنلندا', '🇫🇮', '+358'),
  _WaCountry('بولندا', '🇵🇱', '+48'),
  _WaCountry('إيطاليا', '🇮🇹', '+39'),
  _WaCountry('إسبانيا', '🇪🇸', '+34'),
  _WaCountry('البرتغال', '🇵🇹', '+351'),
  _WaCountry('اليونان', '🇬🇷', '+30'),
  _WaCountry('رومانيا', '🇷🇴', '+40'),
  _WaCountry('المغرب', '🇲🇦', '+212'),
  _WaCountry('الجزائر', '🇩🇿', '+213'),
  _WaCountry('تونس', '🇹🇳', '+216'),
  _WaCountry('ليبيا', '🇱🇾', '+218'),
  _WaCountry('اليمن', '🇾🇪', '+967'),
  _WaCountry('سلطنة عُمان', '🇴🇲', '+968'),
  _WaCountry('قطر', '🇶🇦', '+974'),
  _WaCountry('الكويت', '🇰🇼', '+965'),
  _WaCountry('البحرين', '🇧🇭', '+973'),
  _WaCountry('السودان', '🇸🇩', '+249'),
  _WaCountry('الصومال', '🇸🇴', '+252'),
  _WaCountry('أفغانستان', '🇦🇫', '+93'),
  _WaCountry('إيران', '🇮🇷', '+98'),
  _WaCountry('باكستان', '🇵🇰', '+92'),
  _WaCountry('الهند', '🇮🇳', '+91'),
  _WaCountry('روسيا', '🇷🇺', '+7'),
  _WaCountry('أوكرانيا', '🇺🇦', '+380'),
  _WaCountry('البوسنة', '🇧🇦', '+387'),
  _WaCountry('ألبانيا', '🇦🇱', '+355'),
  _WaCountry('كوسوفو', '🇽🇰', '+383'),
  _WaCountry('المجر', '🇭🇺', '+36'),
  _WaCountry('التشيك', '🇨🇿', '+420'),
  _WaCountry('سلوفاكيا', '🇸🇰', '+421'),
  _WaCountry('كرواتيا', '🇭🇷', '+385'),
  _WaCountry('صربيا', '🇷🇸', '+381'),
  _WaCountry('إندونيسيا', '🇮🇩', '+62'),
  _WaCountry('ماليزيا', '🇲🇾', '+60'),
  _WaCountry('الصين', '🇨🇳', '+86'),
  _WaCountry('اليابان', '🇯🇵', '+81'),
  _WaCountry('كوريا الجنوبية', '🇰🇷', '+82'),
  _WaCountry('البرازيل', '🇧🇷', '+55'),
  _WaCountry('الأرجنتين', '🇦🇷', '+54'),
  _WaCountry('المكسيك', '🇲🇽', '+52'),
  _WaCountry('جنوب أفريقيا', '🇿🇦', '+27'),
  _WaCountry('نيجيريا', '🇳🇬', '+234'),
  _WaCountry('كينيا', '🇰🇪', '+254'),
  _WaCountry('إثيوبيا', '🇪🇹', '+251'),
];

const List<String> _iraqGovernorates = [
  'دمشق',
  'ريف دمشق',
  'حلب',
  'حمص',
  'حماة',
  'اللاذقية',
  'طرطوس',
  'إدلب',
  'دير الزور',
  'الرقة',
  'الحسكة',
  'القنيطرة',
  'درعا',
  'السويداء',
];

// ═══════════════════════════════════════════════════════════════
//  نصوص الترجمة لشاشة تعديل الإعلان
// ═══════════════════════════════════════════════════════════════
const Map<String, Map<String, String>> _editAdStrings = {
  'ar': {
    'editAd': 'تعديل الإعلان',
    'saveChanges': 'حفظ التعديلات',
    'sell': 'أبيع',
    'search': 'أبحث',
    'photos': 'الصور',
    'addPhoto': 'إضافة',
    'main': 'رئيسية',
    'adTitle': 'عنوان الإعلان *',
    'titleHint': 'مثال: آيفون 15 برو 256GB',
    'category': 'القسم *',
    'chooseCategory': 'اختر القسم',
    'description': 'الوصف',
    'descHint': 'اكتب وصفاً تفصيلياً للإعلان...',
    'videoLink': 'رابط فيديو المنتج (اختياري)',
    'videoHint': 'ضع رابط فيديو المنتج هنا (YouTube, TikTok...)',
    'price': 'السعر',
    'condition': 'الحالة',
    'new': 'جديد',
    'likeNew': 'شبه جديد',
    'used': 'مستعمل',
    'gift': 'هدية',
    'location': 'الموقع *',
    'cityHint': 'اسم المدينة (مثال: Berlin)',
    'zipHint': 'الرمز البريدي (PLZ — مثال: 10115)',
    'streetHint': 'الشارع (اختياري)',
    'shareTitle': 'شارك الإعلان على (اختياري)',
    'shareSubtitle': 'اضغط على المنصة لإضافة رابطك',
    'saving': 'جاري الحفظ...',
    'uploadingImages': 'جاري رفع الصور...',
    'saveSuccess': 'تم تعديل الإعلان بنجاح ✓',
    'maxPhotos': 'الحد الأقصى 5 صور',
    'takePhoto': 'التقاط صورة',
    'fromGallery': 'اختيار من المعرض',
    'titleMin': 'عنوان الإعلان يجب أن يكون 10 أحرف على الأقل',
    'chooseSection': 'يرجى اختيار القسم',
    'enterCityZip': 'يرجى إدخال المدينة والرمز البريدي',
    'priceType': 'نوع السعر',
    'fixed': 'سعر ثابت',
    'negotiable': 'قابل للتفاوض',
    'freeGift': 'هدية مجانية',
    'cancel': 'إلغاء',
    'saveBtn': 'حفظ',
    'chooseSection2': 'اختر القسم',
    'general': 'عام',
    'whatsapp': 'واتساب',
    'telegram': 'تيليغرام',
    'facebook': 'فيسبوك',
    'instagram': 'إنستغرام',
    'linkHint': 'رابط {platform}',
    'free': 'مجاني',
    'existingPhotos': 'الصور الحالية',
    'newPhotos': 'صور جديدة',
    'deletePhoto': 'حذف الصورة',
  },
  'de': {
    'editAd': 'Anzeige bearbeiten',
    'saveChanges': 'Änderungen speichern',
    'sell': 'Verkaufen',
    'search': 'Suchen',
    'photos': 'Fotos',
    'addPhoto': 'Hinzufügen',
    'main': 'Haupt',
    'adTitle': 'Anzeigentitel *',
    'titleHint': 'Beispiel: iPhone 15 Pro 256GB',
    'category': 'Kategorie *',
    'chooseCategory': 'Kategorie wählen',
    'description': 'Beschreibung',
    'descHint': 'Schreibe eine detaillierte Beschreibung...',
    'videoLink': 'Produkt-Video-Link (optional)',
    'videoHint': 'Füge hier deinen Video-Link ein (YouTube, TikTok...)',
    'price': 'Preis',
    'condition': 'Zustand',
    'new': 'Neu',
    'likeNew': 'Wie neu',
    'used': 'Gebraucht',
    'gift': 'Geschenk',
    'location': 'Standort *',
    'cityHint': 'Stadtname (z.B.: Berlin)',
    'zipHint': 'Postleitzahl (PLZ — z.B.: 10115)',
    'streetHint': 'Straße (optional)',
    'shareTitle': 'Anzeige teilen auf (optional)',
    'shareSubtitle': 'Tippe auf eine Plattform, um deinen Link hinzuzufügen',
    'saving': 'Wird gespeichert...',
    'uploadingImages': 'Fotos werden hochgeladen...',
    'saveSuccess': 'Anzeige erfolgreich aktualisiert ✓',
    'maxPhotos': 'Maximal 5 Fotos erlaubt',
    'takePhoto': 'Foto aufnehmen',
    'fromGallery': 'Aus Galerie auswählen',
    'titleMin': 'Der Titel muss mindestens 10 Zeichen lang sein',
    'chooseSection': 'Bitte wähle eine Kategorie',
    'enterCityZip': 'Bitte Stadt und Postleitzahl eingeben',
    'priceType': 'Preisart',
    'fixed': 'Festpreis',
    'negotiable': 'Verhandelbar',
    'freeGift': 'Kostenlos/Verschenken',
    'cancel': 'Abbrechen',
    'saveBtn': 'Speichern',
    'chooseSection2': 'Kategorie wählen',
    'general': 'Allgemein',
    'whatsapp': 'WhatsApp',
    'telegram': 'Telegram',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'linkHint': '{platform}-Link',
    'free': 'Kostenlos',
    'existingPhotos': 'Vorhandene Fotos',
    'newPhotos': 'Neue Fotos',
    'deletePhoto': 'Foto löschen',
  },
  'fr': {
    'editAd': 'Modifier l\'annonce',
    'saveChanges': 'Enregistrer les modifications',
    'sell': 'Je vends',
    'search': 'Je cherche',
    'photos': 'Photos',
    'addPhoto': 'Ajouter',
    'main': 'Principal',
    'adTitle': 'Titre de l\'annonce *',
    'titleHint': 'Exemple: iPhone 15 Pro 256Go',
    'category': 'Catégorie *',
    'chooseCategory': 'Choisir une catégorie',
    'description': 'Description',
    'descHint': 'Rédigez une description détaillée...',
    'videoLink': 'Lien vidéo du produit (optionnel)',
    'videoHint': 'Collez le lien vidéo ici (YouTube, TikTok...)',
    'price': 'Prix',
    'condition': 'État',
    'new': 'Neuf',
    'likeNew': 'Comme neuf',
    'used': 'Occasion',
    'gift': 'Don',
    'location': 'Localisation *',
    'cityHint': 'Nom de la ville (ex: Berlin)',
    'zipHint': 'Code postal (ex: 10115)',
    'streetHint': 'Rue (optionnel)',
    'shareTitle': 'Partager l\'annonce sur (optionnel)',
    'shareSubtitle': 'Appuyez sur une plateforme pour ajouter votre lien',
    'saving': 'Enregistrement...',
    'uploadingImages': 'Téléchargement des photos...',
    'saveSuccess': 'Annonce mise à jour ✓',
    'maxPhotos': 'Maximum 5 photos autorisées',
    'takePhoto': 'Prendre une photo',
    'fromGallery': 'Choisir depuis la galerie',
    'titleMin': 'Le titre doit comporter au moins 10 caractères',
    'chooseSection': 'Veuillez choisir une catégorie',
    'enterCityZip': 'Veuillez entrer la ville et le code postal',
    'priceType': 'Type de prix',
    'fixed': 'Prix fixe',
    'negotiable': 'Négociable',
    'freeGift': 'Gratuit / Don',
    'cancel': 'Annuler',
    'saveBtn': 'Enregistrer',
    'chooseSection2': 'Choisir une catégorie',
    'general': 'Général',
    'whatsapp': 'WhatsApp',
    'telegram': 'Telegram',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'linkHint': 'Lien {platform}',
    'free': 'Gratuit',
    'existingPhotos': 'Photos existantes',
    'newPhotos': 'Nouvelles photos',
    'deletePhoto': 'Supprimer la photo',
  },
  'sv': {
    'editAd': 'Redigera annons',
    'saveChanges': 'Spara ändringar',
    'sell': 'Säljer',
    'search': 'Söker',
    'photos': 'Foton',
    'addPhoto': 'Lägg till',
    'main': 'Huvud',
    'adTitle': 'Annonsrubrik *',
    'titleHint': 'Exempel: iPhone 15 Pro 256GB',
    'category': 'Kategori *',
    'chooseCategory': 'Välj kategori',
    'description': 'Beskrivning',
    'descHint': 'Skriv en detaljerad beskrivning...',
    'videoLink': 'Produktvideolänk (valfritt)',
    'videoHint': 'Klistra in videolänken här (YouTube, TikTok...)',
    'price': 'Pris',
    'condition': 'Skick',
    'new': 'Ny',
    'likeNew': 'Som ny',
    'used': 'Begagnad',
    'gift': 'Gåva',
    'location': 'Plats *',
    'cityHint': 'Stadsnamn (t.ex.: Berlin)',
    'zipHint': 'Postnummer (t.ex.: 10115)',
    'streetHint': 'Gata (valfritt)',
    'shareTitle': 'Dela annonsen på (valfritt)',
    'shareSubtitle': 'Tryck på en plattform för att lägga till din länk',
    'saving': 'Sparar...',
    'uploadingImages': 'Laddar upp foton...',
    'saveSuccess': 'Annonsen uppdaterades ✓',
    'maxPhotos': 'Maximalt 5 foton tillåtna',
    'takePhoto': 'Ta foto',
    'fromGallery': 'Välj från galleri',
    'titleMin': 'Rubriken måste vara minst 10 tecken',
    'chooseSection': 'Välj en kategori',
    'enterCityZip': 'Ange stad och postnummer',
    'priceType': 'Pristyp',
    'fixed': 'Fast pris',
    'negotiable': 'Förhandlingsbart',
    'freeGift': 'Gratis / Gåva',
    'cancel': 'Avbryt',
    'saveBtn': 'Spara',
    'chooseSection2': 'Välj kategori',
    'general': 'Allmänt',
    'whatsapp': 'WhatsApp',
    'telegram': 'Telegram',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'linkHint': '{platform}-länk',
    'free': 'Gratis',
    'existingPhotos': 'Befintliga foton',
    'newPhotos': 'Nya foton',
    'deletePhoto': 'Ta bort foto',
  },
  'uk': {
    'editAd': 'Редагувати оголошення',
    'saveChanges': 'Зберегти зміни',
    'sell': 'Продаю',
    'search': 'Шукаю',
    'photos': 'Фото',
    'addPhoto': 'Додати',
    'main': 'Головне',
    'adTitle': 'Заголовок оголошення *',
    'titleHint': 'Приклад: iPhone 15 Pro 256GB',
    'category': 'Категорія *',
    'chooseCategory': 'Оберіть категорію',
    'description': 'Опис',
    'descHint': 'Напишіть детальний опис...',
    'videoLink': 'Посилання на відео (необов\'язково)',
    'videoHint': 'Вставте посилання на відео (YouTube, TikTok...)',
    'price': 'Ціна',
    'condition': 'Стан',
    'new': 'Нове',
    'likeNew': 'Як нове',
    'used': 'Вживане',
    'gift': 'Подарунок',
    'location': 'Місцезнаходження *',
    'cityHint': 'Назва міста (напр.: Berlin)',
    'zipHint': 'Поштовий індекс (напр.: 10115)',
    'streetHint': 'Вулиця (необов\'язково)',
    'shareTitle': 'Поділитися оголошенням (необов\'язково)',
    'shareSubtitle': 'Натисніть на платформу, щоб додати посилання',
    'saving': 'Збереження...',
    'uploadingImages': 'Завантаження фото...',
    'saveSuccess': 'Оголошення оновлено ✓',
    'maxPhotos': 'Максимум 5 фото',
    'takePhoto': 'Зробити фото',
    'fromGallery': 'Вибрати з галереї',
    'titleMin': 'Заголовок має містити щонайменше 10 символів',
    'chooseSection': 'Будь ласка, оберіть категорію',
    'enterCityZip': 'Введіть місто та поштовий індекс',
    'priceType': 'Тип ціни',
    'fixed': 'Фіксована ціна',
    'negotiable': 'Договірна',
    'freeGift': 'Безкоштовно / Подарунок',
    'cancel': 'Скасувати',
    'saveBtn': 'Зберегти',
    'chooseSection2': 'Оберіть категорію',
    'general': 'Загальне',
    'whatsapp': 'WhatsApp',
    'telegram': 'Telegram',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'linkHint': 'Посилання {platform}',
    'free': 'Безкоштовно',
    'existingPhotos': 'Наявні фото',
    'newPhotos': 'Нові фото',
    'deletePhoto': 'Видалити фото',
  },
  'tr': {
    'editAd': 'İlanı Düzenle',
    'saveChanges': 'Değişiklikleri Kaydet',
    'sell': 'Satıyorum',
    'search': 'Arıyorum',
    'photos': 'Fotoğraflar',
    'addPhoto': 'Ekle',
    'main': 'Ana',
    'adTitle': 'İlan Başlığı *',
    'titleHint': 'Örnek: iPhone 15 Pro 256GB',
    'category': 'Kategori *',
    'chooseCategory': 'Kategori seç',
    'description': 'Açıklama',
    'descHint': 'Detaylı bir açıklama yazın...',
    'videoLink': 'Ürün video linki (isteğe bağlı)',
    'videoHint': 'Video linkini buraya yapıştırın (YouTube, TikTok...)',
    'price': 'Fiyat',
    'condition': 'Durum',
    'new': 'Sıfır',
    'likeNew': 'Sıfır gibi',
    'used': 'İkinci el',
    'gift': 'Hediye',
    'location': 'Konum *',
    'cityHint': 'Şehir adı (örn: Berlin)',
    'zipHint': 'Posta kodu (örn: 10115)',
    'streetHint': 'Sokak (isteğe bağlı)',
    'shareTitle': 'İlanı paylaş (isteğe bağlı)',
    'shareSubtitle': 'Link eklemek için platforma tıklayın',
    'saving': 'Kaydediliyor...',
    'uploadingImages': 'Fotoğraflar yükleniyor...',
    'saveSuccess': 'İlan güncellendi ✓',
    'maxPhotos': 'En fazla 5 fotoğraf yükleyebilirsiniz',
    'takePhoto': 'Fotoğraf çek',
    'fromGallery': 'Galeriden seç',
    'titleMin': 'Başlık en az 10 karakter olmalıdır',
    'chooseSection': 'Lütfen bir kategori seçin',
    'enterCityZip': 'Lütfen şehir ve posta kodunu girin',
    'priceType': 'Fiyat türü',
    'fixed': 'Sabit fiyat',
    'negotiable': 'Pazarlıklı',
    'freeGift': 'Ücretsiz / Hediye',
    'cancel': 'İptal',
    'saveBtn': 'Kaydet',
    'chooseSection2': 'Kategori seç',
    'general': 'Genel',
    'whatsapp': 'WhatsApp',
    'telegram': 'Telegram',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'linkHint': '{platform} linki',
    'free': 'Ücretsiz',
    'existingPhotos': 'Mevcut fotoğraflar',
    'newPhotos': 'Yeni fotoğraflar',
    'deletePhoto': 'Fotoğrafı sil',
  },
};

String _s(String langCode, String key) {
  return _editAdStrings[langCode]?[key] ?? _editAdStrings['ar']![key] ?? key;
}

// ═══════════════════════════════════════════════════════════════
class EditAdScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> adData;

  const EditAdScreen({
    super.key,
    required this.docId,
    required this.adData,
  });

  @override
  State<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  String? _selectedGovernorate;
  final _videoCtrl = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubCategory;
  String _langCode = 'ar';
  String _condition = '';
  String _priceType = '';
  String _adType = '';
  String _currency = 'SYP';
  bool _pricePrivate = false;

  // الصور الموجودة من Firestore (روابط)
  List<String> _existingImages = [];
  // صور جديدة يختارها المستخدم
  final List<XFile> _newImages = [];
  final List<Uint8List> _newImageBytes = [];
  final _picker = ImagePicker();

  bool _saving = false;
  bool _uploadingImages = false;

  // روابط المشاركة
  final List<String> _sharePlatformKeys = ['facebook', 'instagram', 'tiktok'];
  final Map<String, bool> _shareOptions = {
    'facebook': false,
    'instagram': false,
    'tiktok': false
  };
  final Map<String, String> _shareLinks = {
    'facebook': '',
    'instagram': '',
    'tiktok': ''
  };
  final Map<String, IconData> _shareIcons = {
    'facebook': Icons.facebook,
    'instagram': Icons.camera_alt,
    'tiktok': Icons.music_note
  };
  final Map<String, Color> _shareColors = {
    'facebook': const Color(0xFF1877F2),
    'instagram': const Color(0xFFE1306C),
    'tiktok': const Color(0xFF010101)
  };

  _WaCountry _waCountry = _waCountries[1]; // +963 سوريا افتراضياً
  final _waPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLangThenData();
  }

  Future<void> _loadLangThenData() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'ar';
    setState(() {
      _langCode = lang;
      _condition = _s(lang, 'used');
      _priceType = _s(lang, 'fixed');
      _adType = _s(lang, 'sell');
    });
    _fillFromFirestore();
  }

  void _fillFromFirestore() {
    final d = widget.adData;
    _titleCtrl.text = d['title'] ?? '';
    if (d['price'] == 'سعر خاص' || d['price'] == 'Special Price') {
      _priceCtrl.text = '';
    } else {
      _priceCtrl.text = ThousandsFormatter.formatExisting(d['price'] ?? '');
    }
    _descCtrl.text = d['description'] ?? '';
    final savedGov = d['governorate'] ?? d['city'];
    if (savedGov != null && _iraqGovernorates.contains(savedGov)) {
      _selectedGovernorate = savedGov;
    }
    _neighborhoodCtrl.text = d['neighborhood'] ?? '';
    _videoCtrl.text = d['videoUrl'] ?? '';

    _selectedCategory = d['category'];
    _selectedSubCategory = d['subCategory'];

    // الصور الموجودة
    final imgs = d['images'];
    if (imgs is List) _existingImages = imgs.cast<String>();

    // الحالة ونوع السعر ونوع الإعلان — نحتفظ بالقيمة المخزنة
    if ((d['condition'] ?? '').toString().isNotEmpty)
      _condition = d['condition'];
    if ((d['priceType'] ?? '').toString().isNotEmpty)
      _priceType = d['priceType'];
    if ((d['adType'] ?? '').toString().isNotEmpty) _adType = d['adType'];
    if ((d['currency'] ?? '').toString().isNotEmpty) _currency = d['currency'];
    _pricePrivate = d['isSpecialPrice'] == true || d['price'] == 'سعر خاص';

    // روابط المشاركة
    final shareLinks = d['shareLinks'];
    if (shareLinks is Map) {
      final map = shareLinks.cast<String, String>();
      final phoneLink = map['واتساب'] ?? '';
      if (phoneLink.startsWith('https://wa.me/')) {
        String phone = phoneLink.replaceFirst('https://wa.me/', '');
        _WaCountry matched = _waCountries[0];
        String number = phone;
        for (final c in _waCountries) {
          final code = c.code.replaceAll('+', '');
          if (phone.startsWith(code)) {
            matched = c;
            number = phone.substring(code.length).trim();
            break;
          }
        }
        _waCountry = matched;
        _waPhoneCtrl.text = number;
      } else {
        _waPhoneCtrl.text = phoneLink;
      }
      _shareLinks['facebook'] = map['فيسبوك'] ?? '';
      _shareLinks['instagram'] = map['إنستغرام'] ?? '';
      _shareLinks['tiktok'] = map['تيك توك'] ?? '';
      _shareOptions.forEach((k, _) {
        _shareOptions[k] = _shareLinks[k]!.isNotEmpty;
      });
    }

    setState(() {});
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _waPhoneCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  // ── اتجاهات النص ──
  TextDirection get _textDir =>
      _langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  TextAlign get _textAlign => (_langCode == 'ar' || _langCode == 'ckb')
      ? TextAlign.right
      : TextAlign.left;
  CrossAxisAlignment get _crossAlign =>
      (_langCode == 'ar' || _langCode == 'ckb')
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start;

  // ── رفع الصور ──
  static const _cloudName = 'doddemkpy';
  static const _uploadPreset = 'alzain';

  Future<List<String>> _uploadNewImages() async {
    if (_newImages.isEmpty) return [];
    final List<String> urls = [];
    setState(() => _uploadingImages = true);
    try {
      for (final img in _newImages) {
        final url = await _uploadToCloudinary(img);
        if (url != null) urls.add(url);
      }
    } finally {
      setState(() => _uploadingImages = false);
    }
    return urls;
  }

  Future<String?> _uploadToCloudinary(XFile imgFile) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final bytes = await imgFile.readAsBytes();
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: imgFile.name));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);
    if (response.statusCode == 200) return json['secure_url'] as String?;
    throw Exception('Cloudinary error: ${json['error']?['message'] ?? body}');
  }

  // ── اختيار صورة جديدة ──
  Future<void> _pickImage() async {
    final l = _langCode;
    final totalPhotos = _existingImages.length + _newImages.length;
    if (totalPhotos >= 5) {
      _showSnack(_s(l, 'maxPhotos'));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.camera_alt, color: Color(0xFFFFD600)),
          title: Text(_s(l, 'takePhoto')),
          onTap: () async {
            Navigator.pop(context);
            final img = await _picker.pickImage(
                source: ImageSource.camera, imageQuality: 80);
            if (img != null) {
              final bytes = await img.readAsBytes();
              setState(() {
                _newImages.add(img);
                _newImageBytes.add(bytes);
              });
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library, color: Color(0xFFFFD600)),
          title: Text(_s(l, 'fromGallery')),
          onTap: () async {
            Navigator.pop(context);
            final remaining =
                _maxPhotos - _existingImages.length - _newImages.length;
            final imgs = await _picker.pickMultiImage(
                imageQuality: 80, limit: remaining);
            if (imgs.isNotEmpty) {
              final bytesList =
                  await Future.wait(imgs.map((i) => i.readAsBytes()));
              setState(() {
                _newImages.addAll(imgs);
                _newImageBytes.addAll(bytesList);
              });
            }
          },
        ),
        const SizedBox(height: 8),
      ])),
    );
  }

  // ── حفظ التعديلات ──
  Future<void> _saveChanges() async {
    final l = _langCode;
    if (_titleCtrl.text.trim().length < 10) {
      _showSnack(_s(l, 'titleMin'));
      return;
    }
    if (_selectedCategory == null) {
      _showSnack(_s(l, 'chooseSection'));
      return;
    }
    if (_selectedGovernorate == null || _selectedGovernorate!.isEmpty) {
      _showSnack(_s(l, 'enterCityZip'));
      return;
    }

    setState(() => _saving = true);
    try {
      // رفع الصور الجديدة
      List<String> newUrls = [];
      if (_newImages.isNotEmpty) newUrls = await _uploadNewImages();

      // دمج الصور الموجودة + الجديدة
      final allImages = [..._existingImages, ...newUrls];

      final rawPhone = _waPhoneCtrl.text.trim().replaceAll(RegExp(r'\s+'), '');
      final fullPhone = rawPhone.isEmpty ? '' : '${_waCountry.code}$rawPhone';
      final waLink = fullPhone.isEmpty
          ? ''
          : 'https://wa.me/${fullPhone.replaceAll('+', '')}';

      final shareLinksForFirestore = <String, String>{
        'واتساب': waLink,
        'فيسبوك': _shareLinks['facebook'] ?? '',
        'إنستغرام': _shareLinks['instagram'] ?? '',
        'تيك توك': _shareLinks['tiktok'] ?? '',
      };

      await FirebaseFirestore.instance
          .collection('ads')
          .doc(widget.docId)
          .update({
        'title': _titleCtrl.text.trim(),
        'category': _selectedCategory ?? '',
        'subCategory': _selectedSubCategory ?? '',
        'price': _pricePrivate
            ? _s(l, 'private')
            : (_priceCtrl.text.trim().isEmpty
                ? _s(l, 'free')
                : ThousandsFormatter.clean(_priceCtrl.text.trim())),
        'isSpecialPrice': _pricePrivate,
        'priceType': _priceType,
        'adType': _adType,
        'governorate': _selectedGovernorate ?? '',
        'city': _selectedGovernorate ?? '',
        'neighborhood': _neighborhoodCtrl.text.trim(),
        'currency': _currency,
        'condition': _condition,
        'description': _descCtrl.text.trim(),
        'shareLinks': shareLinksForFirestore,
        'images': allImages,
        'videoUrl': _videoCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_s(l, 'saveSuccess')), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack(
          'Error: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── حوار رابط المشاركة ──
  void _showLinkDialog(String platformKey) {
    final l = _langCode;
    final name = _s(l, platformKey);
    final ctrl = TextEditingController(text: _shareLinks[platformKey]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: (_langCode == 'ar' || _langCode == 'ckb')
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (_langCode != 'ar') ...[
              Icon(_shareIcons[platformKey],
                  color: _shareColors[platformKey], size: 22),
              const SizedBox(width: 8)
            ],
            Text(_s(l, 'linkHint').replaceAll('{platform}', name),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (_langCode == 'ar' || _langCode == 'ckb') ...[
              const SizedBox(width: 8),
              Icon(_shareIcons[platformKey],
                  color: _shareColors[platformKey], size: 22)
            ],
          ],
        ),
        content: TextField(
          controller: ctrl,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'https://',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: _shareColors[platformKey]!, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_s(l, 'cancel'),
                  style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _shareLinks[platformKey] = ctrl.text.trim();
                _shareOptions[platformKey] = ctrl.text.trim().isNotEmpty;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _shareColors[platformKey],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_s(l, 'saveBtn')),
          ),
        ],
      ),
    );
  }

  // ── اختيار القسم ──
  void _showCategoryPicker() {
    final l = _langCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Column(children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Text(_s(l, 'chooseSection2'),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: getCategories(l).length,
              itemBuilder: (_, i) {
                final cat = getCategories(l)[i];
                return ExpansionTile(
                  leading: Icon(cat.icon, color: cat.color),
                  title: Text(cat.name, textAlign: _textAlign),
                  children: [
                    ...cat.subCategories.map((sub) => ListTile(
                          leading: Icon(sub.icon, color: sub.color, size: 20),
                          title: Text(sub.name,
                              textAlign: _textAlign,
                              style: const TextStyle(fontSize: 14)),
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat.name;
                              _selectedSubCategory = sub.name;
                            });
                            Navigator.pop(context);
                          },
                        )),
                    ListTile(
                      leading:
                          Icon(Icons.more_horiz, color: cat.color, size: 20),
                      title: Text('${cat.name} - ${_s(l, 'general')}',
                          textAlign: _textAlign,
                          style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat.name;
                          _selectedSubCategory = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  // ── اختيار نوع السعر ──
  void _showPriceTypePicker() {
    final l = _langCode;
    final types = [_s(l, 'fixed'), _s(l, 'negotiable'), _s(l, 'freeGift')];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_s(l, 'cancel'),
                    style: const TextStyle(color: Colors.red))),
            Text(_s(l, 'priceType'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 60),
          ]),
        ),
        const Divider(height: 1),
        ...types.map((type) => ListTile(
              trailing: Radio<String>(
                value: type,
                groupValue: _priceType,
                onChanged: (v) {
                  setState(() => _priceType = v!);
                  Navigator.pop(context);
                },
                activeColor: const Color(0xFFFFD600),
              ),
              title: Text(type, textAlign: _textAlign),
            )),
        const SizedBox(height: 16),
      ]),
    );
  }

  // ── اختيار الدولة (للواتساب) ──
  void _showCountryPicker() {
    final searchCtrl = TextEditingController();
    List<_WaCountry> filtered = List.from(_waCountries);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setBS) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'بحث عن دولة...',
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (q) {
                  setBS(() {
                    filtered = _waCountries
                        .where((c) => c.name.contains(q) || c.code.contains(q))
                        .toList();
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
                child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final selected =
                    c.code == _waCountry.code && c.name == _waCountry.name;
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(c.name, textAlign: TextAlign.right),
                  trailing: Text(c.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? const Color(0xFF25D366)
                            : Colors.grey.shade600,
                        fontSize: 14,
                      )),
                  tileColor: selected
                      ? const Color(0xFF25D366).withValues(alpha: 0.08)
                      : null,
                  onTap: () {
                    setState(() => _waCountry = c);
                    Navigator.pop(context);
                  },
                );
              },
            )),
          ]),
        );
      }),
    );
  }

  Widget _buildSharePlatforms(String l) {
    final isRtl = l == 'ar' || l == 'ckb';
    final hasPhone = _waPhoneCtrl.text.trim().isNotEmpty;
    return Column(crossAxisAlignment: _crossAlign, children: [
      Row(children: [
        if (!isRtl) ...[
          const Icon(Icons.chat, color: Color(0xFF25D366), size: 18),
          const SizedBox(width: 6),
        ],
        const Text('WhatsApp',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1F2937))),
        if (isRtl) ...[
          const SizedBox(width: 6),
          const Icon(Icons.chat, color: Color(0xFF25D366), size: 18),
        ],
      ]),
      const SizedBox(height: 8),
      Row(children: [
        if (isRtl) ...[
          Expanded(
            child: TextField(
              controller: _waPhoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              decoration: _inputDecoration('1511 234 5678').copyWith(
                prefixIcon: hasPhone
                    ? const Icon(Icons.check_circle,
                        color: Color(0xFF25D366), size: 20)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showCountryPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                const SizedBox(width: 2),
                Text(_waCountry.code,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 4),
                Text(_waCountry.flag, style: const TextStyle(fontSize: 18)),
              ]),
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: _showCountryPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_waCountry.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(_waCountry.code,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _waPhoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: _inputDecoration('1511 234 5678').copyWith(
                suffixIcon: hasPhone
                    ? const Icon(Icons.check_circle,
                        color: Color(0xFF25D366), size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ]),
      const SizedBox(height: 16),
      const Divider(height: 1),
      const SizedBox(height: 12),
      _buildLabel(_s(l, 'contactOwner')),
      const SizedBox(height: 4),
      Align(
        alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(_s(l, 'shareSubtitle'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ),
      const SizedBox(height: 12),
      Wrap(
        alignment: isRtl ? WrapAlignment.end : WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: _sharePlatformKeys.map((key) {
          final selected = _shareOptions[key]!;
          final hasLink = _shareLinks[key]!.isNotEmpty;
          final name = _s(l, key);
          return GestureDetector(
            onTap: () => _showLinkDialog(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? _shareColors[key]!.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? _shareColors[key]! : Colors.grey.shade300,
                    width: selected ? 1.5 : 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (hasLink) ...[
                  Icon(Icons.check_circle, color: _shareColors[key], size: 14),
                  const SizedBox(width: 4)
                ],
                Text(name,
                    style: TextStyle(
                        fontSize: 13,
                        color:
                            selected ? _shareColors[key] : Colors.grey.shade700,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal)),
                const SizedBox(width: 6),
                Icon(_shareIcons[key],
                    color: selected ? _shareColors[key] : Colors.grey.shade400,
                    size: 18),
              ]),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final l = _langCode;
    final conditionOptions = [
      _s(l, 'new'),
      _s(l, 'likeNew'),
      _s(l, 'used'),
      _s(l, 'gift')
    ];
    final adTypeOptions = [_s(l, 'sell'), _s(l, 'search')];
    final totalPhotos = _existingImages.length + _newImages.length;

    return Directionality(
      textDirection: _textDir,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(_s(l, 'editAd'),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          actions: [
            TextButton(
              onPressed: (_saving || _uploadingImages) ? null : _saveChanges,
              child: Text(
                _s(l, 'saveBtn'),
                style: TextStyle(
                  color: (_saving || _uploadingImages)
                      ? Colors.grey
                      : const Color(0xFFFFD600),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            // ── نوع الإعلان ──
            _buildSection(
                child: Row(
              children: adTypeOptions
                  .map((type) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _adType = type),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _adType == type
                                  ? const Color(0xFFFFD600)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _adType == type
                                      ? const Color(0xFFFFD600)
                                      : Colors.grey.shade300),
                            ),
                            child: Text(type,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _adType == type
                                        ? Colors.black
                                        : Colors.grey)),
                          ),
                        ),
                      ))
                  .toList(),
            )),

            const SizedBox(height: 8),

            // ── الصور ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (l != 'ar') _buildLabel(_s(l, 'photos')),
                Text('$totalPhotos/$_maxPhotos',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                if (l == 'ar' || l == 'ckb') _buildLabel(_s(l, 'photos')),
              ]),
              const SizedBox(height: 10),

              // الصور الموجودة
              if (_existingImages.isNotEmpty) ...[
                Align(
                    alignment: (l == 'ar' || l == 'ckb')
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(_s(l, 'existingPhotos'),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))),
                const SizedBox(height: 6),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImages.length,
                    itemBuilder: (_, i) => Stack(children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: NetworkImage(_existingImages[i]),
                              fit: BoxFit.cover),
                        ),
                      ),
                      // زر حذف الصورة الموجودة
                      Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _existingImages.removeAt(i)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                      if (i == 0)
                        Positioned(
                          bottom: 4,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFD600),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(_s(l, 'main'),
                                style: const TextStyle(
                                    fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // زر إضافة + الصور الجديدة
              SizedBox(
                height: 90,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  // زر الإضافة
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: Colors.grey.shade400, size: 28),
                            const SizedBox(height: 4),
                            Text(_s(l, 'addPhoto'),
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 11)),
                          ]),
                    ),
                  ),
                  // الصور الجديدة المختارة
                  ..._newImages.asMap().entries.map((entry) {
                    final i = entry.key;
                    final img = entry.value;
                    return Stack(children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: MemoryImage(_newImageBytes[i]),
                              fit: BoxFit.cover),
                          border: Border.all(
                              color: const Color(0xFFFFD600), width: 2),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _newImages.removeAt(i);
                            _newImageBytes.removeAt(i);
                          }),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ]);
                  }),
                ]),
              ),
            ])),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildSection(child: _buildSharePlatforms(l)),

            const SizedBox(height: 8),

            // ── عنوان الإعلان ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              _buildLabel(_s(l, 'adTitle')),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                textAlign: _textAlign,
                textDirection: _textDir,
                maxLength: 65,
                decoration: _inputDecoration(_s(l, 'titleHint')),
              ),
            ])),

            const SizedBox(height: 8),

            // ── القسم ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              _buildLabel(_s(l, 'category')),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showCategoryPicker,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.chevron_right, color: Colors.grey),
                        Text(
                          _selectedCategory == null
                              ? _s(l, 'chooseCategory')
                              : _selectedSubCategory != null
                                  ? '$_selectedCategory ← $_selectedSubCategory'
                                  : _selectedCategory!,
                          style: TextStyle(
                              color: _selectedCategory == null
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 14),
                        ),
                      ]),
                ),
              ),
            ])),

            const SizedBox(height: 8),

            // ── الوصف ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              _buildLabel(_s(l, 'description')),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                textAlign: _textAlign,
                textDirection: _textDir,
                maxLines: 5,
                maxLength: 4000,
                decoration: _inputDecoration(_s(l, 'descHint')),
              ),
            ])),

            const SizedBox(height: 8),

            // ── رابط الفيديو ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              _buildLabel(_s(l, 'videoLink')),
              const SizedBox(height: 8),
              TextField(
                controller: _videoCtrl,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.url,
                decoration: _inputDecoration(_s(l, 'videoHint')),
              ),
            ])),

            const SizedBox(height: 8),

            // ── السعر ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              _buildLabel(_s(l, 'price')),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _pricePrivate = !_pricePrivate),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _pricePrivate
                        ? const Color(0xFF3B5BDB).withValues(alpha: 0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _pricePrivate
                          ? const Color(0xFF3B5BDB)
                          : Colors.grey.shade300,
                      width: _pricePrivate ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(
                            _pricePrivate
                                ? Icons.lock
                                : Icons.lock_open_outlined,
                            color: _pricePrivate
                                ? const Color(0xFF3B5BDB)
                                : Colors.grey.shade500,
                            size: 20),
                        const SizedBox(width: 8),
                        Text(_s(l, 'private'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _pricePrivate
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _pricePrivate
                                  ? const Color(0xFF3B5BDB)
                                  : Colors.grey.shade600,
                            )),
                      ]),
                      Switch(
                        value: _pricePrivate,
                        onChanged: (v) => setState(() => _pricePrivate = v),
                        activeColor: const Color(0xFF3B5BDB),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_pricePrivate) ...[
                const SizedBox(height: 12),
                _buildCurrencySelector(),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      inputFormatters: [ThousandsFormatter()],
                      decoration: _inputDecoration('500').copyWith(
                        prefixText: _currency == 'USD' ? '\$ ' : null,
                        prefixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        suffix: _currency == 'SYP'
                            ? const Text('ل.س',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _showPriceTypePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.chevron_right,
                                  color: Colors.grey, size: 18),
                              Expanded(
                                  child: Text(_priceType,
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12))),
                            ]),
                      ),
                    ),
                  ),
                ]),
              ] else ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFF3B5BDB).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    (l == 'ar' || l == 'ckb' || l == 'ku')
                        ? 'سيظهر للمشترين "سعر خاص" بدل السعر — سيتواصلون معك للاستفسار'
                        : 'Buyers will see "Special Price" instead of a price — they\'ll contact you',
                    textAlign: _textAlign,
                    style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF3B5BDB).withValues(alpha: 0.8)),
                  ),
                ),
              ],
            ])),

            const SizedBox(height: 8),

            // ── الحالة ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              _buildLabel(_s(l, 'condition')),
              const SizedBox(height: 8),
              Wrap(
                alignment: (l == 'ar' || l == 'ckb')
                    ? WrapAlignment.end
                    : WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: conditionOptions
                    .map((c) => GestureDetector(
                          onTap: () => setState(() => _condition = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _condition == c
                                  ? const Color(0xFFFFD600)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _condition == c
                                      ? const Color(0xFFFFD600)
                                      : Colors.grey.shade300),
                            ),
                            child: Text(c,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _condition == c
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ),
                        ))
                    .toList(),
              ),
            ])),

            const SizedBox(height: 8),

            // ── الموقع ──
            _buildSection(
                child: Column(crossAxisAlignment: _crossAlign, children: [
              _buildLabel(_s(l, 'location')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGovernorate,
                decoration: _inputDecoration(_s(l, 'location')),
                items: _iraqGovernorates
                    .map((g) => DropdownMenuItem(
                        value: g, child: Text(g, textAlign: _textAlign)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGovernorate = v),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: _neighborhoodCtrl,
                  textAlign: _textAlign,
                  textDirection: _textDir,
                  decoration: _inputDecoration('اكتب في اسم الحي او المكان')),
            ])),

            const SizedBox(height: 16),

            // ── زر الحفظ ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      (_saving || _uploadingImages) ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: (_saving || _uploadingImages)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.black, strokeWidth: 2.5)),
                              const SizedBox(width: 10),
                              Text(
                                  _uploadingImages
                                      ? _s(l, 'uploadingImages')
                                      : _s(l, 'saving'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(_s(l, 'saveBtn'),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ]),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: child);
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1F2937)));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFFD600), width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildCurrencySelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'SYP', label: Text('ليرة سورية')),
        ButtonSegment(value: 'USD', label: Text('دولار أمريكي')),
      ],
      selected: {_currency},
      onSelectionChanged: (newSelection) {
        setState(() => _currency = newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: const Color(0xFFF3F4F6),
        foregroundColor: const Color(0xFF6B7280),
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: const Color(0xFF3B5BDB),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
    );
  }
}
