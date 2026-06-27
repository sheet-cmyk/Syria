import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../data/data.dart';
import '../utils/location_helper.dart';

// ✅ ضع API Key هنا
const String _kApiKey = 'AIzaSyCVJcCqBFoJjuFeAjK_nPfcHlRTmYfbEe8';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  // ── Map ──────────────────────────────────────────────
  final Completer<GoogleMapController> _mapCtrl = Completer();
  LatLng _center = const LatLng(51.1657, 10.4515); // مركز ألمانيا افتراضي
  Set<Circle> _circles = {};

  // ── Search ───────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<_PlaceSuggestion> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounce;

  // ── Slider ───────────────────────────────────────────
  double _radiusKm = 5;

  // ── State ────────────────────────────────────────────
  bool _loadingLocation = false;
  bool _geocoding = false;
  String _locationName = '';

  @override
  void initState() {
    super.initState();
    _updateCircle();
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Circle ───────────────────────────────────────────
  void _updateCircle() {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('radius'),
          center: _center,
          radius: _radiusKm * 1000,
          fillColor: const Color(0xFF3B5BDB).withOpacity(0.15),
          strokeColor: const Color(0xFF3B5BDB).withOpacity(0.6),
          strokeWidth: 2,
        ),
      };
    });
  }

  // ── GPS ──────────────────────────────────────────────
  Future<void> _useMyLocation() async {
    setState(() => _loadingLocation = true);
    final pos = await LocationHelper.getCurrentPosition();
    if (pos != null) {
      _center = LatLng(pos.latitude, pos.longitude);
      _updateCircle();
      await _reverseGeocode(_center);
      final ctrl = await _mapCtrl.future;
      ctrl.animateCamera(
          CameraUpdate.newLatLngZoom(_center, _zoomFor(_radiusKm)));
    }
    setState(() => _loadingLocation = false);
  }

  // ── Reverse Geocoding ────────────────────────────────
  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _geocoding = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${pos.latitude},${pos.longitude}'
        '&key=$_kApiKey'
        '&language=de',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // نأخذ postal_code + locality
          String postal = '';
          String city = '';
          for (final comp in data['results'][0]['address_components']) {
            final types = List<String>.from(comp['types']);
            if (types.contains('postal_code')) postal = comp['short_name'];
            if (types.contains('locality')) city = comp['long_name'];
          }
          final name = [postal, city].where((s) => s.isNotEmpty).join(' ');
          setState(() {
            _locationName = name.isNotEmpty
                ? name
                : data['results'][0]['formatted_address'];
            _searchCtrl.text = _locationName;
          });
        }
      }
    } catch (_) {}
    setState(() => _geocoding = false);
  }

  // ── Places Autocomplete ──────────────────────────────
  Future<void> _onSearchChanged(String query) async {
    _debounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=$_kApiKey'
          '&language=de'
          '&components=country:de|country:at|country:ch|country:fr|country:it|country:es|country:nl|country:be|country:pl|country:cz|country:dk|country:se|country:no|country:fi|country:pt|country:hu|country:ro|country:gr|country:hr|country:sk|country:si|country:bg|country:lt|country:lv|country:ee|country:lu|country:ie|country:cy|country:mt'
          '&types=geocode',
        );
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final preds = data['predictions'] as List? ?? [];
          setState(() {
            _suggestions = preds
                .map((p) => _PlaceSuggestion(
                      placeId: p['place_id'],
                      description: p['description'],
                    ))
                .toList();
            _showSuggestions = _suggestions.isNotEmpty;
          });
        }
      } catch (_) {}
    });
  }

  Future<void> _selectSuggestion(_PlaceSuggestion s) async {
    _searchFocus.unfocus();
    setState(() {
      _showSuggestions = false;
      _searchCtrl.text = s.description;
      _locationName = s.description;
    });
    // جلب إحداثيات المكان
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${s.placeId}'
        '&fields=geometry'
        '&key=$_kApiKey',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final loc = data['result']['geometry']['location'];
        _center = LatLng(loc['lat'], loc['lng']);
        _updateCircle();
        final ctrl = await _mapCtrl.future;
        ctrl.animateCamera(
            CameraUpdate.newLatLngZoom(_center, _zoomFor(_radiusKm)));
      }
    } catch (_) {}
  }

  // ── Camera idle → reverse geocode ───────────────────
  void _onCameraMove(CameraPosition pos) {
    _center = pos.target;
    _updateCircle();
  }

  void _onCameraIdle() {
    _reverseGeocode(_center);
  }

  // ── Zoom helper ──────────────────────────────────────
  double _zoomFor(double km) {
    if (km <= 2) return 14;
    if (km <= 5) return 13;
    if (km <= 10) return 12;
    if (km <= 20) return 11;
    if (km <= 50) return 10;
    if (km <= 100) return 9;
    return 8;
  }

  // ── Apply ────────────────────────────────────────────
  void _apply() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = sampleAds
        .where((ad) => ad.latitude != null && ad.longitude != null)
        .where((ad) {
      final d = LocationHelper.distanceInKm(
        _center.latitude,
        _center.longitude,
        ad.latitude!,
        ad.longitude!,
      );
      if (d > _radiusKm) return false;
      if (q.isEmpty) return true;
      return ad.title.toLowerCase().contains(q) ||
          ad.category.toLowerCase().contains(q);
    }).toList();

    Navigator.pop(context, {
      'ads': filtered,
      'location': _center,
      'radius': _radiusKm,
      'locationName': _locationName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── AppBar ──────────────────────────────
                _buildAppBar(),

                // ── Search Bar ──────────────────────────
                _buildSearchBar(),

                // ── Map ─────────────────────────────────
                Expanded(child: _buildMap()),

                // ── Slider + Button ─────────────────────
                _buildBottom(),
              ],
            ),

            // ── Suggestions Overlay ──────────────────
            if (_showSuggestions) _buildSuggestionsOverlay(),
          ],
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_forward, size: 24),
          ),
          const Expanded(
            child: Text(
              'اختيار الموقع',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: _apply,
            child: Row(
              children: const [
                Icon(Icons.check, color: Color(0xFF22C55E), size: 20),
                SizedBox(width: 4),
                Text(
                  'تطبيق',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              textDirection: TextDirection.ltr,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن مدينة أو منطقة...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: _geocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _showSuggestions = false);
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // زر GPS
          GestureDetector(
            onTap: _loadingLocation ? null : _useMyLocation,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3B5BDB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: _loadingLocation
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location,
                      color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: _zoomFor(_radiusKm),
          ),
          onMapCreated: (c) {
            _mapCtrl.complete(c);
            _updateCircle();
          },
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          circles: _circles,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        // ── Pin ثابت في المنتصف ──
        const Positioned(
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 48,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottom() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── عنوان الـ Slider مثل eBay ──
          Text(
            'Umkreis: ${_radiusKm.round()} km',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF3B5BDB),
              inactiveTrackColor: const Color(0xFFE5E7EB),
              thumbColor: const Color(0xFF22C55E),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
              overlayColor: const Color(0xFF3B5BDB).withOpacity(0.15),
            ),
            child: Slider(
              value: _radiusKm,
              min: 1,
              max: 100,
              onChanged: (v) async {
                setState(() => _radiusKm = v);
                _updateCircle();
                final ctrl = await _mapCtrl.future;
                ctrl.animateCamera(
                  CameraUpdate.newLatLngZoom(_center, _zoomFor(v)),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('100 km',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              Text('1 km',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BDB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'تطبيق الفلتر',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Positioned(
      top: 120, // تحت الـ search bar
      left: 16,
      right: 68,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestions.length > 5 ? 5 : _suggestions.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (_, i) {
              final s = _suggestions[i];
              return ListTile(
                leading: const Icon(Icons.location_on_outlined,
                    color: Color(0xFF6B7280), size: 20),
                title: Text(
                  s.description,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _selectSuggestion(s),
                dense: true,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────
class _PlaceSuggestion {
  final String placeId;
  final String description;
  const _PlaceSuggestion({required this.placeId, required this.description});
}
