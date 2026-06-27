import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../services/admin_service.dart';

// ═══════════════════════════════════════════════════════════════
//  لوحة تحكم المشرف الرئيسية
// ═══════════════════════════════════════════════════════════════

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _deviceIdCtrl = TextEditingController();
  final _userSearchCtrl = TextEditingController();
  bool _searchingDevice = false;
  Map<String, dynamic>? _foundDevice;
  String? _searchedDeviceId;
  String _userFilter = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _deviceIdCtrl.dispose();
    _userSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFFFFD600)),
              SizedBox(width: 8),
              Text('لوحة التحكم',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: const Color(0xFF1F2937),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tab,
            labelColor: const Color(0xFFFFD600),
            unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFFFFD600),
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.campaign, size: 20), text: 'الإعلانات'),
              Tab(icon: Icon(Icons.gavel, size: 20), text: 'المزادات'),
              Tab(icon: Icon(Icons.people, size: 20), text: 'المستخدمون'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            _buildAdsTab(),
            _buildAuctionsTab(),
            _buildUsersTab(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  //  تبويب الإعلانات
  // ══════════════════════════════════════════════════

  Widget _buildAdsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: AdminService.streamAllAds(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD600)));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('لا توجد إعلانات'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _AdAdminCard(docId: doc.id, data: data);
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  تبويب المزادات
  // ══════════════════════════════════════════════════

  Widget _buildAuctionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: AdminService.streamAllAuctions(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD600)));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('لا توجد مزادات'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _AuctionAdminCard(docId: doc.id, data: data);
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════
  //  تبويب المستخدمون والأجهزة
  // ══════════════════════════════════════════════════

  Widget _buildUsersTab() {
    return Column(
      children: [
        // بحث عن جهاز بالـ Device ID
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('حظر جهاز بالمعرف (Device ID)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF374151))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _deviceIdCtrl,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'أدخل Device ID...',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _searchingDevice ? null : _searchDevice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 11),
                    ),
                    icon: _searchingDevice
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.search, size: 18),
                    label: const Text('بحث', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
              if (_searchedDeviceId != null) ...[
                const SizedBox(height: 10),
                _DeviceBanCard(
                  deviceId: _searchedDeviceId!,
                  data: _foundDevice,
                  onRefresh: _searchDevice,
                ),
              ],
            ],
          ),
        ),

        const Divider(height: 1),

        // فلترة المستخدمين
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _userSearchCtrl,
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => setState(() => _userFilter = v.trim()),
            decoration: InputDecoration(
              hintText: 'بحث عن مستخدم بالاسم أو البريد...',
              prefixIcon:
                  const Icon(Icons.search, size: 18, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: AdminService.streamAllUsers(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD600)));
              }
              var docs = snap.data?.docs ?? [];
              if (_userFilter.isNotEmpty) {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final q = _userFilter.toLowerCase();
                  return name.contains(q) || email.contains(q);
                }).toList();
              }
              if (docs.isEmpty) {
                return const Center(child: Text('لا يوجد مستخدمون'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  return _UserAdminCard(userId: doc.id, data: data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _searchDevice() async {
    final id = _deviceIdCtrl.text.trim();
    if (id.isEmpty) return;
    setState(() {
      _searchingDevice = true;
      _foundDevice = null;
      _searchedDeviceId = id;
    });
    try {
      final doc =
          await FirebaseFirestore.instance.collection('devices').doc(id).get();
      if (mounted) {
        setState(() => _foundDevice = doc.exists ? doc.data() : {});
      }
    } catch (_) {
      if (mounted) setState(() => _foundDevice = {});
    } finally {
      if (mounted) setState(() => _searchingDevice = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  كارد إعلان في لوحة التحكم
// ═══════════════════════════════════════════════════════════════

class _AdAdminCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _AdAdminCard({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(data['images'] ?? []);
    final title = data['title'] ?? 'بلا عنوان';
    final price = data['price'] ?? '';
    final city = data['city'] ?? '';
    final currency = data['currency'] ?? 'SYP';
    final isSpecialPrice = data['isSpecialPrice'] == true || price == 'سعر خاص';
    final priceStr = isSpecialPrice
        ? 'سعر خاص'
        : (currency == 'USD' ? '\$$price' : '$price ل.س');
    final hidden = data['hidden'] == true;
    final deleted = data['status'] == 'deleted';
    final userId = data['userId'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: hidden
            ? Border.all(color: Colors.orange.shade300, width: 1.5)
            : deleted
                ? Border.all(color: Colors.red.shade200, width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          // المحتوى الرئيسي
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة مصغرة
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: images.first,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _noImage(),
                        )
                      : _noImage(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (hidden) _badge('مخفي', Colors.orange),
                          if (deleted) _badge('محذوف', Colors.red),
                          if (!hidden && !deleted) _badge('نشط', Colors.green),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('$priceStr • $city',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // أزرار الإجراءات
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              children: [
                // إخفاء / إظهار
                _ActionBtn(
                  icon: hidden ? Icons.visibility : Icons.visibility_off,
                  label: hidden ? 'إظهار' : 'إخفاء',
                  color: Colors.orange,
                  onTap: () => _toggleVisibility(context, hidden),
                ),
                // تعديل
                _ActionBtn(
                  icon: Icons.edit,
                  label: 'تعديل',
                  color: const Color(0xFF3B5BDB),
                  onTap: () => _showEditDialog(context, images),
                ),
                // استبدال صورة
                _ActionBtn(
                  icon: Icons.photo_camera,
                  label: 'الصور',
                  color: const Color(0xFF059669),
                  onTap: () => _showImagesDialog(context, images),
                ),
                // حظر صاحب الإعلان
                if (userId.isNotEmpty)
                  _ActionBtn(
                    icon: Icons.block,
                    label: 'حظر',
                    color: Colors.deepOrange,
                    onTap: () => _showBanUserDialog(context, userId),
                  ),
                // حذف نهائي
                _ActionBtn(
                  icon: Icons.delete_forever,
                  label: 'حذف',
                  color: Colors.red,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVisibility(BuildContext context, bool isHidden) async {
    final err = await AdminService.toggleAdVisibility(docId, !isHidden);
    if (context.mounted) {
      _snack(
          context, err ?? (isHidden ? 'تم إظهار الإعلان' : 'تم إخفاء الإعلان'),
          isError: err != null);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الإعلان نهائياً', textAlign: TextAlign.right),
        content: const Text('سيُحذف الإعلان بشكل نهائي ولا يمكن التراجع عنه.',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await AdminService.deleteAdPermanently(docId);
    if (context.mounted) {
      _snack(context, err ?? 'تم حذف الإعلان نهائياً', isError: err != null);
    }
  }

  void _showEditDialog(BuildContext context, List<String> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminEditAdSheet(docId: docId, data: data),
    );
  }

  void _showImagesDialog(BuildContext context, List<String> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminImagesSheet(docId: docId, images: images),
    );
  }

  void _showBanUserDialog(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BanDialog(
        title: 'حظر صاحب الإعلان',
        onBan: (until) async => AdminService.banUser(userId, until: until),
      ),
    );
  }

  Widget _noImage() => Container(
        width: 70,
        height: 70,
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.campaign, color: Color(0xFF9CA3AF), size: 30),
      );

  Widget _badge(String label, Color color) => Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      );
}

// ═══════════════════════════════════════════════════════════════
//  كارد مزاد في لوحة التحكم
// ═══════════════════════════════════════════════════════════════

class _AuctionAdminCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _AuctionAdminCard({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(data['images'] ?? []);
    final title = data['title'] ?? 'بلا عنوان';
    final price =
        (data['currentPrice'] ?? data['startingPrice'] ?? 0).toStringAsFixed(0);
    final city = data['city'] ?? '';
    final status = data['status'] ?? 'active';
    final hidden = data['hidden'] == true;
    final cancelled = status == 'cancelled';
    final sellerId = data['sellerId'] ?? '';

    Color statusColor = Colors.green;
    String statusLabel = 'نشط';
    if (cancelled) {
      statusColor = Colors.red;
      statusLabel = 'ملغى';
    } else if (hidden) {
      statusColor = Colors.orange;
      statusLabel = 'مخفي';
    } else if (status == 'sold') {
      statusColor = Colors.blue;
      statusLabel = 'مُباع';
    } else if (status == 'expired') {
      statusColor = Colors.grey;
      statusLabel = 'منتهي';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: hidden || cancelled
            ? Border.all(
                color: cancelled ? Colors.red.shade200 : Colors.orange.shade300,
                width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: images.first,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _noImage(),
                        )
                      : _noImage(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(statusLabel,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor)),
                      ),
                      const SizedBox(height: 4),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('$price ل.س • $city',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              children: [
                _ActionBtn(
                  icon: hidden ? Icons.visibility : Icons.visibility_off,
                  label: hidden ? 'إظهار' : 'إخفاء',
                  color: Colors.orange,
                  onTap: () => _toggleVisibility(context, hidden),
                ),
                _ActionBtn(
                  icon: Icons.edit,
                  label: 'تعديل',
                  color: const Color(0xFF3B5BDB),
                  onTap: () => _showEditDialog(context),
                ),
                if (!cancelled && status == 'active' || status == 'endingSoon')
                  _ActionBtn(
                    icon: Icons.cancel_outlined,
                    label: 'إلغاء المزاد',
                    color: Colors.deepOrange,
                    onTap: () => _confirmCancel(context),
                  ),
                if (sellerId.isNotEmpty)
                  _ActionBtn(
                    icon: Icons.block,
                    label: 'حظر',
                    color: Colors.deepOrange,
                    onTap: () => _showBanUserDialog(context, sellerId),
                  ),
                _ActionBtn(
                  icon: Icons.delete_forever,
                  label: 'حذف',
                  color: Colors.red,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVisibility(BuildContext context, bool isHidden) async {
    final err = await AdminService.toggleAuctionVisibility(docId, !isHidden);
    if (context.mounted) {
      _snack(context, err ?? (isHidden ? 'تم إظهار المزاد' : 'تم إخفاء المزاد'),
          isError: err != null);
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء المزاد', textAlign: TextAlign.right),
        content: const Text('سيُلغى المزاد فوراً ويُخفى من التطبيق.',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('تراجع')),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إلغاء المزاد'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await AdminService.cancelAuction(docId);
    if (context.mounted) {
      _snack(context, err ?? 'تم إلغاء المزاد', isError: err != null);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المزاد نهائياً', textAlign: TextAlign.right),
        content: const Text('سيُحذف المزاد وكل مزايداته نهائياً.',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await AdminService.deleteAuctionPermanently(docId);
    if (context.mounted) {
      _snack(context, err ?? 'تم حذف المزاد نهائياً', isError: err != null);
    }
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminEditAuctionSheet(docId: docId, data: data),
    );
  }

  void _showBanUserDialog(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BanDialog(
        title: 'حظر صاحب المزاد',
        onBan: (until) async => AdminService.banUser(userId, until: until),
      ),
    );
  }

  Widget _noImage() => Container(
        width: 70,
        height: 70,
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.gavel, color: Color(0xFF9CA3AF), size: 30),
      );
}

// ═══════════════════════════════════════════════════════════════
//  كارد مستخدم في لوحة التحكم
// ═══════════════════════════════════════════════════════════════

class _UserAdminCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;

  const _UserAdminCard({required this.userId, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'مجهول';
    final email = data['email'] ?? '';
    final photo = data['photoUrl'] ?? '';
    final banned = data['banned'] == true;
    final bannedUntil = data['bannedUntil'] as Timestamp?;
    final isPermanent = banned && bannedUntil == null;
    final isTempBanned = banned &&
        bannedUntil != null &&
        bannedUntil.toDate().isAfter(DateTime.now());
    final isAdmin = data['isAdmin'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            banned ? Border.all(color: Colors.red.shade200, width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // صورة المستخدم
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE5E7EB),
              child: photo.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photo,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _initials(name),
                      ),
                    )
                  : _initials(name),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFD600).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('مشرف',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E))),
                        ),
                      ],
                    ],
                  ),
                  Text(email,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280)),
                      overflow: TextOverflow.ellipsis),
                  if (banned) ...[
                    const SizedBox(height: 2),
                    Text(
                      isPermanent
                          ? 'محظور دائماً'
                          : isTempBanned
                              ? 'محظور حتى: ${_formatDate(bannedUntil.toDate())}'
                              : 'انتهى الحظر',
                      style: TextStyle(
                          fontSize: 10,
                          color: isTempBanned || isPermanent
                              ? Colors.red
                              : Colors.orange),
                    ),
                  ],
                ],
              ),
            ),
            // أزرار
            Column(
              children: [
                if (!banned)
                  TextButton(
                    onPressed: () => _showBanDialog(context),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('حظر', style: TextStyle(fontSize: 12)),
                  )
                else
                  TextButton(
                    onPressed: () => _unban(context),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child:
                        const Text('رفع الحظر', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BanDialog(
        title: 'حظر المستخدم',
        onBan: (until) async => AdminService.banUser(userId, until: until),
      ),
    );
  }

  Future<void> _unban(BuildContext context) async {
    final err = await AdminService.unbanUser(userId);
    if (context.mounted) {
      _snack(context, err ?? 'تم رفع الحظر عن المستخدم', isError: err != null);
    }
  }

  Widget _initials(String name) => Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B7280)),
      );

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ═══════════════════════════════════════════════════════════════
//  كارد بحث الجهاز
// ═══════════════════════════════════════════════════════════════

class _DeviceBanCard extends StatelessWidget {
  final String deviceId;
  final Map<String, dynamic>? data;
  final Future<void> Function() onRefresh;

  const _DeviceBanCard({
    required this.deviceId,
    required this.data,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)));
    }

    final notFound = data!.isEmpty;
    final banned = data!['banned'] == true;
    final bannedUntil = data!['bannedUntil'] as Timestamp?;
    final accounts = List<String>.from(data!['accounts'] ?? []);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notFound
            ? Colors.grey.shade50
            : banned
                ? Colors.red.shade50
                : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: notFound
                ? Colors.grey.shade300
                : banned
                    ? Colors.red.shade200
                    : Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                notFound
                    ? Icons.device_unknown
                    : banned
                        ? Icons.block
                        : Icons.phone_android,
                size: 16,
                color: notFound
                    ? Colors.grey
                    : banned
                        ? Colors.red
                        : Colors.green,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  notFound
                      ? 'الجهاز غير موجود في قاعدة البيانات'
                      : banned
                          ? 'الجهاز محظور'
                          : 'الجهاز غير محظور',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: notFound
                          ? Colors.grey
                          : banned
                              ? Colors.red
                              : Colors.green),
                ),
              ),
            ],
          ),
          if (!notFound) ...[
            const SizedBox(height: 4),
            Text('معرف الجهاز: $deviceId',
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            if (accounts.isNotEmpty)
              Text('عدد الحسابات: ${accounts.length}',
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            if (banned && bannedUntil != null)
              Text(
                  'محظور حتى: ${bannedUntil.toDate().day}/${bannedUntil.toDate().month}/${bannedUntil.toDate().year}',
                  style: const TextStyle(fontSize: 10, color: Colors.red)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (!notFound && banned)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _unban(context),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: const TextStyle(fontSize: 12)),
                    child: const Text('رفع الحظر'),
                  ),
                ),
              if (!banned) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showBanDeviceDialog(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: const TextStyle(fontSize: 12)),
                    child: const Text('حظر هذا الجهاز'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showBanDeviceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BanDialog(
        title: 'حظر الجهاز',
        onBan: (until) async => AdminService.banDevice(deviceId, until: until),
        onDone: onRefresh,
      ),
    );
  }

  Future<void> _unban(BuildContext context) async {
    final err = await AdminService.unbanDevice(deviceId);
    if (context.mounted) {
      _snack(context, err ?? 'تم رفع الحظر عن الجهاز', isError: err != null);
    }
    await onRefresh();
  }
}

// ═══════════════════════════════════════════════════════════════
//  نافذة تعديل إعلان (Bottom Sheet)
// ═══════════════════════════════════════════════════════════════

class AdminEditAdSheet extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const AdminEditAdSheet({super.key, required this.docId, required this.data});

  @override
  State<AdminEditAdSheet> createState() => _AdminEditAdSheetState();
}

class _AdminEditAdSheetState extends State<AdminEditAdSheet> {
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _price;
  late TextEditingController _city;
  late TextEditingController _category;
  late TextEditingController _subCategory;
  late String _currency;
  bool _isSpecialPrice = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _title = TextEditingController(text: d['title'] ?? '');
    _desc = TextEditingController(text: d['description'] ?? '');
    _price = TextEditingController(text: d['price'] ?? '');
    _city = TextEditingController(text: d['city'] ?? '');
    _category = TextEditingController(text: d['category'] ?? '');
    _subCategory = TextEditingController(text: d['subCategory'] ?? '');
    _currency = d['currency'] ?? 'SYP';
    _isSpecialPrice = d['isSpecialPrice'] == true || d['price'] == 'سعر خاص';
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    _city.dispose();
    _category.dispose();
    _subCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('تعديل الإعلان',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _field('العنوان', _title),
              _field('الوصف', _desc, maxLines: 4),
              SwitchListTile(
                title: const Text('سعر خاص',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600)),
                value: _isSpecialPrice,
                onChanged: (v) => setState(() => _isSpecialPrice = v),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF3B5BDB),
              ),
              if (!_isSpecialPrice) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child:
                          _field('السعر', _price, type: TextInputType.number),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: _buildCurrencyDropdown(),
                    ),
                  ],
                ),
              ],
              _field('المدينة', _city),
              _field('القسم الرئيسي', _category),
              _field('القسم الفرعي', _subCategory),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('حفظ التعديلات',
                          style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('العملة',
            style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currency,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'SYP', child: Text('ل.س')),
                DropdownMenuItem(value: 'USD', child: Text('\$')),
              ],
              onChanged: (v) => setState(() => _currency = v!),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final err = await AdminService.updateAd(widget.docId, {
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'price': _isSpecialPrice ? 'سعر خاص' : _price.text.trim(),
      'isSpecialPrice': _isSpecialPrice,
      'currency': _currency,
      'city': _city.text.trim(),
      'category': _category.text.trim(),
      'subCategory': _subCategory.text.trim(),
    });
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    _snack(context, err ?? 'تم حفظ التعديلات بنجاح', isError: err != null);
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: type,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  نافذة تعديل مزاد (Bottom Sheet)
// ═══════════════════════════════════════════════════════════════

class AdminEditAuctionSheet extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const AdminEditAuctionSheet(
      {super.key, required this.docId, required this.data});

  @override
  State<AdminEditAuctionSheet> createState() => _AdminEditAuctionSheetState();
}

class _AdminEditAuctionSheetState extends State<AdminEditAuctionSheet> {
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _city;
  late TextEditingController _startPrice;
  late TextEditingController _minIncrement;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _title = TextEditingController(text: d['title'] ?? '');
    _desc = TextEditingController(text: d['description'] ?? '');
    _city = TextEditingController(text: d['city'] ?? '');
    _startPrice =
        TextEditingController(text: (d['startingPrice'] ?? 0).toString());
    _minIncrement =
        TextEditingController(text: (d['minBidIncrement'] ?? 1).toString());
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _city.dispose();
    _startPrice.dispose();
    _minIncrement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('تعديل المزاد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _field('العنوان', _title),
              _field('الوصف', _desc, maxLines: 3),
              _field('المدينة', _city),
              _field('سعر البداية (ل.س)', _startPrice,
                  type: TextInputType.number),
              _field('الحد الأدنى للمزايدة (ل.س)', _minIncrement,
                  type: TextInputType.number),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('حفظ التعديلات',
                          style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final updates = <String, dynamic>{
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'city': _city.text.trim(),
      'minBidIncrement': double.tryParse(_minIncrement.text) ?? 1.0,
    };
    final totalBids = widget.data['totalBids'] ?? 0;
    if (totalBids == 0) {
      final sp = double.tryParse(_startPrice.text);
      if (sp != null) {
        updates['startingPrice'] = sp;
        updates['currentPrice'] = sp;
      }
    }
    final err = await AdminService.updateAuction(widget.docId, updates);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    _snack(context, err ?? 'تم حفظ التعديلات بنجاح', isError: err != null);
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: type,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  نافذة إدارة صور الإعلان
// ═══════════════════════════════════════════════════════════════

class AdminImagesSheet extends StatefulWidget {
  final String docId;
  final List<String> images;

  const AdminImagesSheet(
      {super.key, required this.docId, required this.images});

  @override
  State<AdminImagesSheet> createState() => _AdminImagesSheetState();
}

class _AdminImagesSheetState extends State<AdminImagesSheet> {
  late List<String> _images;
  bool _uploading = false;
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.images);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Text('إدارة صور الإعلان',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // قائمة الصور الحالية
              if (_images.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child:
                      Text('لا توجد صور', style: TextStyle(color: Colors.grey)),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (_, i) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: _images[i],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(i),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // إضافة صورة من المعرض (موبايل فقط)
              if (!kIsWeb)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickAndUpload,
                    icon: _uploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_photo_alternate),
                    label: const Text('رفع صورة من المعرض'),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),

              // إضافة صورة برابط URL
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlCtrl,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'أو أدخل رابط صورة URL...',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addUrlImage,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12)),
                    child: const Text('إضافة'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveImages,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BDB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child:
                      const Text('حفظ الصور', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null || !mounted) return;
    setState(() => _uploading = true);
    final err = await AdminService.replaceAdImage(
        widget.docId, _images.length, await picked.readAsBytes());
    if (!mounted) return;
    setState(() => _uploading = false);
    if (err != null) {
      _snack(context, err, isError: true);
    } else {
      // إعادة تحميل الصور
      final doc = await FirebaseFirestore.instance
          .collection('ads')
          .doc(widget.docId)
          .get();
      if (mounted) {
        setState(() {
          _images = List<String>.from(doc.data()?['images'] ?? _images);
        });
      }
    }
  }

  void _addUrlImage() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() => _images.add(url));
    _urlCtrl.clear();
  }

  void _removeImage(int i) {
    setState(() => _images.removeAt(i));
  }

  Future<void> _saveImages() async {
    String? err;
    try {
      await FirebaseFirestore.instance
          .collection('ads')
          .doc(widget.docId)
          .update({'images': _images});
    } catch (_) {
      err = 'فشل الحفظ';
    }
    if (!mounted) return;
    Navigator.pop(context);
    _snack(context, err ?? 'تم حفظ الصور بنجاح', isError: err != null);
  }
}

// ═══════════════════════════════════════════════════════════════
//  نافذة الحظر (Bottom Sheet)
// ═══════════════════════════════════════════════════════════════

class BanDialog extends StatefulWidget {
  final String title;
  final Future<String?> Function(DateTime? until) onBan;
  final Future<void> Function()? onDone;

  const BanDialog(
      {super.key, required this.title, required this.onBan, this.onDone});

  @override
  State<BanDialog> createState() => _BanDialogState();
}

class _BanDialogState extends State<BanDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Row(
              children: [
                const Icon(Icons.block, color: Colors.red),
                const SizedBox(width: 8),
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ..._banOptions(),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _banOptions() {
    final options = [
      ('حظر مؤقت - يوم واحد', DateTime.now().add(const Duration(days: 1))),
      ('حظر مؤقت - أسبوع', DateTime.now().add(const Duration(days: 7))),
      ('حظر مؤقت - شهر', DateTime.now().add(const Duration(days: 30))),
      ('حظر دائم', null),
    ];

    return options.map((opt) {
      final isPermanent = opt.$2 == null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : () => _doBan(opt.$2),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPermanent ? Colors.red : Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(opt.$1, style: const TextStyle(fontSize: 13)),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _doBan(DateTime? until) async {
    setState(() => _loading = true);
    final err = await widget.onBan(until);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    _snack(
        context, err ?? (until == null ? 'تم الحظر الدائم' : 'تم الحظر المؤقت'),
        isError: err != null);
    await widget.onDone?.call();
  }
}

// ═══════════════════════════════════════════════════════════════
//  زر إجراء مشترك
// ═══════════════════════════════════════════════════════════════

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  مساعدة: SnackBar
// ═══════════════════════════════════════════════════════════════

void _snack(BuildContext context, String msg, {bool isError = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, textAlign: TextAlign.right),
    backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF059669),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));
}
