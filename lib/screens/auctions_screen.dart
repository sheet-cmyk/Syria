import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_model.dart';
import '../services/auth_service.dart';
import '../gen_l10n/app_localizations.dart';
import 'auction_detail_screen.dart';
import 'add_auction_screen.dart';

class AuctionsScreen extends StatefulWidget {
  const AuctionsScreen({super.key});

  @override
  State<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends State<AuctionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _catKeys = [
    'الكل',
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
  String _selectedCategoryKey = 'الكل';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // الـ Cloud Function تتولى تحديث الحالات وإرسال الإشعارات كل دقيقة
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _catLabels(AppLocalizations l10n) => [
        l10n.auctionCatAll,
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
        title: Text(
          l10n.auctionScreenTitle,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: Color(0xFF3B5BDB)),
            onPressed: () => _openAddAuction(l10n),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B5BDB),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF3B5BDB),
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: l10n.auctionTabActive),
            Tab(text: l10n.auctionTabEndingSoon),
            Tab(text: l10n.auctionTabEnded),
          ],
        ),
      ),
      body: LayoutBuilder(builder: (_, c) {
        final hPad = c.maxWidth > 1100 ? (c.maxWidth - 1100) / 2 : 0.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: [
              _buildCategoryFilter(l10n),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAuctionList(['active'], l10n),
                    _buildAuctionList(['endingSoon'], l10n),
                    _buildAuctionList(['sold', 'expired'], l10n),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategoryFilter(AppLocalizations l10n) {
    final labels = _catLabels(l10n);
    return Container(
      height: 40,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        itemCount: _catKeys.length,
        itemBuilder: (_, i) {
          final key = _catKeys[i];
          final isSelected = key == _selectedCategoryKey;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryKey = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 7),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B5BDB)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuctionList(List<String> statuses, AppLocalizations l10n) {
    final query = FirebaseFirestore.instance
        .collection('auctions')
        .where('status', whereIn: statuses)
        .orderBy('endTime');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B5BDB)));
        }
        if (snap.hasError) {
          return Center(
              child: Text('${snap.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        var docs = snap.data?.docs ?? [];

        if (_selectedCategoryKey != 'الكل') {
          docs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['category'] == _selectedCategoryKey;
          }).toList();
        }

        if (docs.isEmpty) return _buildEmpty(l10n);

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            // شبكة للويب والشاشات العريضة، قائمة للموبايل
            if (w >= 700) {
              final cols = w >= 1100 ? 3 : 2;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final auction = AuctionModel.fromFirestore(docs[i]);
                  return _AuctionGridCard(
                    key: ValueKey(auction.id),
                    auction: auction,
                    onTap: () => _openDetail(auction),
                  );
                },
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(11),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final auction = AuctionModel.fromFirestore(docs[i]);
                return _AuctionListTile(
                  key: ValueKey(auction.id),
                  auction: auction,
                  onTap: () => _openDetail(auction),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gavel, color: Colors.grey, size: 50),
          const SizedBox(height: 11),
          Text(l10n.auctionNoAuctions,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _openAddAuction(l10n),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.auctionAddBtn),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BDB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(AuctionModel auction) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AuctionDetailScreen(auction: auction)));
  }

  void _openAddAuction(AppLocalizations l10n) async {
    if (!AuthService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.auctionLoginFirst)),
      );
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddAuctionScreen()));
  }
}

// ── كارد شبكة للويب ──
class _AuctionGridCard extends StatelessWidget {
  final AuctionModel auction;
  final VoidCallback onTap;
  const _AuctionGridCard(
      {super.key, required this.auction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = auction.computedStatus;
    final isEndingSoon = status == AuctionStatus.endingSoon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isEndingSoon
              ? Border.all(color: Colors.orange, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة المزاد
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: auction.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: auction.images.first,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        placeholder: (_, __) => _gridPlaceholder(),
                        errorWidget: (_, __, ___) => _gridPlaceholder(),
                      )
                    : _gridPlaceholder(),
              ),
            ),
            // المعلومات
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusChip(status: status),
                        Flexible(
                          child: Text(
                            auction.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      auction.currency == 'USD'
                          ? '\$${auction.currentPrice.toInt()}'
                          : '${auction.currentPrice.toInt()} ل.س',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669)),
                      textAlign: TextAlign.right,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${auction.totalBids} ${l10n.auctionBid}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF9CA3AF)),
                        ),
                        Text(
                          '📍 ${auction.city}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridPlaceholder() => Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(
            child: Icon(Icons.gavel, color: Color(0xFF9CA3AF), size: 36)),
      );
}

// ── كارد القائمة للموبايل (مصغّر 10%) ──
class _AuctionListTile extends StatelessWidget {
  final AuctionModel auction;
  final VoidCallback onTap;
  const _AuctionListTile(
      {super.key, required this.auction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = auction.computedStatus;
    final isEndingSoon = status == AuctionStatus.endingSoon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isEndingSoon
              ? Border.all(color: Colors.orange, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 7)
          ],
        ),
        child: Row(
          children: [
            // الصورة
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(12)),
              child: auction.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: auction.images.first,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            // المعلومات
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusChip(status: status),
                        Flexible(
                          child: Text(
                            auction.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      auction.currency == 'USD'
                          ? '\$${auction.currentPrice.toInt()}'
                          : '${auction.currentPrice.toInt()} ل.س',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669)),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${auction.totalBids} ${l10n.auctionBid}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF9CA3AF)),
                        ),
                        Text(
                          '📍 ${auction.city}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 90,
        height: 90,
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.gavel, color: Color(0xFF9CA3AF), size: 29),
      );
}

class _StatusChip extends StatelessWidget {
  final AuctionStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    late Color color;
    late String text;
    switch (status) {
      case AuctionStatus.active:
        color = const Color(0xFF059669);
        text = l10n.auctionStatusActive;
        break;
      case AuctionStatus.endingSoon:
        color = Colors.orange;
        text = l10n.auctionStatusEndingSoon;
        break;
      case AuctionStatus.sold:
        color = const Color(0xFF3B5BDB);
        text = l10n.auctionStatusSold;
        break;
      case AuctionStatus.expired:
        color = Colors.grey;
        text = l10n.auctionStatusExpired;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(7)),
      child: Text(text,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
