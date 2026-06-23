import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopq/core/widgets/app_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'package:shopq/core/widgets/product_card.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/app/theme/app_colors.dart';

/// Public shop (vendor) page — animated collapsing header + staggered product grid.
class ShopDetailScreen extends StatefulWidget {
  final int shopId;
  final String? shopName;
  final String? logo;

  const ShopDetailScreen({
    super.key,
    required this.shopId,
    this.shopName,
    this.logo,
  });

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic> _shop = {};
  List _products = [];
  bool _loading = true;
  String _userId = '';

  final ScrollController _sc = ScrollController();
  bool _collapsed = false;
  final Set<int> _animated = {};
  int? _selectedCat; // null = All

  /// Distinct categories present in this shop's products (for the filter bar).
  List<Map<String, dynamic>> get _categories {
    final map = <int, String>{};
    for (final p in _products) {
      final id = int.tryParse('${p['main_category_id'] ?? ''}');
      if (id != null) {
        map[id] = (p['main_category_name'] ?? p['category'] ?? 'Other').toString();
      }
    }
    return map.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
  }

  List get _filtered => _selectedCat == null
      ? _products
      : _products
          .where((p) => int.tryParse('${p['main_category_id'] ?? ''}') == _selectedCat)
          .toList();

  late final AnimationController _introCtrl;

  double _expandedH = 220; // recomputed per build from the actual content

  /// Header height adapts to content: toolbar + logo/name/chips block + the
  /// measured description height (no clipping, no wasted space).
  double _computeHeaderHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    final desc = (_shop['shop_description'] ?? '').toString().trim();
    double h = mq.padding.top + 56.h + 110.h + 18.h; // status bar + paddings + logo/name/chips row
    if (desc.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: desc,
          style: GoogleFonts.jost(fontSize: 12.5.sp, height: 1.35),
        ),
        maxLines: 2,
        ellipsis: '…',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: mq.size.width - 40.w);
      h += tp.height + 12.h;
    }
    return h;
  }

  @override
  void initState() {
    super.initState();
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _sc.addListener(() {
      final c = _sc.hasClients && _sc.offset > (_expandedH - kToolbarHeight - 60);
      if (c != _collapsed) setState(() => _collapsed = c);
    });
    _init();
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _sc.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final info = await ApiHelper.getUserInfo();
    if (mounted) _userId = info['id'] ?? '';
    await _fetchShop();
  }

  Future<void> _fetchShop() async {
    if (mounted) setState(() => _loading = true);
    try {
      final res = await ApiHelper.get(
        '${ApiConstants.SHOP_DETAIL}?vendor_id=${widget.shopId}',
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _shop = Map<String, dynamic>.from(data['shop'] ?? {});
            _products = data['products'] ?? [];
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _introCtrl.forward(from: 0);
      }
    }
  }

  void selectCategory(int? id) {
    if (_selectedCat == id) return;
    setState(() {
      _selectedCat = id;
      _animated.clear(); // re-run the entrance animation for the new set
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = (_shop['shop_name'] ?? widget.shopName ?? 'Shop').toString();
    _expandedH = _computeHeaderHeight(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _fetchShop,
        child: CustomScrollView(
          controller: _sc,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildHeader(name),
            if (!_loading && _categories.length > 1)
              SliverPersistentHeader(pinned: true, delegate: _FilterBarDelegate(this)),
            if (_loading)
              _buildSkeleton()
            else if (_filtered.isEmpty)
              _buildEmpty()
            else
              _buildGrid(),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }

  // ── Collapsing animated header ──────────────────────────────
  Widget _buildHeader(String name) {
    final logo = (_shop['logo'] ?? widget.logo ?? '').toString();
    final desc = (_shop['shop_description'] ?? '').toString();
    final count = _shop['product_count'] ?? _products.length;

    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedH,
      backgroundColor: AppColors.primaryColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      leadingWidth: 56.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.w),
        child: _circleBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
      ),
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _collapsed ? 1 : 0,
        child: Text(
          name,
          style: GoogleFonts.jost(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _headerBackground(name, logo, desc, count),
      ),
    );
  }

  Widget _headerBackground(String name, String logo, String desc, dynamic count) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.secondaryColor,
              ],
            ),
          ),
        ),
        // Decorative circles
        Positioned(top: -40.h, right: -30.w, child: _bubble(150.w, 0.12)),
        Positioned(bottom: -50.h, left: -20.w, child: _bubble(130.w, 0.10)),
        // Content (fades/slides in)
        SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: _introCtrl,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(_introCtrl.value);
              return Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
              );
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 18.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _logoBadge(logo),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.jost(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: [
                                _chip(Icons.shopping_bag_rounded, '$count products'),
                                _chip(Icons.flash_on_rounded, '24 Min'),
                                _chip(Icons.verified_rounded, 'Assured'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jost(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12.5.sp,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _logoBadge(String logo) {
    return Hero(
      tag: 'shop-logo-${widget.shopId}',
      child: Container(
        width: 76.w,
        height: 76.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: logo.isEmpty
            ? Icon(Icons.storefront_rounded, color: AppColors.primaryColor, size: 34.sp)
            : SizedBox.expand(
                child: AppNetworkImage(ApiConstants.imageUrl(logo), fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _bubble(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );

  Widget _chip(IconData icon, String label) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 12.sp),
            SizedBox(width: 4.w),
            Text(label,
                style: GoogleFonts.jost(
                    color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Material(
        color: Colors.white.withValues(alpha: 0.22),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(icon, color: Colors.white, size: 16.sp),
          ),
        ),
      );

  // ── Product grid with staggered entrance ────────────────────
  Widget _buildGrid() {
    final list = _filtered;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(8.w, 0.h, 8.w, 0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          // Card is a fixed-height widget; size cells to it so there are no gaps.
          mainAxisExtent: 235.h,
          crossAxisSpacing: 6.w,
          mainAxisSpacing: 8.h,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _staggered(
            index,
            ProductCard(
              product: list[index],
              userId: _userId,
              onCartUpdated: () {},
            ),
          ),
          childCount: list.length,
        ),
      ),
    );
  }

  /// Fades + slides each card up once, with a small per-index delay.
  Widget _staggered(int index, Widget child) {
    if (_animated.contains(index)) return child;
    _animated.add(index);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index % 6) * 70),
      curve: Curves.easeOutCubic,
      builder: (_, t, ch) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - t)),
          child: Transform.scale(scale: 0.96 + 0.04 * t, child: ch),
        ),
      ),
      child: child,
    );
  }

  // ── Shimmer loading skeleton ────────────────────────────────
  Widget _buildSkeleton() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 180.h,
          crossAxisSpacing: 6.w,
          mainAxisSpacing: 8.h,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 60.sp, color: AppColors.hintTextColor),
            SizedBox(height: 14.h),
            Text('No products in this category',
                style: GoogleFonts.jost(color: AppColors.hintTextColor, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}

/// Pinned, horizontally-scrollable category filter bar for the shop page.
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final _ShopDetailScreenState state;
  _FilterBarDelegate(this.state);

  @override
  double get minExtent => 55;
  @override
  double get maxExtent => 55;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cats = state._categories;
    return Container(
      color: AppColors.backgroundColor,
      alignment: Alignment.centerLeft,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        children: [
          _chip(context, 'All', state._selectedCat == null, () => state.selectCategory(null)),
          ...cats.map((c) => _chip(
                context,
                c['name'].toString(),
                state._selectedCat == c['id'],
                () => state.selectCategory(c['id'] as int),
              )),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? AppColors.primaryColor : AppColors.borderColor,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.jost(
                fontSize: 12.5.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.primaryTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterBarDelegate oldDelegate) => true;
}
