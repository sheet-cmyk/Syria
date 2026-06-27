import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/auction_model.dart';
import '../services/auction_service.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../gen_l10n/app_localizations.dart';
import 'auth_screen.dart';
import 'admin_panel_screen.dart';
import 'chat_screen.dart';
import '../widgets/winner_dialog.dart';

class AuctionDetailScreen extends StatefulWidget {
  final AuctionModel auction;
  const AuctionDetailScreen({super.key, required this.auction});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final _bidCtrl = TextEditingController();
  bool _bidLoading = false;
  bool _winnerDialogShown = false;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _remaining = widget.auction.timeRemaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.auction.timeRemaining);
    });
    AuctionService.incrementViewCount(widget.auction.id);
  }

  String _formatPrice(double price, String currency) {
    if (currency == 'USD') {
      return '\$${price.toInt()}';
    }
    return '${price.toInt()} ل.س';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<AuctionModel?>(
      stream: AuctionService.streamAuction(widget.auction.id),
      builder: (context, snap) {
        final auction = snap.data ?? widget.auction;

        // عرض نافذة الفائز إذا انتهى المزاد وأنت الفائز
        final uid = AuthService.currentUser?.uid;
        if (!_winnerDialogShown &&
            auction.computedStatus == AuctionStatus.sold &&
            uid != null &&
            auction.highestBidderId == uid) {
          _winnerDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            WinnerDialog.show(
              context,
              auctionTitle: auction.title,
              winningPrice: auction.currentPrice,
              sellerName: auction.sellerName,
              sellerPhoto: auction.sellerPhoto,
              onContactSeller: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    friendId: auction.sellerId,
                    friendName: auction.sellerName,
                    friendPhoto: auction.sellerPhoto,
                  ),
                ),
              ),
            );
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          resizeToAvoidBottomInset: true,
          floatingActionButton: AuthService.isAdmin
              ? FloatingActionButton.small(
                  backgroundColor: const Color(0xFF1F2937),
                  tooltip: 'إجراءات المشرف',
                  onPressed: () => _showAdminSheet(context, auction),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Color(0xFFFFD600), size: 20),
                )
              : null,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(auction, l10n),
                    SliverToBoxAdapter(child: _buildInfo(auction)),
                    SliverToBoxAdapter(child: _buildBidSection(auction, l10n)),
                    SliverToBoxAdapter(child: _buildBidHistory(auction, l10n)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
              auction.isActive
                  ? _buildBidBar(auction, l10n)
                  : _buildEndedBar(auction, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AuctionModel auction, AppLocalizations l10n) {
    final isOwner = AuthService.currentUser?.uid == auction.sellerId;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      actions: isOwner
          ? [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: l10n.auctionDeleteTitle,
                onPressed: () => _confirmDelete(auction, l10n),
              ),
            ]
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // عرض الصور
            auction.images.isNotEmpty
                ? PageView.builder(
                    itemCount: auction.images.length,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: auction.images[i],
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.gavel,
                            color: Color(0xFF9CA3AF), size: 60),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.gavel,
                            color: Color(0xFF9CA3AF), size: 60),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.gavel,
                        color: Color(0xFF9CA3AF), size: 80),
                  ),
            // مؤشر الصور
            if (auction.images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    auction.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _imageIndex == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _imageIndex == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(AuctionModel auction) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (auction.sellerVerified)
                    const Icon(Icons.verified,
                        color: Color(0xFF3B5BDB), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    auction.sellerName,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.location_on, text: auction.city),
              _InfoChip(icon: Icons.category, text: auction.category),
              _InfoChip(
                  icon: Icons.remove_red_eye,
                  text:
                      '${auction.viewCount} ${AppLocalizations.of(context)!.views}'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            auction.description,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF374151), height: 1.6),
            textAlign: TextAlign.right,
          ),
          if (auction.videoUrl != null && auction.videoUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _openVideo(auction.videoUrl!),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF3B5BDB).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_filled,
                        color: Color(0xFF3B5BDB), size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.videoLink,
                        style: const TextStyle(
                          color: Color(0xFF3B5BDB),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.touch_app,
                        color: Color(0xFF3B5BDB), size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openVideo(String url) async {
    String clean = url.trim();
    if (!clean.startsWith('http')) clean = 'https://$clean';
    final uri = Uri.tryParse(clean);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildBidSection(AuctionModel auction, AppLocalizations l10n) {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    final isUrgent = _remaining.inHours < 2 && auction.isActive;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent ? Border.all(color: Colors.orange, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFF3B5BDB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      '$h:$m:$s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? Colors.red : const Color(0xFF3B5BDB),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.timer,
                        size: 16,
                        color: isUrgent ? Colors.red : const Color(0xFF3B5BDB)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.auctionCurrentPrice,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF))),
                  Text(
                    _formatPrice(auction.currentPrice, auction.currency),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF059669)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (auction.highestBidderName != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '👑 ${auction.highestBidderName}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669)),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.auctionHighestBidLabel,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '${l10n.auctionMinBidLabel}: ${_formatPrice(auction.currentPrice + auction.minBidIncrement, auction.currency)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBidHistory(AuctionModel auction, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(l10n.auctionBidHistory,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.history, color: Color(0xFF3B5BDB)),
              ],
            ),
          ),
          const Divider(height: 1),
          StreamBuilder<List<BidModel>>(
            stream: AuctionService.streamBids(auction.id),
            builder: (context, snap) {
              final bids = snap.data ?? [];
              if (bids.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                      child: Text(l10n.auctionNoBids,
                          style: const TextStyle(color: Colors.grey))),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bids.length,
                itemBuilder: (_, i) {
                  final bid = bids[i];
                  final isTop = i == 0;
                  return ListTile(
                    trailing: CircleAvatar(
                      radius: 16,
                      backgroundImage: bid.bidderPhoto.isNotEmpty
                          ? NetworkImage(bid.bidderPhoto)
                          : null,
                      child: bid.bidderPhoto.isEmpty
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isTop)
                          const Text('👑 ', style: TextStyle(fontSize: 12)),
                        Text(
                          bid.bidderName,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isTop
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _formatTime(bid.createdAt),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11),
                    ),
                    leading: Text(
                      _formatPrice(bid.amount, auction.currency),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isTop
                              ? const Color(0xFF059669)
                              : const Color(0xFF3B5BDB)),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBidBar(AuctionModel auction, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _bidLoading ? null : () => _placeBid(auction, l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BDB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _bidLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(l10n.auctionBidNow,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _bidCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: _formatPrice(
                    auction.currentPrice + auction.minBidIncrement,
                    auction.currency),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndedBar(AuctionModel auction, AppLocalizations l10n) {
    final isSold = auction.computedStatus == AuctionStatus.sold;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10)],
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSold
              ? const Color(0xFF3B5BDB).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSold
                  ? '${l10n.auctionSoldFor} ${_formatPrice(auction.currentPrice, auction.currency)}'
                  : l10n.auctionEndedNoBids,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSold ? const Color(0xFF3B5BDB) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      AuctionModel auction, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.auctionDeleteTitle, textAlign: TextAlign.right),
        content: Text(l10n.auctionDeleteConfirm, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await AuctionService.deleteAuction(auction.id);
    if (!mounted) return;
    if (error != null) {
      _showSnack(l10n.auctionDeleteFailed, isError: true);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _placeBid(AuctionModel auction, AppLocalizations l10n) async {
    if (!AuthService.isLoggedIn) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    // إذا الحقل فارغ → استخدم الحد الأدنى تلقائياً
    final minAmount = auction.currentPrice + auction.minBidIncrement;
    final amountText = _bidCtrl.text.trim();
    final double amount;
    if (amountText.isEmpty) {
      amount = minAmount;
    } else {
      final parsed = double.tryParse(amountText);
      if (parsed == null) {
        _showSnack(l10n.auctionInvalidAmount);
        return;
      }
      amount = parsed;
    }

    setState(() => _bidLoading = true);

    // جلب بيانات التواصل من الملف الشخصي
    final userData = await AuthService.getUserData();
    if (!mounted) return;
    final social = Map<String, dynamic>.from(userData?['socialLinks'] ?? {});
    final whatsapp = (social['whatsapp'] as String? ?? '').trim();

    // إجبار المشتري على إضافة واتساب قبل المزايدة
    if (whatsapp.isEmpty) {
      setState(() => _bidLoading = false);
      _showWhatsappRequiredDialog();
      return;
    }

    final user = AuthService.currentUser!;
    final bidderContact = <String, String>{
      'email': (user.email ?? userData?['email'] as String? ?? ''),
      if ((userData?['phone'] as String? ?? '').isNotEmpty)
        'phone': userData!['phone'] as String,
      'whatsapp': whatsapp,
      if ((social['facebook'] as String? ?? '').isNotEmpty)
        'facebook': social['facebook'] as String,
      if ((social['instagram'] as String? ?? '').isNotEmpty)
        'instagram': social['instagram'] as String,
    };
    final error = await AuctionService.placeBid(
      auction: auction,
      bidderId: user.uid,
      bidderName: user.displayName ?? 'مجهول',
      bidderPhoto: user.photoURL ?? '',
      amount: amount,
      bidderContact: bidderContact,
    );

    if (!mounted) return;
    setState(() => _bidLoading = false);

    if (error != null) {
      _showSnack(error, isError: true);
    } else {
      _bidCtrl.clear();
      _showSnack(l10n.auctionBidSuccess);
    }
  }

  void _showAdminSheet(BuildContext ctx, AuctionModel auction) {
    final isActive = auction.isActive;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
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
              const Row(children: [
                Icon(Icons.admin_panel_settings, color: Color(0xFFFFD600)),
                SizedBox(width: 8),
                Text('إجراءات المشرف — المزاد',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              _adminTile(Icons.visibility_off, 'إخفاء المزاد', Colors.orange,
                  () async {
                Navigator.pop(_);
                final err = await AdminService.toggleAuctionVisibility(
                    auction.id, true);
                _showSnack(err ?? 'تم إخفاء المزاد', isError: err != null);
              }),
              _adminTile(Icons.edit, 'تعديل المزاد', const Color(0xFF3B5BDB),
                  () {
                Navigator.pop(_);
                showModalBottomSheet(
                  context: ctx,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (__) => AdminEditAuctionSheet(
                    docId: auction.id,
                    data: auction.toMap(),
                  ),
                );
              }),
              if (isActive)
                _adminTile(Icons.cancel_outlined, 'إلغاء المزاد فوراً',
                    Colors.deepOrange, () async {
                  Navigator.pop(_);
                  final ok = await showDialog<bool>(
                    context: ctx,
                    builder: (__) => AlertDialog(
                      title: const Text('إلغاء المزاد',
                          textAlign: TextAlign.right),
                      content: const Text('سيُلغى المزاد فوراً ويُخفى.',
                          textAlign: TextAlign.right),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(__, false),
                            child: const Text('تراجع')),
                        TextButton(
                          onPressed: () => Navigator.pop(__, true),
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('إلغاء المزاد'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    final err = await AdminService.cancelAuction(auction.id);
                    _showSnack(err ?? 'تم إلغاء المزاد', isError: err != null);
                  }
                }),
              _adminTile(Icons.block, 'حظر صاحب المزاد', Colors.deepOrange, () {
                Navigator.pop(_);
                showModalBottomSheet(
                  context: ctx,
                  backgroundColor: Colors.transparent,
                  builder: (__) => BanDialog(
                    title: 'حظر صاحب المزاد',
                    onBan: (until) async =>
                        AdminService.banUser(auction.sellerId, until: until),
                  ),
                );
              }),
              _adminTile(Icons.delete_forever, 'حذف المزاد نهائياً', Colors.red,
                  () async {
                Navigator.pop(_);
                final ok = await showDialog<bool>(
                  context: ctx,
                  builder: (__) => AlertDialog(
                    title: const Text('حذف المزاد نهائياً',
                        textAlign: TextAlign.right),
                    content: const Text('سيُحذف المزاد وكل مزايداته.',
                        textAlign: TextAlign.right),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(__, false),
                          child: const Text('إلغاء')),
                      TextButton(
                        onPressed: () => Navigator.pop(__, true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('حذف نهائي'),
                      ),
                    ],
                  ),
                );
                if (ok == true && ctx.mounted) {
                  await AdminService.deleteAuctionPermanently(auction.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminTile(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14, color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    );
  }

  void _showWhatsappRequiredDialog() {
    final whatsappCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.chat, color: Color(0xFF25D366)),
                SizedBox(width: 8),
                Text('أضافة رقمك',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'يجب إضافة رقمك الحقيقي حتى يتمكن البائع من التواصل معك عند الفوز.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 14),
                // ─── عرض البلد (سوريا فقط) ──────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '🇸🇾  سوريا  (+963)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // ─── حقل رقم الهاتف ───────────────────────────────────────
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: whatsappCtrl,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.left,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      prefixText: '+964 ',
                      prefixStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      hintText: '7XXXXXXXXX',
                      suffixIcon:
                          const Icon(Icons.chat, color: Color(0xFF25D366)),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء',
                    style: TextStyle(color: Color(0xFF6B7280))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final num = whatsappCtrl.text.trim();
                  if (num.length != 10 || !num.startsWith('7')) {
                    _showSnack('يجب إدخال 10 أرقام تبدأ بالرقم 7',
                        isError: true);
                    return;
                  }
                  Navigator.pop(context);
                  final userData = await AuthService.getUserData();
                  final existing = Map<String, String>.from(
                    (userData?['socialLinks'] as Map?)?.map(
                            (k, v) => MapEntry(k.toString(), v.toString())) ??
                        {},
                  );
                  existing['whatsapp'] = '+964$num';
                  await AuthService.updateProfile(
                    name: AuthService.currentUser?.displayName ?? '',
                    socialLinks: existing,
                  );
                  if (mounted) {
                    _showSnack('تم حفظ الرقم. اضغط المزايدة مجدداً.');
                  }
                },
                child: const Text('حفظ وتابع'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.right),
      backgroundColor: isError ? Colors.red : const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
          const SizedBox(width: 4),
          Icon(icon, size: 13, color: const Color(0xFF6B7280)),
        ],
      ),
    );
  }
}
