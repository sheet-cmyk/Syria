import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/auction_model.dart';
import '../services/auction_service.dart';
import '../services/auth_service.dart';
import '../gen_l10n/app_localizations.dart';
import '../utils/thousands_formatter.dart';

class AddAuctionScreen extends StatefulWidget {
  const AddAuctionScreen({super.key});

  @override
  State<AddAuctionScreen> createState() => _AddAuctionScreenState();
}

class _AddAuctionScreenState extends State<AddAuctionScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startPriceCtrl = TextEditingController();
  final _incrementCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  bool _contactLoaded = false;

  // Arabic keys stored in Firestore — display text is localized separately
  static const _catKeys = [
    'إلكترونيات',
    'سيارات',
    'تلفون',
    'كمبيوتر',
    'لابتوب',
    'شاحنة',
    'أدوات زراعية',
    'ملابس',
    'أثاث',
    'عقارات',
    'أخرى',
  ];
  String _categoryKey = 'إلكترونيات';
  DateTime _endTime = DateTime.now().add(const Duration(days: 3));
  final List<XFile> _images = [];
  final List<Uint8List> _imageBytes = [];
  String _currency = 'SYP'; // 'SYP' or 'USD'
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _prefillContactFromProfile();
  }

  Future<void> _prefillContactFromProfile() async {
    if (_contactLoaded) return;
    final data = await AuthService.getUserData();
    if (!mounted || data == null) return;
    final social = Map<String, dynamic>.from(data['socialLinks'] ?? {});
    setState(() {
      _contactLoaded = true;
      _phoneCtrl.text = (data['phone'] as String? ?? '');
      _whatsappCtrl.text = (social['whatsapp'] as String? ?? '');
      _facebookCtrl.text = (social['facebook'] as String? ?? '');
      _instagramCtrl.text = (social['instagram'] as String? ?? '');
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _startPriceCtrl.dispose();
    _incrementCtrl.dispose();
    _cityCtrl.dispose();
    _videoCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _facebookCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  List<String> _catLabels(AppLocalizations l10n) => [
        l10n.auctionCatElectronics,
        l10n.auctionCatCars,
        'تلفون',
        'كمبيوتر',
        'لابتوب',
        'شاحنة',
        'أدوات زراعية',
        l10n.auctionCatClothing,
        l10n.auctionCatFurniture,
        l10n.auctionCatRealEstate,
        l10n.auctionCatOther,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.auctionAddNew,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildSection(l10n.auctionImagesSection, _buildImagePicker(l10n)),
            _buildSection(l10n.auctionInfoSection, _buildInfoFields(l10n)),
            _buildSection(l10n.auctionPriceDuration, _buildPriceFields(l10n)),
            _buildSection('معلومات التواصل', _buildContactFields()),
            const SizedBox(height: 20),
            _buildSubmitButton(l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937))),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            children: [
              GestureDetector(
                onTap: () => _pickImage(l10n),
                child: Container(
                  width: 90,
                  height: 90,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF3B5BDB), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF3B5BDB).withValues(alpha: 0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate,
                          color: Color(0xFF3B5BDB), size: 28),
                      const SizedBox(height: 4),
                      Text(l10n.auctionAddPhoto,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF3B5BDB))),
                    ],
                  ),
                ),
              ),
              ..._images.asMap().entries.map((entry) {
                final idx = entry.key;
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: MemoryImage(_imageBytes[idx]),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _images.removeAt(idx);
                          _imageBytes.removeAt(idx);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoFields(AppLocalizations l10n) {
    final labels = _catLabels(l10n);
    return Column(
      children: [
        _field(_titleCtrl, l10n.auctionTitleField, Icons.title),
        const SizedBox(height: 10),
        _field(_descCtrl, l10n.description, Icons.description, maxLines: 3),
        const SizedBox(height: 10),
        _field(_cityCtrl, l10n.city, Icons.location_on),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categoryKey,
              isExpanded: true,
              onChanged: (v) => setState(() => _categoryKey = v!),
              items: List.generate(
                _catKeys.length,
                (i) => DropdownMenuItem(
                  value: _catKeys[i],
                  child: Text(labels[i]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceFields(AppLocalizations l10n) {
    return Column(
      children: [
        _buildCurrencySelector(),
        const SizedBox(height: 12),
        _field(_startPriceCtrl, 'السعر الابتدائي', null,
            isNumber: true,
            prefixText: _currency == 'USD' ? '\$' : null,
            suffixText: _currency == 'SYP' ? 'ل.س' : null),
        const SizedBox(height: 10),
        _field(_incrementCtrl, 'الحد الأدنى للزيادة', null,
            isNumber: true,
            prefixText: _currency == 'USD' ? '\$' : null,
            suffixText: _currency == 'SYP' ? 'ل.س' : null),
        const SizedBox(height: 10),
        _field(_videoCtrl, l10n.videoLink, Icons.play_circle_outline,
            isUrl: true),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _pickEndTime,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_endTime.day}/${_endTime.month}/${_endTime.year} ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
                Row(
                  children: [
                    Text(l10n.auctionEndDate,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280))),
                    const SizedBox(width: 6),
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF3B5BDB), size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        // رقم الهاتف (مطلوب)
        Row(
          children: [
            Expanded(
              child: _field(_phoneCtrl, 'رقم الهاتف *', Icons.phone,
                  isPhone: true),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // واتساب (اختياري)
        _field(_whatsappCtrl, 'رقم واتساب (اختياري)', Icons.chat,
            isPhone: true),
        const SizedBox(height: 10),
        // فيسبوك (اختياري)
        _field(_facebookCtrl, 'رابط فيسبوك (اختياري)', Icons.facebook,
            isUrl: true),
        const SizedBox(height: 10),
        // إنستقرام (اختياري)
        _field(_instagramCtrl, 'رابط إنستقرام (اختياري)',
            Icons.camera_alt_outlined,
            isUrl: true),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '* ستُرسل معلومات التواصل للفائز عند انتهاء المزاد',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ],
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
        setState(() {
          _currency = newSelection.first;
        });
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

  Widget _field(TextEditingController ctrl, String hint, IconData? icon,
      {int maxLines = 1,
      bool isNumber = false,
      bool isUrl = false,
      bool isPhone = false,
      String? prefixText,
      String? suffixText}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      textAlign: (isUrl || isPhone || prefixText != null)
          ? TextAlign.left
          : TextAlign.right,
      textDirection: (isUrl || isPhone || prefixText != null)
          ? TextDirection.ltr
          : TextDirection.rtl,
      keyboardType: isNumber
          ? TextInputType.number
          : isPhone
              ? TextInputType.phone
              : isUrl
                  ? TextInputType.url
                  : null,
      inputFormatters: [
        if (isNumber) ThousandsFormatter(),
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF9CA3AF), size: 20)
            : null,
        prefixText: prefixText,
        prefixStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w600),
        suffixText: suffixText,
        suffixStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : () => _submit(l10n),
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.gavel),
        label: Text(l10n.auctionPublishBtn,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5BDB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Future<void> _pickImage(AppLocalizations l10n) async {
    if (_images.length >= 5) {
      _showSnack(l10n.maxPhotos);
      return;
    }
    final picker = ImagePicker();
    final allowed = 5 - _images.length;
    final picked = await picker.pickMultiImage(
      imageQuality: 70,
      limit: allowed,
    );
    if (picked.isNotEmpty) {
      final toAdd = picked.take(5 - _images.length).toList();
      final bytesList = await Future.wait(toAdd.map((p) => p.readAsBytes()));
      setState(() {
        _images.addAll(toAdd);
        _imageBytes.addAll(bytesList);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime.now().add(const Duration(hours: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (time == null) return;
    setState(() {
      _endTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit(AppLocalizations l10n) async {
    // ── التحقق من رقم الهاتف في الفورم ──
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showSnack('رقم الهاتف مطلوب للنشر', isError: true);
      return;
    }

    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack(l10n.auctionEnterTitle);
      return;
    }
    final startPrice = double.tryParse(ThousandsFormatter.clean(_startPriceCtrl.text));
    if (startPrice == null || startPrice <= 0) {
      _showSnack(l10n.auctionEnterValidPrice);
      return;
    }
    final increment = double.tryParse(ThousandsFormatter.clean(_incrementCtrl.text)) ?? 1.0;

    setState(() => _loading = true);

    try {
      final imageUrls = <String>[];
      for (int i = 0; i < _imageBytes.length; i++) {
        final ref = FirebaseStorage.instance.ref(
            'auctions/${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg');
        await ref.putData(_imageBytes[i]);
        imageUrls.add(await ref.getDownloadURL());
      }

      final user = AuthService.currentUser!;
      final auction = AuctionModel(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        sellerId: user.uid,
        sellerName: user.displayName ?? 'مجهول',
        sellerPhoto: user.photoURL ?? '',
        sellerVerified: false,
        images: imageUrls,
        category: _categoryKey,
        city: _cityCtrl.text.trim(),
        startingPrice: startPrice,
        currentPrice: startPrice,
        minBidIncrement: increment,
        currency: _currency,
        startTime: DateTime.now(),
        endTime: _endTime,
        totalBids: 0,
        viewCount: 0,
        status: AuctionStatus.active,
        isFeatured: false,
        videoUrl:
            _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
        sellerContact: {
          'phone': _phoneCtrl.text.trim(),
          if (_whatsappCtrl.text.trim().isNotEmpty)
            'whatsapp': _whatsappCtrl.text.trim(),
          if (_facebookCtrl.text.trim().isNotEmpty)
            'facebook': _facebookCtrl.text.trim(),
          if (_instagramCtrl.text.trim().isNotEmpty)
            'instagram': _instagramCtrl.text.trim(),
        },
      );

      final error = await AuctionService.createAuction(auction);
      if (!mounted) return;

      if (error != null) {
        _showSnack(error, isError: true);
      } else {
        _showSnack(l10n.auctionPublishSuccess);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('$e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.right),
      backgroundColor: isError ? Colors.red : const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
