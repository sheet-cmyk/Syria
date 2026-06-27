import 'package:flutter/material.dart';
import '../models/models.dart';

// ••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
//  ترجمة أسماء الأقسام والأقسام الفرعية — 6 لغات
// ••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

enum CatKey {
  realEstate,
  vehicles,
  services,
  electronics,
  clothing,
  furniture,
  internet,
  electricTools,
  food,
}

enum SubKey {
  // عقارات
  lands,
  houses,
  apartments,
  shops,
  underConstruction,
  offices,
  farms,
  // مركبات
  cars,
  trucks,
  motorcycles,
  spareParts,
  tires,
  // خدمات
  moving,
  homeMaintenance,
  cleaning,
  carpenter,
  plumbing,
  electrician,
  haircut,
  beauty,
  painting,
  onlineServices,
  translation,
  privateLessons,
  restaurants,
  markets,
  elderCare,
  eventOrganizing,
  marketingDesign,
  // -- جديد: بحث عن عمل --
  jobSearch,
  // إضافات مخصصة حسب طلب المستخدم
  animalsBirds,
  // إلكترونيات
  mobiles,
  laptops,
  tablets,
  smartScreens,
  gamingDevices,
  headphones,
  smartwatches,
  electronicsAccessories,
  // -- جديد: ألعاب فيديو (قسم مستقل داخل إلكترونيات) --
  videoGames,
  // ملابس
  menClothing,
  womenClothing,
  kidsClothing,
  bags,
  accessories,
  // -- جديد: عناية بالبشرة + أدوات حلاقة --
  skinCare,
  shavingTools,
  // مفروشات
  livingRoomFurniture,
  bedroomFurniture,
  kitchenFurniture,
  officeFurniture,
  carpets,
  decor,
  householdItems,
  // إنترنت وخدمات
  wifiOffers,
  simInternet,
  phoneInternet,
  fiveGInternet,
  gasOffers,
  electricityOffers,
  carInsurance,
  // ط·آ£ط·آ¯ط¸ث†ط·آ§ط·ع¾ ط¸ئ’ط¸â€،ط·آ±ط·آ¨ط·آ§ط·آ¦ط¸ظ¹ط·آ©
  powerTools,
  handTools,
  measuringTools,
  gardenTools,
  industrialTools,
  // ط¸â€¦ط¸ث†ط·آ§ط·آ¯ ط·ط›ط·آ°ط·آ§ط·آ¦ط¸ظ¹ط·آ©
  freshFood,
  frozenFood,
  dairyProducts,
  bakedGoods,
  organicFood,
  // ط·ط›ط¸ظ¹ط·آ± ط·آ°ط¸â€‍ط¸ئ’ (ط¸â€¦ط·آ´ط·ع¾ط·آ±ط¸ئ’)
  other,
  // ----- ط·آ¬ط·آ¯ط¸ظ¹ط·آ¯: ط·آµط¸â€ ط¸â€کط¸ظ¾ ط¸ث†ط·آ¸ط·آ§ط·آ¦ط¸ظ¾ ط¸ث†ط·آ®ط·آ¯ط¸â€¦ط·آ§ط·ع¾ ط·آ¨ط·آ¯ط¸ظ¹ط¸â€‍ط·آ© ط¸â€‍ط·آ£ط¸ظ¹ط¸â€ڑط¸ث†ط¸â€ ط·آ© ط·آ§ط¸â€‍ط·آ¹ط·آ±ط¸ث†ط·آ¶ -----
  servicesGeneral,
  jobs,
  tradeProjects,
  winterSection,
  industries,
  transport,
  // ----- ط·آ¬ط·آ¯ط¸ظ¹ط·آ¯: ط·آ¹ط¸â€ڑط·آ§ط·آ±ط·آ§ط·ع¾ ط¸â€‍ط¸â€‍ط·آ¥ط¸ظ¹ط·آ¬ط·آ§ط·آ± -----
  housesForRent,
  apartmentsForRent,
  shopsForRent,
  // ----- جديد: إضافات قسم وظائف وخدمات -----
  contractingServices,
  heavyEquipment,
  buildingMaterials,
  factoriesWorkshops,
  trucksAccessories,
  tourismTravel,
  generalFollowup,
  booksEducation,
  otherMiscellany,
  specialProducts,
  carMechanics,
  buildingEngineer,
}

// ── ترجمة أسماء الأقسام الرئيسية ──
const Map<CatKey, Map<String, String>> _catNames = {
  CatKey.realEstate: {
    'ar': 'عقارات',
    'en': 'Real Estate',
    'de': 'Immobilien',
    'fr': 'Immobilier',
    'sv': 'Fastigheter',
    'tr': 'Emlak'
  },
  CatKey.vehicles: {
    'ar': 'مركبات',
    'en': 'Vehicles',
    'de': 'Fahrzeuge',
    'fr': 'Véhicules',
    'sv': 'Fordon',
    'tr': 'Araçlar'
  },
  CatKey.services: {
    'ar': 'خدمات وبحث عن عمل',
    'en': 'Services & Jobs',
    'de': 'Dienste & Jobsuche',
    'fr': 'Services & Emploi',
    'sv': 'Tjänster & Jobb',
    'tr': 'Hizmetler & İş'
  },
  CatKey.electronics: {
    'ar': 'إلكترونيات',
    'en': 'Electronics',
    'de': 'Elektronik',
    'fr': 'Électronique',
    'sv': 'Elektronik',
    'tr': 'Elektronik'
  },
  CatKey.clothing: {
    'ar': 'ملابس وموضة',
    'en': 'Fashion & Clothing',
    'de': 'Mode & Kleidung',
    'fr': 'Mode & Vêtements',
    'sv': 'Mode & Kläder',
    'tr': 'Moda & Giyim'
  },
  CatKey.furniture: {
    'ar': 'مفروشات',
    'en': 'Furniture',
    'de': 'Möbel',
    'fr': 'Mobilier',
    'sv': 'Möbler',
    'tr': 'Mobilya'
  },
  CatKey.internet: {
    'ar': 'وظائف وخدمات',
    'en': 'Jobs & Services',
    'de': 'Jobs & Dienste',
    'fr': 'Emplois & Services',
    'sv': 'Jobb & Tjänster',
    'tr': 'İşler & Hizmetler'
  },
  CatKey.electricTools: {
    'ar': 'أدوات كهربائية',
    'en': 'Power Tools',
    'de': 'Elektrowerkzeuge',
    'fr': 'Outils électriques',
    'sv': 'Elverktyg',
    'tr': 'Elektrikli Aletler'
  },
  CatKey.food: {
    'ar': 'مواد غذائية',
    'en': 'Food',
    'de': 'Lebensmittel',
    'fr': 'Alimentation',
    'sv': 'Livsmedel',
    'tr': 'Gıda Ürünleri'
  },
};

// ── ترجمة الأقسام الفرعية ──
const Map<SubKey, Map<String, String>> _subNames = {
  // عقارات
  SubKey.lands: {
    'ar': 'أراضي',
    'en': 'Lands',
    'de': 'Grundstücke',
    'fr': 'Terrains',
    'sv': 'Tomter',
    'tr': 'Arazi'
  },
  SubKey.houses: {
    'ar': 'منازل',
    'en': 'Houses',
    'de': 'Häuser',
    'fr': 'Maisons',
    'sv': 'Hus',
    'tr': 'Evler'
  },
  SubKey.apartments: {
    'ar': 'شقق',
    'en': 'Apartments',
    'de': 'Wohnungen',
    'fr': 'Appartements',
    'sv': 'Lägenheter',
    'tr': 'Daireler'
  },
  SubKey.shops: {
    'ar': 'محلات',
    'en': 'Shops',
    'de': 'Geschäfte',
    'fr': 'Boutiques',
    'sv': 'Butiker',
    'tr': 'Dükkanlar'
  },
  SubKey.underConstruction: {
    'ar': 'قيد الإنشاء',
    'en': 'Under Construction',
    'de': 'Im Bau',
    'fr': 'En construction',
    'sv': 'Under byggnation',
    'tr': 'İnşaat Halinde'
  },
  SubKey.offices: {
    'ar': 'مكاتب',
    'en': 'Offices',
    'de': 'Büros',
    'fr': 'Bureaux',
    'sv': 'Kontor',
    'tr': 'Ofisler'
  },
  SubKey.farms: {
    'ar': 'مزارع',
    'en': 'Farms',
    'de': 'Bauernhöfe',
    'fr': 'Fermes',
    'sv': 'Gårdar',
    'tr': 'Çiftlikler'
  },

  // مركبات
  SubKey.cars: {
    'ar': 'سيارات',
    'en': 'Cars',
    'de': 'Autos',
    'fr': 'Voitures',
    'sv': 'Bilar',
    'tr': 'Arabalar'
  },
  SubKey.trucks: {
    'ar': 'شاحنات',
    'en': 'Trucks',
    'de': 'LKWs',
    'fr': 'Camions',
    'sv': 'Lastbilar',
    'tr': 'Kamyonlar'
  },
  SubKey.motorcycles: {
    'ar': 'دراجات نارية',
    'en': 'Motorcycles',
    'de': 'Motorräder',
    'fr': 'Motos',
    'sv': 'Motorcyklar',
    'tr': 'Motosikletler'
  },
  SubKey.spareParts: {
    'ar': 'قطع غيار',
    'en': 'Spare Parts',
    'de': 'Ersatzteile',
    'fr': 'Pièces détachées',
    'sv': 'Reservdelar',
    'tr': 'Yedek Parça'
  },
  SubKey.tires: {
    'ar': 'إطارات',
    'en': 'Tires',
    'de': 'Reifen',
    'fr': 'Pneus',
    'sv': 'Däck',
    'tr': 'Lastikler'
  },

  // خدمات وبحث عن عمل
  SubKey.moving: {
    'ar': 'نقل عفش',
    'en': 'Moving',
    'de': 'Umzug',
    'fr': 'Déménagement',
    'sv': 'Flytt',
    'tr': 'Taşımacılık'
  },
  SubKey.homeMaintenance: {
    'ar': 'صيانة منزلية',
    'en': 'Home Maintenance',
    'de': 'Hausreparaturen',
    'fr': 'Maintenance maison',
    'sv': 'Hemunderhåll',
    'tr': 'Ev Bakımı'
  },
  SubKey.cleaning: {
    'ar': 'خدمات تنظيف',
    'en': 'Cleaning Services',
    'de': 'Reinigungsservice',
    'fr': 'Services de nettoyage',
    'sv': 'Städtjänster',
    'tr': 'Temizlik Hizmetleri'
  },
  SubKey.carpenter: {
    'ar': 'نجار',
    'en': 'Carpenter',
    'de': 'Schreiner',
    'fr': 'Menuisier',
    'sv': 'Snickare',
    'tr': 'Marangoz'
  },
  SubKey.plumbing: {
    'ar': 'سباكة',
    'en': 'Plumbing',
    'de': 'Klempner',
    'fr': 'Plomberie',
    'sv': 'VVS',
    'tr': 'Tesisatçı'
  },
  SubKey.electrician: {
    'ar': 'كهربائي',
    'en': 'Electrician',
    'de': 'Elektriker',
    'fr': 'Électricien',
    'sv': 'Elektriker',
    'tr': 'Elektrikçi'
  },
  SubKey.haircut: {
    'ar': 'حلاقة',
    'en': 'Haircut',
    'de': 'Friseur',
    'fr': 'Coiffure',
    'sv': 'Frisör',
    'tr': 'Kuaför'
  },
  SubKey.beauty: {
    'ar': 'تجميل وعناية',
    'en': 'Beauty & Care',
    'de': 'Schönheit & Pflege',
    'fr': 'Beauté & soins',
    'sv': 'Skönhet & vård',
    'tr': 'Güzellik & Bakım'
  },
  SubKey.painting: {
    'ar': 'دهان وصباغة',
    'en': 'Painting',
    'de': 'Maler',
    'fr': 'Peinture',
    'sv': 'Målare',
    'tr': 'Boyacı'
  },
  SubKey.onlineServices: {
    'ar': 'خدمات أونلاين',
    'en': 'Online Services',
    'de': 'Online-Dienste',
    'fr': 'Services en ligne',
    'sv': 'Onlinetjänster',
    'tr': 'Online Hizmetler'
  },
  SubKey.translation: {
    'ar': 'ترجمة',
    'en': 'Translation',
    'de': 'Übersetzung',
    'fr': 'Traduction',
    'sv': 'Översättning',
    'tr': 'Çeviri'
  },
  SubKey.restaurants: {
    'ar': 'مطاعم',
    'en': 'Restaurants',
    'de': 'Restaurants',
    'fr': 'Restaurants',
    'sv': 'Restauranger',
    'tr': 'Restoranlar'
  },
  SubKey.markets: {
    'ar': 'أسواق',
    'en': 'Markets',
    'de': 'Märkte',
    'fr': 'Marchés',
    'sv': 'Marknader',
    'tr': 'Pazarlar'
  },
  SubKey.privateLessons: {
    'ar': 'دروس خصوصية',
    'en': 'Private Lessons',
    'de': 'Nachhilfe',
    'fr': 'Cours particuliers',
    'sv': 'Privatlektioner',
    'tr': 'Özel Dersler'
  },
  SubKey.elderCare: {
    'ar': 'رعاية مسنين',
    'en': 'Elder Care',
    'de': 'Altenpflege',
    'fr': 'Aide aux personnes âgées',
    'sv': 'Äldreomsorg',
    'tr': 'Yaşlı Bakımı'
  },
  SubKey.eventOrganizing: {
    'ar': 'تنظيم مناسبات',
    'en': 'Event Organizing',
    'de': 'Eventorganisation',
    'fr': 'Organisation d\'événements',
    'sv': 'Evenemangsplanering',
    'tr': 'Etkinlik Org.'
  },
  SubKey.marketingDesign: {
    'ar': 'تسويق وتصميم',
    'en': 'Marketing & Design',
    'de': 'Marketing & Design',
    'fr': 'Marketing & design',
    'sv': 'Marknadsföring',
    'tr': 'Pazarlama & Tasarım'
  },
  SubKey.jobSearch: {
    'ar': 'بحث عن عمل',
    'en': 'Job Search',
    'de': 'Jobsuche',
    'fr': 'Recherche d\'emploi',
    'sv': 'Jobbsökning',
    'tr': 'İş Arama'
  },
  SubKey.animalsBirds: {
    'ar': 'حيوانات وطيور',
    'en': 'Animals & Birds',
    'de': 'Tiere & Vögel',
    'fr': 'Animaux & Oiseaux',
    'sv': 'Djur & Fåglar',
    'tr': 'Hayvanlar & Kuşlar'
  },
  SubKey.servicesGeneral: {
    'ar': 'خدمات عامة',
    'en': 'General Services',
    'de': 'Allgemeine Dienste',
    'fr': 'Services généraux',
    'sv': 'Allmänna tjänster',
    'tr': 'Genel Hizmetler'
  },
  SubKey.jobs: {
    'ar': 'وظائف',
    'en': 'Jobs',
    'de': 'Jobs',
    'fr': 'Emplois',
    'sv': 'Jobb',
    'tr': 'İşler'
  },
  SubKey.tradeProjects: {
    'ar': 'تجارة ومشاريع',
    'en': 'Trade & Projects',
    'de': 'Handel & Projekte',
    'fr': 'Commerce & Projets',
    'sv': 'Handel & Projekt',
    'tr': 'Ticaret & Projeler'
  },
  SubKey.winterSection: {
    'ar': 'قسم الشتاء',
    'en': 'Winter Section',
    'de': 'Winter Abteilung',
    'fr': 'Section Hiver',
    'sv': 'Vintersida',
    'tr': 'Kış Bölümü'
  },
  SubKey.industries: {
    'ar': 'صناعات',
    'en': 'Industries',
    'de': 'Industrien',
    'fr': 'Industries',
    'sv': 'Industrier',
    'tr': 'Sanayiler'
  },
  SubKey.transport: {
    'ar': 'نقليات',
    'en': 'Transport',
    'de': 'Transport',
    'fr': 'Transport',
    'sv': 'Transport',
    'tr': 'Nakliye'
  },
  SubKey.housesForRent: {
    'ar': 'منازل للإيجار',
    'en': 'Houses for Rent',
    'de': 'Häuser zu vermieten',
    'fr': 'Maisons à louer',
    'sv': 'Hus att hyra',
    'tr': 'Kiralık Evler'
  },
  SubKey.apartmentsForRent: {
    'ar': 'شقق للإيجار',
    'en': 'Apartments for Rent',
    'de': 'Wohnungen zu vermieten',
    'fr': 'Appartements à louer',
    'sv': 'Lägenheter att hyra',
    'tr': 'Kiralık Daireler'
  },
  SubKey.shopsForRent: {
    'ar': 'محلات للإيجار',
    'en': 'Shops for Rent',
    'de': 'Geschäfte zu vermieten',
    'fr': 'Boutiques à louer',
    'sv': 'Butiker att hyra',
    'tr': 'Kiralık Dükkanlar'
  },
  // إضافات وظائف وخدمات
  SubKey.contractingServices: {
    'ar': 'مقاولات وخدمات',
    'en': 'Contracting & Services',
    'de': 'Bau & Dienstleistungen',
    'fr': 'Construction et Services',
    'sv': 'Entreprenad & Tjänster',
    'tr': 'Müteahhitlik & Hizmetler'
  },
  SubKey.heavyEquipment: {
    'ar': 'معدات ثقيلة وملحقاتها',
    'en': 'Heavy Equipment',
    'de': 'Schweres Gerät',
    'fr': 'Équipement lourd',
    'sv': 'Tung utrustning',
    'tr': 'Ağır Ekipmanlar'
  },
  SubKey.buildingMaterials: {
    'ar': 'مواد البناء والصناعة',
    'en': 'Building Materials',
    'de': 'Baumaterialien',
    'fr': 'Matériaux de construction',
    'sv': 'Byggmaterial',
    'tr': 'Yapı Malzemeleri'
  },
  SubKey.factoriesWorkshops: {
    'ar': 'مصانع وورش وملحقاتها',
    'en': 'Factories & Workshops',
    'de': 'Fabriken & Werkstätten',
    'fr': 'Usines et Ateliers',
    'sv': 'Fabriker & Verkstäder',
    'tr': 'Fabrikalar & Atölyeler'
  },
  SubKey.trucksAccessories: {
    'ar': 'شاحنات وملحقاتها',
    'en': 'Trucks & Accessories',
    'de': 'LKW & Zubehör',
    'fr': 'Camions et Accessoires',
    'sv': 'Lastbilar & Tillbehör',
    'tr': 'Kamyonlar ve Aksesuarlar'
  },
  SubKey.tourismTravel: {
    'ar': 'سياحة وسفر ومشاوير خاصة',
    'en': 'Tourism & Travel',
    'de': 'Tourismus & Reisen',
    'fr': 'Tourisme et Voyages',
    'sv': 'Turism & Resor',
    'tr': 'Turizm & Seyahat'
  },
  SubKey.generalFollowup: {
    'ar': 'تعقيب وخدمات عامة',
    'en': 'Follow-up & General',
    'de': 'Allgemeine Dienste',
    'fr': 'Services généraux',
    'sv': 'Allmänna tjänster',
    'tr': 'Genel Hizmetler'
  },
  SubKey.booksEducation: {
    'ar': 'كتب وتعليم وخدماتها',
    'en': 'Books & Education',
    'de': 'Bücher & Bildung',
    'fr': 'Livres et Éducation',
    'sv': 'Böcker & Utbildning',
    'tr': 'Kitaplar & Eğitim'
  },
  SubKey.otherMiscellany: {
    'ar': 'منوعات أخرى',
    'en': 'Other Miscellany',
    'de': 'Sonstiges',
    'fr': 'Autre Divers',
    'sv': 'Övrigt',
    'tr': 'Diğer Çeşitli'
  },
  SubKey.specialProducts: {
    'ar': 'منتجات خاصة',
    'en': 'Special Products',
    'de': 'Spezielle Produkte',
    'fr': 'Produits Spéciaux',
    'sv': 'Specialprodukter',
    'tr': 'Özel Ürünler'
  },
  SubKey.carMechanics: {
    'ar': 'مكانيك سيارات',
    'en': 'Car Mechanics',
    'de': 'Automechanik',
    'fr': 'Mécanique Auto',
    'sv': 'Bilmekanik',
    'tr': 'Oto Mekaniği'
  },
  SubKey.buildingEngineer: {
    'ar': 'مهندس مباني',
    'en': 'Building Engineer',
    'de': 'Bauingenieur',
    'fr': 'Ingénieur en bâtiment',
    'sv': 'Byggnadsingenjör',
    'tr': 'İnşaat Mühendisi'
  },

  // إلكترونيات
  SubKey.mobiles: {
    'ar': 'موبايلات',
    'en': 'Mobiles',
    'de': 'Handys',
    'fr': 'Mobiles',
    'sv': 'Mobiler',
    'tr': 'Cep Telefonları'
  },
  SubKey.laptops: {
    'ar': 'لابتوبات',
    'en': 'Laptops',
    'de': 'Laptops',
    'fr': 'Ordinateurs portables',
    'sv': 'Bärbara datorer',
    'tr': 'Dizüstü Bilgisayarlar'
  },
  SubKey.tablets: {
    'ar': 'تابلت',
    'en': 'Tablets',
    'de': 'Tablets',
    'fr': 'Tablettes',
    'sv': 'Surfplattor',
    'tr': 'Tabletler'
  },
  SubKey.smartScreens: {
    'ar': 'شاشات ذكية',
    'en': 'Smart TVs',
    'de': 'Smart-TVs',
    'fr': 'Téléviseurs intelligents',
    'sv': 'Smart-TV',
    'tr': 'Akıllı Ekranlar'
  },
  SubKey.gamingDevices: {
    'ar': 'أجهزة ألعاب',
    'en': 'Gaming Consoles',
    'de': 'Spielkonsolen',
    'fr': 'Consoles de jeux',
    'sv': 'Spelkonsoler',
    'tr': 'Oyun Konsolları'
  },
  SubKey.headphones: {
    'ar': 'سماعات وصوتيات',
    'en': 'Headphones & Audio',
    'de': 'Kopfhörer & Audio',
    'fr': 'Casques & audio',
    'sv': 'Hörlurar & ljud',
    'tr': 'Kulaklık & Ses'
  },
  SubKey.smartwatches: {
    'ar': 'ساعات ذكية',
    'en': 'Smartwatches',
    'de': 'Smartwatches',
    'fr': 'Montres connectées',
    'sv': 'Smartklockor',
    'tr': 'Akıllı Saatler'
  },
  SubKey.electronicsAccessories: {
    'ar': 'إكسسوارات إلكترونية',
    'en': 'Electronics Accessories',
    'de': 'Zubehör',
    'fr': 'Accessoires électroniques',
    'sv': 'Elektroniktillbehör',
    'tr': 'Elektronik Aksesuarlar'
  },
  SubKey.videoGames: {
    'ar': 'ألعاب فيديو',
    'en': 'Video Games',
    'de': 'Videospiele',
    'fr': 'Jeux vidéo',
    'sv': 'Videospel',
    'tr': 'Video Oyunları'
  },

  // ملابس وموضة
  SubKey.menClothing: {
    'ar': 'ملابس رجالية',
    'en': 'Men\'s Clothing',
    'de': 'Herrenkleidung',
    'fr': 'Vêtements homme',
    'sv': 'Herrmode',
    'tr': 'Erkek Giyim'
  },
  SubKey.womenClothing: {
    'ar': 'ملابس نسائية',
    'en': 'Women\'s Clothing',
    'de': 'Damenkleidung',
    'fr': 'Vêtements femme',
    'sv': 'Dammode',
    'tr': 'Kadın Giyim'
  },
  SubKey.kidsClothing: {
    'ar': 'ملابس أطفال',
    'en': 'Kids\' Clothing',
    'de': 'Kinderkleidung',
    'fr': 'Vêtements enfants',
    'sv': 'Barnkläder',
    'tr': 'Çocuk Giyim'
  },
  SubKey.bags: {
    'ar': 'حقائب',
    'en': 'Bags',
    'de': 'Taschen',
    'fr': 'Sacs',
    'sv': 'Väskor',
    'tr': 'Çantalar'
  },
  SubKey.accessories: {
    'ar': 'إكسسوارات',
    'en': 'Accessories',
    'de': 'Accessoires',
    'fr': 'Accessoires',
    'sv': 'Accessoarer',
    'tr': 'Aksesuarlar'
  },
  SubKey.skinCare: {
    'ar': 'عناية بالبشرة',
    'en': 'Skin Care',
    'de': 'Hautpflege',
    'fr': 'Soin de la peau',
    'sv': 'Hudvård',
    'tr': 'Cilt Bakımı'
  },
  SubKey.shavingTools: {
    'ar': 'أدوات حلاقة',
    'en': 'Shaving Tools',
    'de': 'Rasierzubehör',
    'fr': 'Accessoires rasage',
    'sv': 'Rakutrustning',
    'tr': 'Tıraş Araçları'
  },

  // مفروشات
  SubKey.livingRoomFurniture: {
    'ar': 'أثاث غرف جلوس',
    'en': 'Living Room Furniture',
    'de': 'Wohnzimmermöbel',
    'fr': 'Meubles salon',
    'sv': 'Vardagsrumsmöbler',
    'tr': 'Oturma Odası Mobilyası'
  },
  SubKey.bedroomFurniture: {
    'ar': 'أثاث غرف نوم',
    'en': 'Bedroom Furniture',
    'de': 'Schlafzimmermöbel',
    'fr': 'Meubles chambre',
    'sv': 'Sovrumsmöbler',
    'tr': 'Yatak Odası Mobilyası'
  },
  SubKey.kitchenFurniture: {
    'ar': 'أثاث مطابخ',
    'en': 'Kitchen Furniture',
    'de': 'Küchenmöbel',
    'fr': 'Meubles cuisine',
    'sv': 'Köksmöbler',
    'tr': 'Mutfak Mobilyası'
  },
  SubKey.officeFurniture: {
    'ar': 'أثاث مكاتب',
    'en': 'Office Furniture',
    'de': 'Büromöbel',
    'fr': 'Mobilier bureau',
    'sv': 'Kontorsmöbler',
    'tr': 'Ofis Mobilyası'
  },
  SubKey.carpets: {
    'ar': 'سجاد وموكيت',
    'en': 'Carpets & Rugs',
    'de': 'Teppiche',
    'fr': 'Tapis & moquettes',
    'sv': 'Mattor',
    'tr': 'Halı & Kilim'
  },
  SubKey.decor: {
    'ar': 'ديكور وإكسسوارات',
    'en': 'Decor & Accessories',
    'de': 'Deko & Accessoires',
    'fr': 'Déco & accessoires',
    'sv': 'Inredning',
    'tr': 'Dekorasyon & Aksesuar'
  },
  SubKey.householdItems: {
    'ar': 'غراض بيت',
    'en': 'Household Items',
    'de': 'Haushaltswaren',
    'fr': 'Articles ménagers',
    'sv': 'Hushållsartiklar',
    'tr': 'Ev Eşyaları'
  },

  // إنترنت
  SubKey.wifiOffers: {
    'ar': 'عروض واي فاي',
    'en': 'WiFi Offers',
    'de': 'WLAN-Angebote',
    'fr': 'Offres WiFi',
    'sv': 'WiFi-erbjudanden',
    'tr': 'WiFi Teklifleri'
  },
  SubKey.simInternet: {
    'ar': 'إنترنت مع شريحة',
    'en': 'Internet with SIM',
    'de': 'Internet mit SIM',
    'fr': 'Internet avec SIM',
    'sv': 'Internet med SIM',
    'tr': 'SIM\'li İnternet'
  },
  SubKey.phoneInternet: {
    'ar': 'إنترنت مع هاتف',
    'en': 'Internet with Phone',
    'de': 'Internet mit Handy',
    'fr': 'Internet avec tél.',
    'sv': 'Internet med telefon',
    'tr': 'Telefonlu İnternet'
  },
  SubKey.fiveGInternet: {
    'ar': 'عروض إنترنت 5G',
    'en': '5G Internet Offers',
    'de': '5G-Angebote',
    'fr': 'Offres 5G',
    'sv': '5G-erbjudanden',
    'tr': '5G İnternet'
  },
  SubKey.gasOffers: {
    'ar': 'عروض الغاز',
    'en': 'Gas Offers',
    'de': 'Gasangebote',
    'fr': 'Offres gaz',
    'sv': 'Gaserbjudanden',
    'tr': 'Doğalgaz Teklifleri'
  },
  SubKey.electricityOffers: {
    'ar': 'عروض الكهرباء',
    'en': 'Electricity Offers',
    'de': 'Stromangebote',
    'fr': 'Offres électricité',
    'sv': 'Elangebote',
    'tr': 'Elektrik Teklifleri'
  },
  SubKey.carInsurance: {
    'ar': 'تأمين سيارات',
    'en': 'Car Insurance',
    'de': 'Kfz-Versicherung',
    'fr': 'Assurance auto',
    'sv': 'Bilförsäkring',
    'tr': 'Araç Sigortası'
  },

  // أدوات كهربائية ويدوية
  SubKey.powerTools: {
    'ar': 'أدوات كهربائية',
    'en': 'Power Tools',
    'de': 'Elektrowerkzeuge',
    'fr': 'Outils électriques',
    'sv': 'Elverktyg',
    'tr': 'Elektrikli Aletler'
  },
  SubKey.handTools: {
    'ar': 'أدوات يدوية',
    'en': 'Hand Tools',
    'de': 'Handwerkzeuge',
    'fr': 'Outils manuels',
    'sv': 'Handverktyg',
    'tr': 'El Aletleri'
  },
  SubKey.measuringTools: {
    'ar': 'أدوات قياس',
    'en': 'Measuring Tools',
    'de': 'Messwerkzeuge',
    'fr': 'Outils de mesure',
    'sv': 'Mätverktyg',
    'tr': 'Ölçüm Aletleri'
  },
  SubKey.gardenTools: {
    'ar': 'أدوات حديقة',
    'en': 'Garden Tools',
    'de': 'Gartengeräte',
    'fr': 'Outils de jardin',
    'sv': 'Trädgårdsverktyg',
    'tr': 'Bahçe Aletleri'
  },
  SubKey.industrialTools: {
    'ar': 'معدات صناعية',
    'en': 'Industrial Equipment',
    'de': 'Industriemaschinen',
    'fr': 'Équipements industriels',
    'sv': 'Industriutrustning',
    'tr': 'Endüstriyel Ekipman'
  },

  // مواد غذائية
  SubKey.freshFood: {
    'ar': 'منتجات طازجة',
    'en': 'Fresh Products',
    'de': 'Frische Produkte',
    'fr': 'Produits frais',
    'sv': 'Färska produkter',
    'tr': 'Taze Ürünler'
  },
  SubKey.frozenFood: {
    'ar': 'مجمدات',
    'en': 'Frozen Food',
    'de': 'Tiefkühlkost',
    'fr': 'Surgelés',
    'sv': 'Fryst mat',
    'tr': 'Dondurulmuş Gıdalar'
  },
  SubKey.dairyProducts: {
    'ar': 'ألبان وأجبان',
    'en': 'Dairy Products',
    'de': 'Milchprodukte',
    'fr': 'Produits laitiers',
    'sv': 'Mejeriprodukter',
    'tr': 'Süt Ürünleri'
  },
  SubKey.bakedGoods: {
    'ar': 'مخبوزات',
    'en': 'Baked Goods',
    'de': 'Backwaren',
    'fr': 'Produits de boulangerie',
    'sv': 'Bakverk',
    'tr': 'Unlu Mamüller'
  },
  SubKey.organicFood: {
    'ar': 'منتجات عضوية',
    'en': 'Organic Products',
    'de': 'Bio-Produkte',
    'fr': 'Produits biologiques',
    'sv': 'Ekologiska produkter',
    'tr': 'Organik Ürünler'
  },

  // أخرى
  SubKey.other: {
    'ar': 'أخرى',
    'en': 'Other',
    'de': 'Sonstiges',
    'fr': 'Autre',
    'sv': 'Övrigt',
    'tr': 'Diğer'
  },
};

String getCatName(CatKey key, String lang) =>
    _catNames[key]?[lang] ?? _catNames[key]?['ar'] ?? '';

String getSubName(SubKey key, String lang) =>
    _subNames[key]?[lang] ?? _subNames[key]?['ar'] ?? '';

// ••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
List<Category> getCategories(String lang) => [
      // 0 — عقارات
      Category(
        name: getCatName(CatKey.realEstate, lang),
        icon: Icons.home,
        color: const Color(0xFFF59E0B),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.lands, lang),
              icon: Icons.park,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.houses, lang),
              icon: Icons.home,
              color: const Color(0xFF14B8A6)),
          SubCategory(
              name: getSubName(SubKey.apartments, lang),
              icon: Icons.apartment,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.shops, lang),
              icon: Icons.store,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.housesForRent, lang),
              icon: Icons.house_siding,
              color: const Color(0xFFEF4444)),
          SubCategory(
              name: getSubName(SubKey.apartmentsForRent, lang),
              icon: Icons.apartment,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.shopsForRent, lang),
              icon: Icons.storefront,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.underConstruction, lang),
              icon: Icons.construction,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.offices, lang),
              icon: Icons.work,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.farms, lang),
              icon: Icons.grass,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 1 — مركبات
      Category(
        name: getCatName(CatKey.vehicles, lang),
        icon: Icons.directions_car,
        color: const Color(0xFF3B82F6),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.cars, lang),
              icon: Icons.directions_car,
              color: const Color(0xFFEF4444)),
          SubCategory(
              name: getSubName(SubKey.trucks, lang),
              icon: Icons.local_shipping,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.motorcycles, lang),
              icon: Icons.two_wheeler,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.spareParts, lang),
              icon: Icons.build_circle,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.tires, lang),
              icon: Icons.tire_repair,
              color: const Color(0xFF374151)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 2 — خدمات وبحث عن عمل
      Category(
        name: getCatName(CatKey.services, lang),
        icon: Icons.handshake,
        color: const Color(0xFF8B5CF6),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.moving, lang),
              icon: Icons.local_shipping,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.homeMaintenance, lang),
              icon: Icons.build,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.cleaning, lang),
              icon: Icons.cleaning_services,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.carpenter, lang),
              icon: Icons.hardware,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.plumbing, lang),
              icon: Icons.water,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.electrician, lang),
              icon: Icons.bolt,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.haircut, lang),
              icon: Icons.content_cut,
              color: const Color(0xFFEF4444)),
          SubCategory(
              name: getSubName(SubKey.beauty, lang),
              icon: Icons.spa,
              color: const Color(0xFFEC4899)),
          SubCategory(
              name: getSubName(SubKey.painting, lang),
              icon: Icons.format_paint,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.onlineServices, lang),
              icon: Icons.computer,
              color: const Color(0xFF6366F1)),
          SubCategory(
              name: getSubName(SubKey.translation, lang),
              icon: Icons.translate,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.privateLessons, lang),
              icon: Icons.school,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.elderCare, lang),
              icon: Icons.health_and_safety,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.eventOrganizing, lang),
              icon: Icons.event,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.marketingDesign, lang),
              icon: Icons.campaign,
              color: const Color(0xFF10B981)),
          // -- جديد: بحث عن عمل --
          SubCategory(
              name: getSubName(SubKey.jobSearch, lang),
              icon: Icons.manage_search,
              color: const Color(0xFF0EA5E9)),
          SubCategory(
              name: getSubName(SubKey.animalsBirds, lang),
              icon: Icons.pets,
              color: const Color(0xFFEF4444)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 3 — إلكترونيات
      Category(
        name: getCatName(CatKey.electronics, lang),
        icon: Icons.phone_android,
        color: const Color(0xFF6366F1),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.mobiles, lang),
              icon: Icons.phone_android,
              color: const Color(0xFFEF4444)),
          SubCategory(
              name: getSubName(SubKey.laptops, lang),
              icon: Icons.laptop,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.tablets, lang),
              icon: Icons.tablet,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.smartScreens, lang),
              icon: Icons.tv,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.gamingDevices, lang),
              icon: Icons.sports_esports,
              color: const Color(0xFFF97316)),
          // -- جديد: ألعاب فيديو --
          SubCategory(
              name: getSubName(SubKey.videoGames, lang),
              icon: Icons.videogame_asset,
              color: const Color(0xFF7C3AED)),
          SubCategory(
              name: getSubName(SubKey.headphones, lang),
              icon: Icons.headphones,
              color: const Color(0xFF374151)),
          SubCategory(
              name: getSubName(SubKey.smartwatches, lang),
              icon: Icons.watch,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.electronicsAccessories, lang),
              icon: Icons.cable,
              color: const Color(0xFF06B6D4)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 4 — ملابس وموضة
      Category(
        name: getCatName(CatKey.clothing, lang),
        icon: Icons.checkroom,
        color: const Color(0xFF10B981),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.menClothing, lang),
              icon: Icons.person,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.womenClothing, lang),
              icon: Icons.person_2,
              color: const Color(0xFFEC4899)),
          SubCategory(
              name: getSubName(SubKey.kidsClothing, lang),
              icon: Icons.child_care,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.bags, lang),
              icon: Icons.shopping_bag,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.accessories, lang),
              icon: Icons.diamond,
              color: const Color(0xFF10B981)),
          // -- جديد: عناية بالبشرة --
          SubCategory(
              name: getSubName(SubKey.skinCare, lang),
              icon: Icons.face_retouching_natural,
              color: const Color(0xFFEC4899)),
          // -- جديد: أدوات حلاقة --
          SubCategory(
              name: getSubName(SubKey.shavingTools, lang),
              icon: Icons.content_cut,
              color: const Color(0xFF6366F1)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 5 — مفروشات
      Category(
        name: getCatName(CatKey.furniture, lang),
        icon: Icons.weekend,
        color: const Color(0xFF8B5CF6),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.livingRoomFurniture, lang),
              icon: Icons.chair_alt,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.bedroomFurniture, lang),
              icon: Icons.king_bed,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.kitchenFurniture, lang),
              icon: Icons.kitchen,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.officeFurniture, lang),
              icon: Icons.desk,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.carpets, lang),
              icon: Icons.texture,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.decor, lang),
              icon: Icons.format_paint,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.householdItems, lang),
              icon: Icons.inventory_2,
              color: const Color(0xFFEC4899)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 6 — وظائف وخدمات (معدل)
      Category(
        name: getCatName(CatKey.internet, lang),
        icon: Icons.storefront,
        color: const Color(0xFFEF4444),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.servicesGeneral, lang),
              icon: Icons.handyman,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.jobs, lang),
              icon: Icons.work,
              color: const Color(0xFF0EA5E9)),
          SubCategory(
              name: getSubName(SubKey.tradeProjects, lang),
              icon: Icons.business_center,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.winterSection, lang),
              icon: Icons.ac_unit,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.industries, lang),
              icon: Icons.precision_manufacturing,
              color: const Color(0xFFEF4444)),
          SubCategory(
              name: getSubName(SubKey.transport, lang),
              icon: Icons.local_shipping,
              color: const Color(0xFF14B8A6)),
          SubCategory(
              name: getSubName(SubKey.contractingServices, lang),
              icon: Icons.construction,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.heavyEquipment, lang),
              icon: Icons.engineering,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.buildingMaterials, lang),
              icon: Icons.foundation,
              color: const Color(0xFF8B5CF6)),
          SubCategory(
              name: getSubName(SubKey.factoriesWorkshops, lang),
              icon: Icons.factory,
              color: const Color(0xFFEF4444)),
          SubCategory(
              name: getSubName(SubKey.trucksAccessories, lang),
              icon: Icons.local_shipping,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.tourismTravel, lang),
              icon: Icons.flight_takeoff,
              color: const Color(0xFF0EA5E9)),
          SubCategory(
              name: getSubName(SubKey.generalFollowup, lang),
              icon: Icons.assignment_turned_in,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.booksEducation, lang),
              icon: Icons.menu_book,
              color: const Color(0xFF6366F1)),
          SubCategory(
              name: getSubName(SubKey.carMechanics, lang),
              icon: Icons.build_circle,
              color: const Color(0xFF374151)),
          SubCategory(
              name: getSubName(SubKey.buildingEngineer, lang),
              icon: Icons.architecture,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.specialProducts, lang),
              icon: Icons.star,
              color: const Color(0xFFEAB308)),
          SubCategory(
              name: getSubName(SubKey.otherMiscellany, lang),
              icon: Icons.category,
              color: const Color(0xFF9CA3AF)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 7 — أدوات كهربائية
      Category(
        name: getCatName(CatKey.electricTools, lang),
        icon: Icons.electrical_services,
        color: const Color(0xFF3B82F6),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.powerTools, lang),
              icon: Icons.electrical_services,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.handTools, lang),
              icon: Icons.hardware,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.measuringTools, lang),
              icon: Icons.straighten,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.gardenTools, lang),
              icon: Icons.yard,
              color: const Color(0xFF84CC16)),
          SubCategory(
              name: getSubName(SubKey.industrialTools, lang),
              icon: Icons.precision_manufacturing,
              color: const Color(0xFF6366F1)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
      // 8 — مواد غذائية
      Category(
        name: getCatName(CatKey.food, lang),
        icon: Icons.restaurant,
        color: const Color(0xFFEF4444),
        subCategories: [
          SubCategory(
              name: getSubName(SubKey.freshFood, lang),
              icon: Icons.eco,
              color: const Color(0xFF10B981)),
          SubCategory(
              name: getSubName(SubKey.frozenFood, lang),
              icon: Icons.ac_unit,
              color: const Color(0xFF3B82F6)),
          SubCategory(
              name: getSubName(SubKey.dairyProducts, lang),
              icon: Icons.local_cafe,
              color: const Color(0xFFF59E0B)),
          SubCategory(
              name: getSubName(SubKey.bakedGoods, lang),
              icon: Icons.bakery_dining,
              color: const Color(0xFFF97316)),
          SubCategory(
              name: getSubName(SubKey.organicFood, lang),
              icon: Icons.grass,
              color: const Color(0xFF84CC16)),
          SubCategory(
              name: getSubName(SubKey.other, lang),
              icon: Icons.more_horiz,
              color: const Color(0xFF9CA3AF)),
        ],
      ),
    ];

final List<Category> categories = getCategories('ar');

// ••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
final List<Map<String, String>> banners = [
  {
    'title': 'استثمر في مشروع رقمي طموح',
    'subtitle': 'تواصل معنا الآن.',
    'image': 'assets/images/banner1.jpg',
  },
  {
    'title': 'إعلانك يصل إلى العملاء في كل مكان',
    'subtitle': 'احجز مساحتك الإعلانية الآن.',
    'image': 'assets/images/banner2.jpg',
  },
  {
    'title': 'شقة في أفضل المناطق',
    'subtitle': 'تواصل معنا الآن.',
    'image': 'assets/images/banner3.jpg',
  },
];

List<AdModel> sampleAds = [];
