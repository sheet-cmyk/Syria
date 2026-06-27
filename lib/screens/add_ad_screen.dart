import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../data/data.dart';
import '../utils/thousands_formatter.dart';

// ═══════════════════════════════════════════════════════════════
const int _maxPhotos = 5;
const int _maxAdsPerUser = 5;
// ═══════════════════════════════════════════════════════════════

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

// قائمة محافظات سوريا
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

const Map<String, Map<String, String>> _addAdStrings = {
  'ar': {
    'publishAd': 'نشر إعلان',
    'save': 'حفظ',
    'draftSaved': 'تم حفظ المسودة ✓',
    'sell': 'أبيع',
    'search': 'أبحث',
    'photos': 'الصور',
    'addPhoto': 'إضافة',
    'main': 'رئيسية',
    'adTitle': 'اسم الإعلان *',
    'titleHint': 'مثال: آيفون 15 برو 256GB',
    'category': 'القسم *',
    'chooseCategory': 'اختر القسم',
    'description': 'الوصف',
    'descHint': 'اكتب وصفاً تفصيلياً للإعلان...',
    'videoLink': 'فيديو الإعلان (اختياري)',
    'videoHint': 'ضع فيديو تابع للإعلان إذا أمكن',
    'price': 'السعر',
    'condition': 'الحالة',
    'new': 'جديد',
    'likeNew': 'شبه جديد',
    'used': 'مستعمل',
    'gift': 'هدية',
    'location': 'الموقع *',
    'autoLocate': 'تحديد تلقائي',
    'locating': 'جاري التحديد...',
    'cityHint': 'اسم المدينة (مثال: Berlin)',
    'zipHint': 'الرمز البريدي (PLZ — مثال: 10115)',
    'streetHint': 'الشارع (اختياري)',
    'contactInfo': 'معلومات الاتصال من ملفك الشخصي',
    'contactOwner': 'التواصل مع صاحب الإعلان',
    'shareSubtitle': 'اضغط على المنصة لإضافة رابطك',
    'publishBtn': 'نشر الإعلان',
    'uploadingImages': 'جاري رفع الصور...',
    'publishing': 'جاري النشر...',
    'publishSuccess': 'تم نشر الإعلان بنجاح ✓',
    'maxPhotosMsg': 'الحد الأقصى للصور هو $_maxPhotos فقط',
    'maxAdsMsg':
        'لقد وصلت إلى الحد الأقصى المسموح من الإعلانات ($_maxAdsPerUser إعلانات)',
    'checkingLimit': 'جاري التحقق...',
    'takePhoto': 'التقاط صورة',
    'fromGallery': 'اختيار من المعرض',
    'titleMin': 'اسم الإعلان يجب أن يكون 10 أحرف على الأقل',
    'chooseSection': 'يرجى اختيار القسم',
    'enterCityZip': 'يرجى اختيار المحافظة',
    'locationEnabled': 'تم تحديد موقعك — أدخل اسم المدينة والرمز البريدي ✓',
    'enableLocation': 'يرجى تفعيل خدمة الموقع',
    'locationDenied': 'تم رفض إذن الموقع',
    'locationFailed': 'تعذّر تحديد الموقع',
    'priceType': 'نوع السعر',
    'fixed': 'سعر ثابت',
    'negotiable': 'قابل للتفاوض',
    'freeGift': 'هدية مجانية',
    'cancel': 'إلغاء',
    'saveBtn': 'حفظ',
    'chooseSection2': 'اختر القسم',
    'general': 'عام',
    'whatsapp': 'واتساب',
    'facebook': 'فيسبوك',
    'instagram': 'إنستغرام',
    'tiktok': 'تيك توك',
    'linkHint': 'رابط {platform}',
    'free': 'مجاني',
    'user': 'مستخدم',
    'private': 'سعر خاص',
  },
  'en': {
    'publishAd': 'Post Ad',
    'save': 'Save',
    'draftSaved': 'Draft saved ✓',
    'sell': 'Selling',
    'search': 'Looking',
    'photos': 'Photos',
    'addPhoto': 'Add',
    'main': 'Main',
    'adTitle': 'Ad Title *',
    'titleHint': 'Example: iPhone 15 Pro 256GB',
    'category': 'Category *',
    'chooseCategory': 'Choose Category',
    'description': 'Description',
    'descHint': 'Write a detailed description...',
    'videoLink': 'Ad Video (optional)',
    'videoHint': 'Add a video link to the ad if available',
    'price': 'Price',
    'condition': 'Condition',
    'new': 'New',
    'likeNew': 'Like New',
    'used': 'Used',
    'gift': 'Gift',
    'location': 'Location *',
    'autoLocate': 'Auto Detect',
    'locating': 'Detecting...',
    'cityHint': 'City name (e.g.: Berlin)',
    'zipHint': 'Postal code (PLZ — e.g.: 10115)',
    'streetHint': 'Street (optional)',
    'contactInfo': 'Contact info from your profile',
    'contactOwner': 'Contact the seller',
    'shareSubtitle': 'Tap a platform to add your link',
    'publishBtn': 'Post Ad',
    'uploadingImages': 'Uploading photos...',
    'publishing': 'Publishing...',
    'publishSuccess': 'Ad posted successfully ✓',
    'maxPhotosMsg': 'Maximum $_maxPhotos photos allowed',
    'maxAdsMsg': 'You have reached the limit of $_maxAdsPerUser ads',
    'checkingLimit': 'Checking...',
    'takePhoto': 'Take Photo',
    'fromGallery': 'Choose from Gallery',
    'titleMin': 'Ad title must be at least 10 characters',
    'chooseSection': 'Please choose a category',
    'enterCityZip': 'Please choose governorate',
    'locationEnabled': 'Location detected — Enter city and postal code ✓',
    'enableLocation': 'Please enable location service',
    'locationDenied': 'Location permission denied',
    'locationFailed': 'Failed to detect location',
    'priceType': 'Price Type',
    'fixed': 'Fixed Price',
    'negotiable': 'Negotiable',
    'freeGift': 'Free / Gift',
    'cancel': 'Cancel',
    'saveBtn': 'Save',
    'chooseSection2': 'Choose Category',
    'general': 'General',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': '{platform} link',
    'free': 'Free',
    'user': 'User',
    'private': 'Private',
  },
  'de': {
    'publishAd': 'Anzeige aufgeben',
    'save': 'Speichern',
    'draftSaved': 'Entwurf gespeichert ✓',
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
    'videoLink': 'Anzeigen-Video (optional)',
    'videoHint': 'Füge ein Video zur Anzeige hinzu, wenn möglich',
    'price': 'Preis',
    'condition': 'Zustand',
    'new': 'Neu',
    'likeNew': 'Wie neu',
    'used': 'Gebraucht',
    'gift': 'Geschenk',
    'location': 'Standort *',
    'autoLocate': 'Automatisch ermitteln',
    'locating': 'Wird ermittelt...',
    'cityHint': 'Stadtname (z.B.: Berlin)',
    'zipHint': 'Postleitzahl (PLZ — z.B.: 10115)',
    'streetHint': 'Straße (optional)',
    'contactInfo': 'Kontaktdaten aus deinem Profil',
    'contactOwner': 'Kontakt zum Anbieter',
    'shareSubtitle': 'Tippe auf eine Plattform, um deinen Link hinzuzufügen',
    'publishBtn': 'Anzeige veröffentlichen',
    'uploadingImages': 'Fotos werden hochgeladen...',
    'publishing': 'Wird veröffentlicht...',
    'publishSuccess': 'Anzeige erfolgreich veröffentlicht ✓',
    'maxPhotosMsg': 'Maximal $_maxPhotos Fotos erlaubt',
    'maxAdsMsg': 'Sie haben das Maximum von $_maxAdsPerUser Anzeigen erreicht',
    'checkingLimit': 'Wird überprüft...',
    'takePhoto': 'Foto aufnehmen',
    'fromGallery': 'Aus Galerie auswählen',
    'titleMin': 'Der Titel muss mindestens 10 Zeichen lang sein',
    'chooseSection': 'Bitte wähle eine Kategorie',
    'enterCityZip': 'Bitte Provinz wählen',
    'locationEnabled': 'Standort ermittelt — Bitte Stadt und PLZ eingeben ✓',
    'enableLocation': 'Bitte Ortungsdienst aktivieren',
    'locationDenied': 'Standortberechtigung verweigert',
    'locationFailed': 'Standort konnte nicht ermittelt werden',
    'priceType': 'Preisart',
    'fixed': 'Festpreis',
    'negotiable': 'Verhandelbar',
    'freeGift': 'Kostenlos/Verschenken',
    'cancel': 'Abbrechen',
    'saveBtn': 'Speichern',
    'chooseSection2': 'Kategorie wählen',
    'general': 'Allgemein',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': '{platform}-Link',
    'free': 'Kostenlos',
    'user': 'Benutzer',
    'private': 'Privat',
  },
  'fr': {
    'publishAd': 'Publier une annonce',
    'save': 'Sauvegarder',
    'draftSaved': 'Brouillon sauvegardé ✓',
    'sell': 'Je vends',
    'search': 'Je cherche',
    'photos': 'Photos',
    'addPhoto': 'Ajouter',
    'main': 'Principal',
    'adTitle': "Titre de l'annonce *",
    'titleHint': 'Exemple: iPhone 15 Pro 256Go',
    'category': 'Catégorie *',
    'chooseCategory': 'Choisir une catégorie',
    'description': 'Description',
    'descHint': 'Rédigez une description détaillée...',
    'videoLink': "Vidéo de l'annonce (optionnel)",
    'videoHint': "Ajoutez une vidéo à l'annonce si possible",
    'price': 'Prix',
    'condition': 'État',
    'new': 'Neuf',
    'likeNew': 'Comme neuf',
    'used': 'Occasion',
    'gift': 'Don',
    'location': 'Localisation *',
    'autoLocate': 'Localisation auto',
    'locating': 'Localisation en cours...',
    'cityHint': 'Nom de la ville (ex: Berlin)',
    'zipHint': 'Code postal (ex: 10115)',
    'streetHint': 'Rue (optionnel)',
    'contactInfo': 'Coordonnées de votre profil',
    'contactOwner': 'Contacter le propriétaire',
    'shareSubtitle': 'Appuyez sur une plateforme pour ajouter votre lien',
    'publishBtn': "Publier l'annonce",
    'uploadingImages': 'Téléchargement des photos...',
    'publishing': 'Publication en cours...',
    'publishSuccess': 'Annonce publiée avec succès ✓',
    'maxPhotosMsg': 'Maximum $_maxPhotos photos autorisées',
    'maxAdsMsg': 'Vous avez atteint la limite de $_maxAdsPerUser annonces',
    'checkingLimit': 'Vérification...',
    'takePhoto': 'Prendre une photo',
    'fromGallery': 'Choisir depuis la galerie',
    'titleMin': 'Le titre doit comporter au moins 10 caractères',
    'chooseSection': 'Veuillez choisir une catégorie',
    'enterCityZip': 'Veuillez choisir la gouvernorat',
    'locationEnabled':
        'Localisation détectée — Entrez la ville et le code postal ✓',
    'enableLocation': 'Veuillez activer le service de localisation',
    'locationDenied': 'Permission de localisation refusée',
    'locationFailed': 'Impossible de déterminer la localisation',
    'priceType': 'Type de prix',
    'fixed': 'Prix fixe',
    'negotiable': 'Négociable',
    'freeGift': 'Gratuit / Don',
    'cancel': 'Annuler',
    'saveBtn': 'Enregistrer',
    'chooseSection2': 'Choisir une catégorie',
    'general': 'Général',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': 'Lien {platform}',
    'free': 'Gratuit',
    'user': 'Utilisateur',
    'private': 'Confidentiel',
  },
  'sv': {
    'publishAd': 'Lägg upp annons',
    'save': 'Spara',
    'draftSaved': 'Utkast sparat ✓',
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
    'videoLink': 'Annonsvideo (valfritt)',
    'videoHint': 'Lägg till en video till annonsen om möjligt',
    'price': 'Pris',
    'condition': 'Skick',
    'new': 'Ny',
    'likeNew': 'Som ny',
    'used': 'Begagnad',
    'gift': 'Gåva',
    'location': 'Plats *',
    'autoLocate': 'Hitta automatiskt',
    'locating': 'Hämtar plats...',
    'cityHint': 'Stadsnamn (t.ex.: Berlin)',
    'zipHint': 'Postnummer (t.ex.: 10115)',
    'streetHint': 'Gata (valfritt)',
    'contactInfo': 'Kontaktuppgifter från din profil',
    'contactOwner': 'Kontakta annonsören',
    'shareSubtitle': 'Tryck på en plattform för att lägga till din länk',
    'publishBtn': 'Publicera annons',
    'uploadingImages': 'Laddar upp foton...',
    'publishing': 'Publicerar...',
    'publishSuccess': 'Annonsen publicerades ✓',
    'maxPhotosMsg': 'Maximalt $_maxPhotos foton tillåtna',
    'maxAdsMsg': 'Du har nått gränsen på $_maxAdsPerUser annonser',
    'checkingLimit': 'Kontrollerar...',
    'takePhoto': 'Ta foto',
    'fromGallery': 'Välj från galleri',
    'titleMin': 'Rubriken måste vara minst 10 tecken',
    'chooseSection': 'Välj en kategori',
    'enterCityZip': 'Vänligen välj provins',
    'locationEnabled': 'Plats hittad — Ange stad och postnummer ✓',
    'enableLocation': 'Aktivera platstjänster',
    'locationDenied': 'Platsbehörighet nekades',
    'locationFailed': 'Kunde inte hitta platsen',
    'priceType': 'Pristyp',
    'fixed': 'Fast pris',
    'negotiable': 'Förhandlingsbart',
    'freeGift': 'Gratis / Gåva',
    'cancel': 'Avbryt',
    'saveBtn': 'Spara',
    'chooseSection2': 'Välj kategori',
    'general': 'Allmänt',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': '{platform}-länk',
    'free': 'Gratis',
    'user': 'Användare',
    'private': 'Privat',
  },
  'uk': {
    'publishAd': 'Розмістити оголошення',
    'save': 'Зберегти',
    'draftSaved': 'Чернетку збережено ✓',
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
    'videoLink': "Відео оголошення (необов'язково)",
    'videoHint': 'Додайте відео до оголошення, якщо можливо',
    'price': 'Ціна',
    'condition': 'Стан',
    'new': 'Нове',
    'likeNew': 'Як нове',
    'used': 'Вживане',
    'gift': 'Подарунок',
    'location': 'Місцезнаходження *',
    'autoLocate': 'Визначити автоматично',
    'locating': 'Визначення...',
    'cityHint': 'Назва міста (напр.: Berlin)',
    'zipHint': 'Поштовий індекс (напр.: 10115)',
    'streetHint': "Вулиця (необов'язково)",
    'contactInfo': 'Контактні дані з вашого профілю',
    "contactOwner": "Зв'язатися з власником",
    'shareSubtitle': 'Натисніть на платформу, щоб додати посилання',
    'publishBtn': 'Опублікувати оголошення',
    'uploadingImages': 'Завантаження фото...',
    'publishing': 'Публікація...',
    'publishSuccess': 'Оголошення опубліковано ✓',
    'maxPhotosMsg': 'Максимум $_maxPhotos фото',
    'maxAdsMsg': 'Ви досягли ліміту $_maxAdsPerUser оголошень',
    'checkingLimit': 'Перевірка...',
    'takePhoto': 'Зробити фото',
    'fromGallery': 'Вибрати з галереї',
    'titleMin': 'Заголовок має містити щонайменше 10 символів',
    'chooseSection': 'Будь ласка, оберіть категорію',
    'enterCityZip': 'Будь ласка, виберіть провінцію',
    'locationEnabled': 'Місце визначено — введіть місто та індекс ✓',
    'enableLocation': 'Увімкніть службу геолокації',
    'locationDenied': 'Дозвіл на геолокацію відхилено',
    'locationFailed': 'Не вдалося визначити місцезнаходження',
    'priceType': 'Тип ціни',
    'fixed': 'Фіксована ціна',
    'negotiable': 'Договірна',
    'freeGift': 'Безкоштовно / Подарунок',
    'cancel': 'Скасувати',
    'saveBtn': 'Зберегти',
    'chooseSection2': 'Оберіть категорію',
    'general': 'Загальне',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': 'Посилання {platform}',
    'free': 'Безкоштовно',
    'user': 'Користувач',
    'private': 'Приватно',
  },
  'tr': {
    'publishAd': 'İlan Ver',
    'save': 'Kaydet',
    'draftSaved': 'Taslak kaydedildi ✓',
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
    'videoLink': 'İlan Videosu (isteğe bağlı)',
    'videoHint': 'Mümkünse ilana bir video ekleyin',
    'price': 'Fiyat',
    'condition': 'Durum',
    'new': 'Sıfır',
    'likeNew': 'Sıfır gibi',
    'used': 'İkinci el',
    'gift': 'Hediye',
    'location': 'Konum *',
    'autoLocate': 'Otomatik belirle',
    'locating': 'Belirleniyor...',
    'cityHint': 'Şehir adı (örn: Berlin)',
    'zipHint': 'Posta kodu (örn: 10115)',
    'streetHint': 'Sokak (isteğe bağlı)',
    'contactInfo': 'Profilinizdeki iletişim bilgileri',
    'contactOwner': 'İlan sahibiyle iletişim',
    'shareSubtitle': 'Link eklemek için platforma tıklayın',
    'publishBtn': 'İlanı Yayınla',
    'uploadingImages': 'Fotoğraflar yükleniyor...',
    'publishing': 'Yayınlanıyor...',
    'publishSuccess': 'İlan başarıyla yayınlandı ✓',
    'maxPhotosMsg': 'En fazla $_maxPhotos fotoğraf yükleyebilirsiniz',
    'maxAdsMsg': '$_maxAdsPerUser ilan limitine ulaştınız',
    'checkingLimit': 'Kontrol ediliyor...',
    'takePhoto': 'Fotoğraf çek',
    'fromGallery': 'Galeriden seç',
    'titleMin': 'Başlık en az 10 karakter olmalıdır',
    'chooseSection': 'Lütfen bir kategori seçin',
    'enterCityZip': 'Lütfen il seçin',
    'locationEnabled': 'Konumunuz belirlendi — Şehir ve posta kodu girin ✓',
    'enableLocation': 'Lütfen konum servisini etkinleştirin',
    'locationDenied': 'Konum izni reddedildi',
    'locationFailed': 'Konum belirlenemedi',
    'priceType': 'Fiyat türü',
    'fixed': 'Sabit fiyat',
    'negotiable': 'Pazarlıklı',
    'freeGift': 'Ücretsiz / Hediye',
    'cancel': 'İptal',
    'saveBtn': 'Kaydet',
    'chooseSection2': 'Kategori seç',
    'general': 'Genel',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': '{platform} linki',
    'free': 'Ücretsiz',
    'user': 'Kullanıcı',
    'private': 'Gizli',
  },
  'ku': {
    'publishAd': 'Reklamê weşan bike',
    'save': 'Toze bike',
    'draftSaved': 'Pêşnivîs toze bû ✓',
    'sell': 'Ez difiroşim',
    'search': 'Ez digerim',
    'photos': 'Wêne',
    'addPhoto': 'Zêde bike',
    'main': 'Sereke',
    'adTitle': 'Sernavê reklamê *',
    'titleHint': 'Nimûne: iPhone 15 Pro 256GB',
    'category': 'Kategorî *',
    'chooseCategory': 'Kategoriyê hilbijêre',
    'description': 'Danasîn',
    'descHint': 'Danasînek berfireh binivîse...',
    'videoLink': 'Vîdyoya reklamê (vebijarkî)',
    'videoHint': 'Heke gengaz be vîdyoyek zêde bike',
    'price': 'Baha',
    'condition': 'Rewş',
    'new': 'Nû',
    'likeNew': 'Wek nû',
    'used': 'Bikarhatî',
    'gift': 'Diyarî',
    'location': 'Cih *',
    'autoLocate': 'Otomatîk dît',
    'locating': 'Tê dîtin...',
    'cityHint': 'Navê bajêr (mînak: Berlin)',
    'zipHint': 'Koda postê (mînak: 10115)',
    'streetHint': 'Kolan (vebijarkî)',
    'contactInfo': 'Agahdariya têkiliyê ji profîlê',
    'contactOwner': 'Têkilî bi xwediyê reklamê re',
    'shareSubtitle': 'Ji bo lînkê li ser platformê bixin',
    'publishBtn': 'Reklamê weşan bike',
    'uploadingImages': 'Wêneyên barkirin...',
    'publishing': 'Weşandin...',
    'publishSuccess': 'Reklam bi serkeftî weşa bû ✓',
    'maxPhotosMsg': 'Herî zêde $_maxPhotos wêne',
    'maxAdsMsg': 'Tu gihîştî sînorê $_maxAdsPerUser reklamên',
    'checkingLimit': 'Tê kontrol kirin...',
    'takePhoto': 'Wêne bigire',
    'fromGallery': 'Ji galeriyê hilbijêre',
    'titleMin': 'Sernavê reklamê divê herî kêm 10 tîp be',
    'chooseSection': 'Ji kerema xwe kategoriyekê hilbijêre',
    'enterCityZip': 'Ji kerema xwe herêma hilbijêre',
    'locationEnabled': 'Cih hat dîtin — Bajêr û koda postê binivîse ✓',
    'enableLocation': 'Ji kerema xwe karûbarê cihê çalak bike',
    'locationDenied': 'Destûra cihê hate redkirin',
    'locationFailed': 'Cih nehat dîtin',
    'priceType': 'Celebê bihayê',
    'fixed': 'Bihayê sabit',
    'negotiable': 'Lihevkirî',
    'freeGift': 'Belaş / Diyarî',
    'cancel': 'Betal bike',
    'saveBtn': 'Toze bike',
    'chooseSection2': 'Kategoriyê hilbijêre',
    'general': 'Giştî',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': 'Girêdana {platform}',
    'free': 'Belaş',
    'user': 'Bikarhêner',
    'private': 'Taybet',
  },
  'ckb': {
    'publishAd': 'ئەعلان بڵاو بکەرەوە',
    'save': 'پاشەکەوت بکە',
    'draftSaved': 'ڕەشنووس پاشەکەوت کرا ✓',
    'sell': 'دەیفرۆشم',
    'search': 'دەمگەڕێم',
    'photos': 'وێنە',
    'addPhoto': 'زیاد بکە',
    'main': 'سەرەکی',
    'adTitle': 'سەردێڕی ئەعلان *',
    'titleHint': 'نموونە: iPhone 15 Pro 256GB',
    'category': 'کاتێگۆری *',
    'chooseCategory': 'کاتێگۆری هەڵبژێرە',
    'description': 'وەسف',
    'descHint': 'وەسفێکی بەرفراوان بنووسە...',
    'videoLink': 'ڤیدیۆی ئەعلان (ئارەزوومەندانە)',
    'videoHint': 'ئەگەر بتوانیت ڤیدیۆێک زیاد بکە',
    'price': 'نرخ',
    'condition': 'باری کاڵا',
    'new': 'نوێ',
    'likeNew': 'وەک نوێ',
    'used': 'بەکارهاتوو',
    'gift': 'دیاری',
    'location': 'شوێن *',
    'autoLocate': 'بە خۆکاری دیاریبکە',
    'locating': 'دیاریکردن...',
    'cityHint': 'ناوی شار (نموونە: Berlin)',
    'zipHint': 'کۆدی پۆستە (نموونە: 10115)',
    'streetHint': 'کۆلان (ئارەزوومەندانە)',
    'contactInfo': 'زانیاری پەیوەندی لە پرۆفایلەوە',
    'contactOwner': 'پەیوەندی بە خاوەنی ئەعلانەوە',
    'shareSubtitle': 'بۆ زیادکردنی لینک کلیک بکە',
    'publishBtn': 'ئەعلان بڵاو بکەرەوە',
    'uploadingImages': 'وێنەکان بارکردن...',
    'publishing': 'بڵاوکردنەوە...',
    'publishSuccess': 'ئەعلان بە سەرکەوتوویی بڵاو کرایەوە ✓',
    'maxPhotosMsg': 'زۆرترین $_maxPhotos وێنە',
    'maxAdsMsg': 'گەیشتیتە سنووری $_maxAdsPerUser ئەعلان',
    'checkingLimit': 'پشکنین...',
    'takePhoto': 'وێنە بکێش',
    'fromGallery': 'لە گەلەرییەوە هەڵبژێرە',
    'titleMin': 'سەردێڕ دەبێت لانیکەم ١٠ پیت بێت',
    'chooseSection': 'تکایە کاتێگۆریێک هەڵبژێرە',
    'enterCityZip': 'تکایە پارێزگا هەڵبژێرە',
    'locationEnabled': 'شوێن دیاری کرا — شار و کۆدی پۆستە بنووسە ✓',
    'enableLocation': 'تکایە خزمەتی شوێن چالاک بکە',
    'locationDenied': 'مۆڵەتی شوێن ڕەتکرایەوە',
    'locationFailed': 'شوێن دیاری نەکرا',
    'priceType': 'جۆری نرخ',
    'fixed': 'نرخی جێگیر',
    'negotiable': 'چانەپێکراو',
    'freeGift': 'بەخۆڕایی / دیاری',
    'cancel': 'هەڵوەشاندنەوە',
    'saveBtn': 'پاشەکەوت بکە',
    'chooseSection2': 'کاتێگۆری هەڵبژێرە',
    'general': 'گشتی',
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'tiktok': 'TikTok',
    'linkHint': 'لینکی {platform}',
    'free': 'بەخۆڕایی',
    'user': 'بەکارهێنەر',
    'private': 'تایبەت',
  },
};

String _s(String langCode, String key) =>
    _addAdStrings[langCode]?[key] ?? _addAdStrings['ar']![key] ?? key;

class AddAdScreen extends StatefulWidget {
  const AddAdScreen({super.key});
  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
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

  bool _loadingLocation = false;
  bool _publishing = false;
  bool _checkingLimit = false;
  bool _pricePrivate = false;

  final List<XFile> _images = [];
  final List<Uint8List> _imageBytes = [];
  final _picker = ImagePicker();
  bool _uploadingImages = false;

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
    _loadLangAndDraft();
  }

  Future<void> _loadLangAndDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'ar';
    setState(() {
      _langCode = lang;
      _condition = _s(lang, 'new');
      _priceType = _s(lang, 'fixed');
      _adType = _s(lang, 'sell');
    });
    _loadDraft(prefs);
    _loadWaFromProfile();
  }

  Future<void> _loadWaFromProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final phone = (doc.data()?['phone'] as String? ?? '').trim();
      if (phone.isEmpty) return;
      _WaCountry matched = _waCountries[0];
      String number = phone;
      for (final c in _waCountries) {
        if (phone.startsWith(c.code)) {
          matched = c;
          number = phone.substring(c.code.length).trim();
          break;
        }
      }
      if (mounted)
        setState(() {
          _waCountry = matched;
          _waPhoneCtrl.text = number;
        });
    } catch (_) {}
  }

  Future<void> _loadDraft(SharedPreferences prefs) async {
    final savedCode = prefs.getString('draft_wa_code');
    if (savedCode != null) {
      final matched = _waCountries.firstWhere((c) => c.code == savedCode,
          orElse: () => _waCountries[0]);
      _waCountry = matched;
    }
    setState(() {
      _titleCtrl.text = prefs.getString('draft_title') ?? '';
      _priceCtrl.text = prefs.getString('draft_price') ?? '';
      _descCtrl.text = prefs.getString('draft_desc') ?? '';
      final savedGov = prefs.getString('draft_governorate');
      if (savedGov == null ||
          savedGov.isEmpty ||
          !_iraqGovernorates.contains(savedGov)) {
        _selectedGovernorate = null;
      } else {
        _selectedGovernorate = savedGov;
      }
      _neighborhoodCtrl.text = prefs.getString('draft_neighborhood') ?? '';
      _selectedCategory = prefs.getString('draft_category');
      _selectedSubCategory = prefs.getString('draft_subCategory');
      _videoCtrl.text = prefs.getString('draft_video') ?? '';
      _waPhoneCtrl.text = prefs.getString('draft_wa_phone') ?? '';
      final sc = prefs.getString('draft_condition');
      final sp = prefs.getString('draft_priceType');
      final sa = prefs.getString('draft_adType');
      if (sc != null && sc.isNotEmpty) _condition = sc;
      if (sp != null && sp.isNotEmpty) _priceType = sp;
      if (sa != null && sa.isNotEmpty) _adType = sa;
      final sCurr = prefs.getString('draft_currency');
      if (sCurr != null && sCurr.isNotEmpty) _currency = sCurr;
      _pricePrivate = prefs.getBool('draft_price_private') ?? false;
    });
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', _titleCtrl.text);
    await prefs.setString('draft_price', ThousandsFormatter.clean(_priceCtrl.text));
    await prefs.setString('draft_desc', _descCtrl.text);
    await prefs.setString('draft_governorate', _selectedGovernorate ?? '');
    await prefs.setString('draft_neighborhood', _neighborhoodCtrl.text);
    await prefs.setString('draft_category', _selectedCategory ?? '');
    await prefs.setString('draft_subCategory', _selectedSubCategory ?? '');
    await prefs.setString('draft_condition', _condition);
    await prefs.setString('draft_priceType', _priceType);
    await prefs.setString('draft_adType', _adType);
    await prefs.setString('draft_currency', _currency);
    await prefs.setString('draft_video', _videoCtrl.text);
    await prefs.setString('draft_wa_code', _waCountry.code);
    await prefs.setString('draft_wa_phone', _waPhoneCtrl.text);
    await prefs.setBool('draft_price_private', _pricePrivate);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in [
      'draft_title',
      'draft_price',
      'draft_desc',
      'draft_governorate',
      'draft_neighborhood',
      'draft_category',
      'draft_subCategory',
      'draft_condition',
      'draft_priceType',
      'draft_adType',
      'draft_currency',
      'draft_video',
      'draft_wa_code',
      'draft_wa_phone',
      'draft_price_private'
    ]) {
      await prefs.remove(k);
    }
  }

  @override
  void dispose() {
    _saveDraft();
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _streetCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _videoCtrl.dispose();
    _waPhoneCtrl.dispose();
    super.dispose();
  }

  TextDirection get _textDir => (_langCode == 'ar' || _langCode == 'ckb')
      ? TextDirection.rtl
      : TextDirection.ltr;
  TextAlign get _textAlign => (_langCode == 'ar' || _langCode == 'ckb')
      ? TextAlign.right
      : TextAlign.left;
  CrossAxisAlignment get _crossAlign =>
      (_langCode == 'ar' || _langCode == 'ckb')
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start;

  // ══════════════════════════════════════════════════════
  //  التحقق من عدد الإعلانات في Firebase (server-side)
  // ══════════════════════════════════════════════════════
  Future<bool> _checkAdsLimit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await FirebaseFirestore.instance
        .collection('ads')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    return (snapshot.count ?? 0) < _maxAdsPerUser;
  }

  // ══════════════════════════════════════════════════════
  //  اختيار الصور مع تطبيق الحد
  // ══════════════════════════════════════════════════════
  Future<void> _pickImage() async {
    final l = _langCode;
    if (_images.length >= _maxPhotos) {
      _showLimitDialog(_s(l, 'maxPhotosMsg'), Icons.photo_library);
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
              if (_images.length >= _maxPhotos) {
                _showLimitDialog(_s(l, 'maxPhotosMsg'), Icons.photo_library);
                return;
              }
              final bytes = await img.readAsBytes();
              setState(() {
                _images.add(img);
                _imageBytes.add(bytes);
              });
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library, color: Color(0xFFFFD600)),
          title: Text(_s(l, 'fromGallery')),
          onTap: () async {
            Navigator.pop(context);
            final remaining = _maxPhotos - _images.length;
            if (remaining <= 0) {
              _showLimitDialog(_s(l, 'maxPhotosMsg'), Icons.photo_library);
              return;
            }
            final imgs = await _picker.pickMultiImage(
                imageQuality: 80, limit: remaining);
            if (imgs.isNotEmpty) {
              final bytesList =
                  await Future.wait(imgs.map((i) => i.readAsBytes()));
              setState(() {
                _images.addAll(imgs);
                _imageBytes.addAll(bytesList);
              });
            }
          },
        ),
        const SizedBox(height: 8),
      ])),
    );
  }

  // ── حوار تنبيه الحد ──
  void _showLimitDialog(String message, IconData icon) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: Colors.orange.shade50, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.orange, size: 32),
          ),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937))),
        ]),
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

  static const _cloudName = 'doddemkpy';
  static const _uploadPreset = 'alzain';

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return [];
    final List<String> urls = [];
    setState(() => _uploadingImages = true);
    try {
      for (final img in _images) {
        final url = await _uploadToCloudinary(img);
        if (url != null) urls.add(url);
      }
    } catch (e) {
      setState(() => _uploadingImages = false);
      rethrow;
    }
    setState(() => _uploadingImages = false);
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

  Future<void> _getLocation() async {
    final l = _langCode;
    setState(() => _loadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack(_s(l, 'enableLocation'));
        setState(() => _loadingLocation = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack(_s(l, 'locationDenied'));
          setState(() => _loadingLocation = false);
          return;
        }
      }
      await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      setState(() => _loadingLocation = false);
      _showSnack(_s(l, 'locationEnabled'));
    } catch (e) {
      setState(() => _loadingLocation = false);
      _showSnack(_s(l, 'locationFailed'));
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showLinkDialog(String platformKey) {
    final l = _langCode;
    final name = _s(l, platformKey);
    final ctrl = TextEditingController(text: _shareLinks[platformKey]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
            mainAxisAlignment: _langCode == 'ar' || _langCode == 'ckb'
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (_langCode != 'ar' && _langCode != 'ckb') ...[
                Icon(_shareIcons[platformKey],
                    color: _shareColors[platformKey], size: 22),
                const SizedBox(width: 8)
              ],
              Text(_s(l, 'linkHint').replaceAll('{platform}', name),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              if (_langCode == 'ar' || _langCode == 'ckb') ...[
                const SizedBox(width: 8),
                Icon(_shareIcons[platformKey],
                    color: _shareColors[platformKey], size: 22)
              ],
            ]),
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
                      BorderSide(color: _shareColors[platformKey]!, width: 2))),
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
                    borderRadius: BorderRadius.circular(10))),
            child: Text(_s(l, 'saveBtn')),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  نشر الإعلان مع التحقق من الحد في Firebase
  // ══════════════════════════════════════════════════════
  Future<void> _publish() async {
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
      _showSnack(_langCode == 'ar'
          ? 'يرجى اختيار المحافظة'
          : 'Please choose governorate');
      return;
    }

    // ── التحقق من عدد الإعلانات في Firebase ──
    setState(() => _checkingLimit = true);
    final canPublish = await _checkAdsLimit();
    setState(() => _checkingLimit = false);

    if (!canPublish) {
      _showLimitDialog(_s(l, 'maxAdsMsg'), Icons.inventory_2_outlined);
      return;
    }

    setState(() => _publishing = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      List<String> imageUrls = [];
      if (_images.isNotEmpty) imageUrls = await _uploadImages();

      // بناء رقم الواتساب الكامل
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

      // حفظ رقم الواتساب في الملف الشخصي
      if (user != null && fullPhone.isNotEmpty) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'phone': fullPhone}).catchError((_) {});
      }

      await FirebaseFirestore.instance.collection('ads').add({
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
        'neighborhood': _neighborhoodCtrl.text.trim(),
        'currency': _currency,
        'condition': _condition,
        'description': _descCtrl.text.trim(),
        'userId': user?.uid ?? '',
        'userName': user?.displayName ?? '',
        'userPhoto': user?.photoURL ?? '',
        'shareLinks': shareLinksForFirestore,
        'images': imageUrls,
        'videoUrl': _videoCtrl.text.trim(),
        'lang': l,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await _clearDraft();
      if (!mounted) return;
      setState(() => _publishing = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_s(l, 'publishSuccess')),
          backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showSnack(
          'Error: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}');
    }
  }

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
                          _saveDraft();
                          Navigator.pop(context);
                        },
                      )),
                  ListTile(
                    leading: Icon(Icons.more_horiz, color: cat.color, size: 20),
                    title: Text('${cat.name} - ${_s(l, 'general')}',
                        textAlign: _textAlign,
                        style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat.name;
                        _selectedSubCategory = null;
                      });
                      _saveDraft();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          )),
        ]),
      ),
    );
  }

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
                  activeColor: const Color(0xFFFFD600)),
              title: Text(type, textAlign: _textAlign),
            )),
        const SizedBox(height: 16),
      ]),
    );
  }

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
                    _saveDraft();
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
      // ── واتساب: رقم مع رمز الدولة ──
      Row(children: [
        if (!isRtl) ...[
          const Icon(Icons.chat, color: Color(0xFF25D366), size: 18),
          const SizedBox(width: 6),
        ],
        Text('WhatsApp',
            style: const TextStyle(
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
          // حقل الرقم أولاً ثم رمز الدولة في RTL
          Expanded(
            child: TextField(
              controller: _waPhoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              onChanged: (_) => _saveDraft(),
              decoration: _inputDecoration('1511 234 5678').copyWith(
                prefixIcon: hasPhone
                    ? Icon(Icons.check_circle,
                        color: const Color(0xFF25D366), size: 20)
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
          // رمز الدولة أولاً في LTR
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
              onChanged: (_) => _saveDraft(),
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
      const SizedBox(height: 4),
      Align(
        alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          isRtl
              ? 'سيُحفظ تلقائياً في ملفك الشخصي'
              : 'Saved automatically to your profile',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ),
      const SizedBox(height: 16),
      const Divider(height: 1),
      const SizedBox(height: 12),
      // ── باقي المنصات (روابط) ──
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
      const SizedBox(height: 12),
      _buildLabel(_s(l, 'adTitle')),
      const SizedBox(height: 8),
      TextField(
          controller: _titleCtrl,
          textAlign: _textAlign,
          textDirection: _textDir,
          maxLength: 65,
          onChanged: (_) => _saveDraft(),
          decoration: _inputDecoration(_s(l, 'titleHint'))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // قراءة اللغة من الـ context مباشرة — يتحدث تلقائياً
    final l = Localizations.localeOf(context).languageCode;
    // تحديث _langCode إذا تغيرت اللغة (لاستخدامه في الدوال الأخرى)
    if (_langCode != l) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          setState(() {
            _langCode = l;
            _condition = _s(l, 'new');
            _priceType = _s(l, 'fixed');
            _adType = _s(l, 'sell');
          });
      });
    }
    final user = FirebaseAuth.instance.currentUser;
    final conditionOptions = [
      _s(l, 'new'),
      _s(l, 'likeNew'),
      _s(l, 'used'),
      _s(l, 'gift')
    ];
    final adTypeOptions = [_s(l, 'sell'), _s(l, 'search')];
    final isBusy = _publishing || _uploadingImages || _checkingLimit;

    return Directionality(
      textDirection: _textDir,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(_s(l, 'publishAd'),
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
              onPressed: () async {
                await _saveDraft();
                _showSnack(_s(l, 'draftSaved'));
              },
              child: Text(_s(l, 'save'),
                  style: const TextStyle(
                      color: Color(0xFFFFD600), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          // نوع الإعلان
          _buildSection(
              child: Row(
                  children: adTypeOptions
                      .map((type) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _adType = type);
                                _saveDraft();
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    color: _adType == type
                                        ? const Color(0xFFFFD600)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: _adType == type
                                            ? const Color(0xFFFFD600)
                                            : Colors.grey.shade300)),
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
                      .toList())),

          const SizedBox(height: 8),

          // الصور + التواصل + عنوان
          _buildSection(
              child: Column(crossAxisAlignment: _crossAlign, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (l != 'ar') _buildLabel(_s(l, 'photos')),
              // ── عداد الصور مع شريط تقدم ──
              Row(children: [
                Text('${_images.length}/$_maxPhotos',
                    style: TextStyle(
                        color: _images.length >= _maxPhotos
                            ? Colors.orange
                            : Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: _images.length >= _maxPhotos
                            ? FontWeight.bold
                            : FontWeight.normal)),
                if (_images.length >= _maxPhotos) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 14),
                ],
              ]),
              if (l == 'ar' || l == 'ckb') _buildLabel(_s(l, 'photos')),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                        color: _images.length >= _maxPhotos
                            ? Colors.orange.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _images.length >= _maxPhotos
                                ? Colors.orange.shade300
                                : Colors.grey.shade300)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _images.length >= _maxPhotos
                                  ? Icons.block
                                  : Icons.add_photo_alternate_outlined,
                              color: _images.length >= _maxPhotos
                                  ? Colors.orange
                                  : Colors.grey.shade400,
                              size: 28),
                          const SizedBox(height: 4),
                          Text(
                              _images.length >= _maxPhotos
                                  ? '$_maxPhotos/$_maxPhotos'
                                  : _s(l, 'addPhoto'),
                              style: TextStyle(
                                  color: _images.length >= _maxPhotos
                                      ? Colors.orange
                                      : Colors.grey.shade500,
                                  fontSize: 11)),
                        ]),
                  ),
                ),
                ..._images.asMap().entries.map((entry) {
                  final i = entry.key;
                  return Stack(children: [
                    Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: MemoryImage(_imageBytes[i]),
                                fit: BoxFit.cover))),
                    Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                            onTap: () => setState(() {
                                  _images.removeAt(i);
                                  _imageBytes.removeAt(i);
                                }),
                            child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 14)))),
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
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)))),
                  ]);
                }),
              ]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildSharePlatforms(l),
          ])),

          const SizedBox(height: 8),

          // القسم
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
                              fontSize: 14)),
                    ]),
              ),
            ),
          ])),

          const SizedBox(height: 8),

          // رابط الفيديو
          _buildSection(
              child: Column(crossAxisAlignment: _crossAlign, children: [
            _buildLabel(_s(l, 'videoLink')),
            const SizedBox(height: 8),
            TextField(
                controller: _videoCtrl,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.url,
                onChanged: (_) => _saveDraft(),
                decoration: _inputDecoration(_s(l, 'videoHint'))),
          ])),

          const SizedBox(height: 8),

          // الوصف
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
                onChanged: (_) => _saveDraft(),
                decoration: _inputDecoration(_s(l, 'descHint'))),
          ])),

          const SizedBox(height: 8),

          // السعر
          _buildSection(
              child: Column(crossAxisAlignment: _crossAlign, children: [
            _buildLabel(_s(l, 'price')),
            const SizedBox(height: 8),

            // ── زر "خاص" toggle ──
            GestureDetector(
              onTap: () {
                setState(() => _pricePrivate = !_pricePrivate);
                _saveDraft();
              },
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
                        _pricePrivate ? Icons.lock : Icons.lock_open_outlined,
                        color: _pricePrivate
                            ? const Color(0xFF3B5BDB)
                            : Colors.grey.shade500,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _s(l, 'private'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _pricePrivate
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _pricePrivate
                              ? const Color(0xFF3B5BDB)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ]),
                    Switch(
                      value: _pricePrivate,
                      onChanged: (v) {
                        setState(() => _pricePrivate = v);
                        _saveDraft();
                      },
                      activeColor: const Color(0xFF3B5BDB),
                    ),
                  ],
                ),
              ),
            ),

            // ── حقل السعر + العملة — مخفي عند تفعيل الخاص ──
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
                      onChanged: (_) => _saveDraft(),
                      decoration: _inputDecoration('500').copyWith(
                          prefixText: _currency == 'USD' ? '\$ ' : null,
                          prefixStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          suffix: _currency == 'SYP'
                              ? const Text('ل.س',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                              : null),
                    )),
                const SizedBox(width: 8),
                Expanded(
                    flex: 2,
                    child: GestureDetector(
                        onTap: _showPriceTypePicker,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.expand_more,
                                    color: Colors.grey, size: 18),
                                Expanded(
                                  child: Text(
                                    _priceType,
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ]),
                        ))),
              ]),
            ] else ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l == 'ar' || l == 'ckb' || l == 'ku'
                      ? 'سيظهر للمشترين "سعر خاص" بدل السعر — سيتواصلون معك للاستفسار'
                      : 'Buyers will see "Special Price" instead of a price — they\'ll contact you',
                  textAlign: _textAlign,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF3B5BDB).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ])),

          const SizedBox(height: 8),

          // الحالة
          _buildSection(
              child: Column(crossAxisAlignment: _crossAlign, children: [
            _buildLabel(_s(l, 'condition')),
            const SizedBox(height: 8),
            Wrap(
              alignment: l == 'ar' || l == 'ckb'
                  ? WrapAlignment.end
                  : WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: conditionOptions
                  .map((c) => GestureDetector(
                        onTap: () {
                          setState(() => _condition = c);
                          _saveDraft();
                        },
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
                                      : Colors.grey.shade300)),
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

          // الموقع
          _buildSection(
              child: Column(crossAxisAlignment: _crossAlign, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (l != 'ar') _buildLabel(_s(l, 'location')),
              TextButton.icon(
                onPressed: _loadingLocation ? null : _getLocation,
                icon: _loadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                    _loadingLocation ? _s(l, 'locating') : _s(l, 'autoLocate'),
                    style: const TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD600)),
              ),
              if (l == 'ar' || l == 'ckb') _buildLabel(_s(l, 'location')),
            ]),
            const SizedBox(height: 8),
            // استبدلنا حقول المدينة/الرمز/الشارع بقائمة المحافظات وحقل الحي
            DropdownButtonFormField<String>(
              value: _selectedGovernorate,
              decoration: _inputDecoration(_s(l, 'location')),
              items: _iraqGovernorates
                  .map((g) => DropdownMenuItem(
                      value: g, child: Text(g, textAlign: _textAlign)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedGovernorate = v;
                });
                _saveDraft();
              },
            ),
            const SizedBox(height: 8),
            TextField(
                controller: _neighborhoodCtrl,
                textAlign: _textAlign,
                textDirection: _textDir,
                onChanged: (_) => _saveDraft(),
                decoration: _inputDecoration('اكتب في اسم الحي او المكان')),
          ])),

          const SizedBox(height: 8),

          // معلومات المستخدم
          _buildSection(
              child: ListTile(
            contentPadding: EdgeInsets.zero,
            trailing: l == 'ar' || l == 'ckb'
                ? CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: user?.photoURL == null
                        ? Text(
                            user?.displayName?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(fontWeight: FontWeight.bold))
                        : null,
                  )
                : null,
            leading: l != 'ar'
                ? CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: user?.photoURL == null
                        ? Text(
                            user?.displayName?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(fontWeight: FontWeight.bold))
                        : null,
                  )
                : const Icon(Icons.chevron_left, color: Colors.grey),
            title: Text(user?.displayName ?? _s(l, 'user'),
                textAlign: _textAlign,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(_s(l, 'contactInfo'),
                textAlign: _textAlign,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          )),

          const SizedBox(height: 16),

          // زر النشر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isBusy ? null : _publish,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: isBusy
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
                                _checkingLimit
                                    ? _s(l, 'checkingLimit')
                                    : _uploadingImages
                                        ? _s(l, 'uploadingImages')
                                        : _s(l, 'publishing'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ])
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(_s(l, 'publishBtn'),
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                          ]),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ])),
      ),
    );
  }

  Widget _buildSection({required Widget child}) => Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: child);

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  Widget _buildCurrencySelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'SYP', label: Text('ليرة سورية')),
        ButtonSegment(value: 'USD', label: Text('دولار أمريكي')),
      ],
      selected: {_currency},
      onSelectionChanged: (newSelection) {
        setState(() {
          _currency = newSelection.first;
        });
        _saveDraft();
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
