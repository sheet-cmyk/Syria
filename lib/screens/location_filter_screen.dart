import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ads_list_screen.dart';

// ── بيانات الدول والمدن ──
const Map<String, Map<String, dynamic>> _countriesData = {
  'سوريا': {
    'flag': '🇸🇾',
    'cities': [
      // محافظات سوريا
      'دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماه', 'اللاذقية', 'طرطوس',
      'إدلب', 'دير الزور', 'الحسكة', 'الرقة', 'درعا', 'السويداء', 'القنيطرة',
      // مدن وأحياء دمشق
      'المزة', 'المالكي', 'أبو رمانة', 'الشعلان', 'القصاع', 'باب توما',
      'باب شرقي', 'الميدان', 'كفرسوسة', 'دمر', 'قدسيا', 'الربوة',
      'جرمانا', 'السيدة زينب', 'صحنايا', 'يلدا', 'بيت سحم', 'التضامن',
      'المعضمية', 'داريا', 'سقبا', 'حرستا', 'دوما', 'عربين', 'زملكا',
      'عين ترما', 'القابون', 'تشرين', 'برزة', 'العباسيين', 'ركن الدين',
      // مدن حلب
      'حلب القديمة', 'الشهباء', 'العزيزية', 'الجميلية', 'السبيل', 'الشعار',
      'الفردوس', 'الأشرفية', 'صلاح الدين', 'الحيدرية', 'الشيخ سعيد',
      'الراموسة', 'مساكن هنانو', 'نيو أليبو', 'الزهراء',
      // مدن حمص
      'حمص القديمة', 'الوعر', 'الخالدية', 'بابا عمرو', 'الحمراء',
      'تلبيسة', 'الرستن', 'تدمر', 'القريتين',
      // مدن أخرى
      'جبلة', 'بانياس', 'صافيتا', 'مصياف', 'سلمية', 'شيزر',
      'عفرين', 'اعزاز', 'الباب', 'منبج', 'القامشلي', 'عامودا',
      'البوكمال', 'الميادين', 'المعدامية', 'قطنا', 'الكسوة',
      'صيدنايا', 'معلولا', 'عرطوز', 'الضمير',
    ],
  },
  'ألمانيا': {
    'flag': '🇩🇪',
    'cities': [
      'Berlin',
      'Hamburg',
      'München',
      'Köln',
      'Frankfurt',
      'Stuttgart',
      'Düsseldorf',
      'Leipzig',
      'Dortmund',
      'Essen',
      'Bremen',
      'Dresden',
      'Hannover',
      'Nürnberg',
      'Duisburg',
      'Bochum',
      'Wuppertal',
      'Bielefeld',
      'Bonn',
      'Münster',
      'Karlsruhe',
      'Mannheim',
      'Augsburg',
      'Wiesbaden',
      'Gelsenkirchen',
      'Mönchengladbach',
      'Braunschweig',
      'Chemnitz',
      'Kiel',
      'Aachen',
      'Halle',
      'Magdeburg',
      'Freiburg',
      'Oberhausen',
      'Lübeck',
      'Erfurt',
      'Rostock',
      'Kassel',
      'Mainz',
      'Hamm',
    ],
  },
  'فرنسا': {
    'flag': '🇫🇷',
    'cities': [
      'Paris',
      'Marseille',
      'Lyon',
      'Toulouse',
      'Nice',
      'Nantes',
      'Strasbourg',
      'Montpellier',
      'Bordeaux',
      'Lille',
      'Rennes',
      'Reims',
      'Saint-Étienne',
      'Toulon',
      'Le Havre',
      'Grenoble',
      'Dijon',
      'Angers',
      'Nîmes',
      'Villeurbanne',
      'Saint-Denis',
      'Le Mans',
      'Aix-en-Provence',
      'Clermont-Ferrand',
      'Brest',
      'Limoges',
      'Tours',
      'Amiens',
      'Perpignan',
      'Metz',
    ],
  },
  'السويد': {
    'flag': '🇸🇪',
    'cities': [
      'Stockholm',
      'Göteborg',
      'Malmö',
      'Uppsala',
      'Västerås',
      'Örebro',
      'Linköping',
      'Helsingborg',
      'Jönköping',
      'Norrköping',
      'Lund',
      'Umeå',
      'Gävle',
      'Borås',
      'Södertälje',
      'Eskilstuna',
      'Halmstad',
      'Växjö',
      'Karlstad',
      'Sundsvall',
      'Östersund',
      'Trollhättan',
      'Luleå',
      'Borlänge',
      'Falun',
    ],
  },
  'هولندا': {
    'flag': '🇳🇱',
    'cities': [
      'Amsterdam',
      'Rotterdam',
      'Den Haag',
      'Utrecht',
      'Eindhoven',
      'Tilburg',
      'Groningen',
      'Almere',
      'Breda',
      'Nijmegen',
      'Apeldoorn',
      'Haarlem',
      'Arnhem',
      'Zaanstad',
      'Amersfoort',
      'Haarlemmermeer',
      'Den Bosch',
      'Zoetermeer',
      'Zwolle',
      'Enschede',
      'Leiden',
      'Dordrecht',
      'Westland',
      'Maastricht',
      'Emmen',
    ],
  },
  'اليونان': {
    'flag': '🇬🇷',
    'cities': [
      'Athens',
      'Thessaloniki',
      'Patras',
      'Heraklion',
      'Larissa',
      'Volos',
      'Ioannina',
      'Trikala',
      'Chalcis',
      'Serres',
      'Alexandroupoli',
      'Xanthi',
      'Katerini',
      'Kalamata',
      'Kavala',
      'Corfu',
      'Rhodes',
      'Chania',
      'Lamia',
      'Agrinio',
    ],
  },
};

class LocationFilterScreen extends StatefulWidget {
  const LocationFilterScreen({super.key});

  @override
  State<LocationFilterScreen> createState() => _LocationFilterScreenState();
}

class _LocationFilterScreenState extends State<LocationFilterScreen> {
  String? _selectedCountry;
  String? _selectedCity;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // اعرض قائمة المدن السورية افتراضياً
    _selectedCountry = 'سوريا';
  }

  List<String> get _filteredCities {
    if (_selectedCountry == null) return [];
    final cities = List<String>.from(
        (_countriesData[_selectedCountry]!['cities'] as List));
    if (_searchQuery.isEmpty) return cities;
    return cities
        .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _applyFilter(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filter_city', city);
    await prefs.setString('filter_country', _selectedCountry ?? '');
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdsListScreen(
          categoryName: 'جميع الإعلانات',
          filterCity: city,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('فلترة حسب الموقع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFFFFD600),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── اختيار الدولة ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('اختر الدولة',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _countriesData.entries.map((entry) {
                      final isSelected = _selectedCountry == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedCountry = entry.key;
                          _selectedCity = null;
                          _searchCtrl.clear();
                          _searchQuery = '';
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFD600)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD600)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(entry.key,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                              const SizedBox(width: 6),
                              Text(entry.value['flag'] as String,
                                  style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── البحث في المدن ──
          if (_selectedCountry != null) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchCtrl,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مدينة...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const Divider(height: 1),

            // ── قائمة المدن ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filteredCities.length,
                itemBuilder: (_, i) {
                  final city = _filteredCities[i];
                  final isSelected = _selectedCity == city;
                  return ListTile(
                    onTap: () => _applyFilter(city),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFFFFD600))
                        : const Icon(Icons.location_on_outlined,
                            color: Colors.grey, size: 20),
                    title: Text(
                      city,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                    tileColor: isSelected ? const Color(0xFFFFFDE7) : null,
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('اختر دولة لعرض المدن',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
