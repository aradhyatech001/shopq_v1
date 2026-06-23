import 'package:flutter/material.dart';
import 'package:shopq_admin/CustomWidgets/app_network_image.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  // ── List state ─────────────────────────────────────────────
  List<dynamic> _products = [];
  List<dynamic> _filtered = [];
  int _page = 1;
  int _total = 0;
  bool _loading = false;
  bool _initialLoad = true;
  bool _lowOnly = false;
  int _lowThresh = 10;
  String _search = '';
  final _searchCtrl = TextEditingController();

  // ── Selected product (right panel) ────────────────────────
  Map<String, dynamic>? _selected;

  // ── Per-variant stock input controllers ───────────────────
  final Map<int, TextEditingController> _stockCtrls = {};
  final Map<int, bool> _isUpdating = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProducts());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    for (final c in _stockCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── API ────────────────────────────────────────────────────
  Future<void> _fetchProducts() async {
    if (_initialLoad && mounted) setState(() => _loading = true);
    try {
      var url = '${ApiConstants.VIEW_ALL_PRODUCTS}?page=$_page&limit=20';
      if (_search.isNotEmpty) url += '&search=${Uri.encodeComponent(_search)}';
      final res = await AdminApi.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(data['products']);
          _total = data['total'];
          _initialLoad = false;
        });
        _applyFilter();
        _initCtrls();

        // Keep selected product fresh
        if (_selected != null) {
          final id = _selected!['id'].toString();
          final fresh = _products.firstWhere(
            (p) => p['id'].toString() == id,
            orElse: () => <String, dynamic>{},
          );
          if (fresh.isNotEmpty) setState(() => _selected = fresh);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _initCtrls() {
    for (final p in _products) {
      for (final v in (p['variants'] as List? ?? [])) {
        final id = int.tryParse(v['id'].toString()) ?? 0;
        _stockCtrls.putIfAbsent(id, () => TextEditingController(text: '0'));
      }
    }
  }

  void _applyFilter() {
    if (!mounted) return;
    setState(() {
      _filtered = _lowOnly
          ? _products.where((p) {
              return (p['variants'] as List? ?? []).any((v) {
                final s = int.tryParse(v['stock']?.toString() ?? '0') ?? 0;
                return s <= _lowThresh;
              });
            }).toList()
          : List.from(_products);
    });
  }

  Future<void> _updateStock(int variantId, int change, int current) async {
    final newStock = current + change;
    if (newStock < 0) {
      _snack('Stock cannot be negative', AppColors.errorColor);
      return;
    }
    setState(() => _isUpdating[variantId] = true);
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.UPDATE_STOCK),
        body: {
          'variant_id': variantId.toString(),
          'stock': newStock.toString(),
        },
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Stock updated → $newStock', AppColors.successColor);
        // Update local state immediately
        setState(() {
          for (final p in _products) {
            for (final v in (p['variants'] as List? ?? [])) {
              if (int.tryParse(v['id'].toString()) == variantId) {
                v['stock'] = newStock.toString();
              }
            }
          }
          // Refresh selected product too
          if (_selected != null) {
            final id = _selected!['id'].toString();
            final fresh = _products.firstWhere(
              (p) => p['id'].toString() == id,
              orElse: () => <String, dynamic>{},
            );
            if (fresh.isNotEmpty) _selected = fresh;
          }
          _stockCtrls[variantId]?.text = '0';
          _applyFilter();
        });
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _isUpdating[variantId] = false);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.jost(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Stock Management',
      subtitle: '$_total products',
      actions: [
        // Low stock toggle
        Row(
          children: [
            Text(
              'Low stock only',
              style: GoogleFonts.jost(
                fontSize: 12.sp,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(width: 6.w),
            Switch(
              value: _lowOnly,
              activeThumbColor: AppColors.primaryColor,
              onChanged: (v) {
                setState(() => _lowOnly = v);
                _applyFilter();
              },
            ),
          ],
        ),
        IconButton(
          onPressed: _fetchProducts,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ],
      child: Row(
        children: [
          // ════════════════════════════════════════════════
          // LEFT — product list
          // ════════════════════════════════════════════════
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Search + threshold bar
                _buildFilterBar(),

                // Count
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Showing ${_filtered.length} of $_total',
                      style: GoogleFonts.jost(
                        fontSize: 12.sp,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ),

                // Product list
                Expanded(child: _buildProductList()),

                // Pagination
                if (_total > 20) _buildPagination(),
              ],
            ),
          ),

          // Divider
          const VerticalDivider(width: 1),

          // ════════════════════════════════════════════════
          // RIGHT — variant detail panel
          // ════════════════════════════════════════════════
          Expanded(
            flex: 4,
            child: _selected == null
                ? _emptyDetail()
                : _buildVariantPanel(_selected!),
          ),
        ],
      ),
    );
  }

  // ── Filter bar ─────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surfaceColor,
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AdminSearchBar(
                  controller: _searchCtrl,
                  hint: 'Search products...',
                  onClear: () {
                    setState(() {
                      _search = '';
                      _page = 1;
                    });
                    _fetchProducts();
                  },
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _search = _searchCtrl.text;
                    _page = 1;
                  });
                  _fetchProducts();
                },
                icon: Icon(Icons.search_rounded, size: 15.sp),
                label: Text('Search', style: GoogleFonts.jost(fontSize: 13.sp)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                'Low stock threshold: ',
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              Text(
                '$_lowThresh',
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warningColor,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _lowThresh.toDouble(),
                  min: 1,
                  max: 50,
                  divisions: 49,
                  activeColor: AppColors.warningColor,
                  inactiveColor: AppColors.borderColor,
                  onChanged: (v) {
                    setState(() => _lowThresh = v.toInt());
                    _applyFilter();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Product list ───────────────────────────────────────────
  Widget _buildProductList() {
    if (_loading && _initialLoad) return _shimmer();
    if (_filtered.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        message: _lowOnly ? 'No low-stock products' : 'No products found',
      );
    }
    return Stack(
      children: [
        ListView.separated(
          padding: EdgeInsets.all(12.w),
          itemCount: _filtered.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (_, i) => _buildProductTile(_filtered[i]),
        ),
        if (_loading && !_initialLoad)
          Container(
            color: Colors.black.withValues(alpha: 0.05),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildProductTile(Map<String, dynamic> product) {
    final variants = (product['variants'] as List? ?? []);
    final images = (product['images'] as List?)?.cast<String>() ?? [];
    final hasLow = variants.any((v) {
      final s = int.tryParse(v['stock']?.toString() ?? '0') ?? 0;
      return s <= _lowThresh;
    });
    final isSelected =
        _selected != null &&
        _selected!['id'].toString() == product['id'].toString();

    return GestureDetector(
      onTap: () => setState(() => _selected = product),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.06)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : hasLow
                ? AppColors.errorColor.withValues(alpha: 0.4)
                : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? null : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: images.isNotEmpty
                  ? AppNetworkImage(
                      images.first,
                      width: 44.w,
                      height: 44.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
            SizedBox(width: 12.w),

            // Name + variant count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '—',
                    style: GoogleFonts.jost(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.layers_rounded,
                        size: 12.sp,
                        color: AppColors.hintTextColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${variants.length} variants',
                        style: GoogleFonts.jost(
                          fontSize: 11.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Low stock badge
            if (hasLow)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.errorColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Low',
                  style: GoogleFonts.jost(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.shopping_bag_rounded,
      color: AppColors.primaryColor,
      size: 20,
    ),
  );

  // ── Empty detail ───────────────────────────────────────────
  Widget _emptyDetail() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app_rounded,
          size: 52.sp,
          color: AppColors.hintTextColor,
        ),
        SizedBox(height: 12.h),
        Text(
          'Select a product',
          style: GoogleFonts.jost(
            fontSize: 16.sp,
            color: AppColors.secondaryTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Click any product to manage its stock',
          style: GoogleFonts.jost(
            fontSize: 12.sp,
            color: AppColors.hintTextColor,
          ),
        ),
      ],
    ),
  );

  // ── Variant detail panel ───────────────────────────────────
  Widget _buildVariantPanel(Map<String, dynamic> product) {
    final variants = (product['variants'] as List? ?? []);
    final images = (product['images'] as List?)?.cast<String>() ?? [];

    return Container(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          // Panel header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: const BoxDecoration(
              color: AppColors.surfaceColor,
              border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                // Thumbnail
                if (images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: AppNetworkImage(
                      images.first,
                      width: 38.w,
                      height: 38.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? '—',
                        style: GoogleFonts.jost(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${variants.length} variants',
                        style: GoogleFonts.jost(
                          fontSize: 12.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Variant list
          Expanded(
            child: variants.isEmpty
                ? const EmptyState(
                    icon: Icons.layers_outlined,
                    message: 'No variants for this product',
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: variants.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) =>
                        _buildVariantCard(variants[i], product['name'] ?? ''),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCard(dynamic variant, String productName) {
    final id = int.tryParse(variant['id']?.toString() ?? '0') ?? 0;
    final vName = variant['name']?.toString() ?? 'Unnamed';
    final stock = int.tryParse(variant['stock']?.toString() ?? '0') ?? 0;
    final price =
        variant['selling_price']?.toString() ??
        variant['price']?.toString() ??
        '—';
    final isLow = stock <= _lowThresh;

    _stockCtrls.putIfAbsent(id, () => TextEditingController(text: '0'));

    // Progress bar color
    final maxStock = (stock * 2).clamp(50, 10000);
    final progress = (stock / maxStock).clamp(0.0, 1.0);
    final barColor = progress < 0.2
        ? AppColors.errorColor
        : progress < 0.5
        ? AppColors.warningColor
        : AppColors.successColor;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isLow
              ? AppColors.errorColor.withValues(alpha: 0.35)
              : AppColors.borderColor,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variant name + price row
          Row(
            children: [
              Expanded(
                child: Text(
                  '$productName — $vName',
                  style: GoogleFonts.jost(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '₹$price',
                style: GoogleFonts.jost(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Stock + progress
          Row(
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 14.sp,
                color: isLow ? AppColors.errorColor : AppColors.successColor,
              ),
              SizedBox(width: 6.w),
              Text(
                'Current Stock: $stock',
                style: GoogleFonts.jost(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isLow
                      ? AppColors.errorColor
                      : AppColors.primaryTextColor,
                ),
              ),
              SizedBox(width: 10.w),
              if (isLow)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'LOW',
                    style: GoogleFonts.jost(
                      fontSize: 9.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7.h,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          SizedBox(height: 14.h),

          // Update input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockCtrls[id],
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  style: GoogleFonts.jost(fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'e.g. +10 or -5',
                    hintStyle: GoogleFonts.jost(
                      fontSize: 12.sp,
                      color: AppColors.hintTextColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    isDense: true,
                    suffix: Text(
                      '→ ${stock + (int.tryParse(_stockCtrls[id]?.text ?? '0') ?? 0)}',
                      style: GoogleFonts.jost(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}), // refresh suffix
                ),
              ),
              SizedBox(width: 10.w),
              _isUpdating[id] == true
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        final change =
                            int.tryParse(_stockCtrls[id]?.text ?? '') ?? 0;
                        if (change == 0) {
                          _snack(
                            'Enter a non-zero value',
                            AppColors.warningColor,
                          );
                          return;
                        }
                        _updateStock(id, change, stock);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: GoogleFonts.jost(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              SizedBox(width: 6.w),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18.sp,
                  color: AppColors.secondaryTextColor,
                ),
                onPressed: () => setState(() => _stockCtrls[id]?.text = '0'),
                tooltip: 'Reset',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Pagination ─────────────────────────────────────────────
  Widget _buildPagination() {
    final total = (_total / 20).ceil();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _page > 1
                  ? AppColors.primaryColor
                  : AppColors.hintTextColor,
            ),
            onPressed: _page > 1
                ? () {
                    setState(() => _page--);
                    _fetchProducts();
                  }
                : null,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Text(
              '$_page / $total',
              style: GoogleFonts.jost(fontSize: 12.sp),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _page < total
                  ? AppColors.primaryColor
                  : AppColors.hintTextColor,
            ),
            onPressed: _page < total
                ? () {
                    setState(() => _page++);
                    _fetchProducts();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────
  Widget _shimmer() => ListView.builder(
    padding: EdgeInsets.all(12.w),
    itemCount: 8,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        height: 68.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    ),
  );
}
