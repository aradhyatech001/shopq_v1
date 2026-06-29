import 'dart:typed_data';
import 'package:shopq_admin/CustomWidgets/app_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:shimmer/shimmer.dart';

import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  // ── Form controllers ──────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedCatId;
  String? _selectedSubCatId;
  String? _selectedBrandId;
  List _subCats = [];
  List _mainCats = [];
  List _brands = [];
  List<String> _typeOptions = [];
  List<String> _selectedTypes = [];

  final List<TextEditingController> _vName = [];
  final List<TextEditingController> _vPrice = [];
  final List<TextEditingController> _vSell = [];
  final List<TextEditingController> _vWhole = [];
  final List<TextEditingController> _vStock = [];
  final List<String?> _vIds = [];

  final List<TextEditingController> _iAttr = [];
  final List<TextEditingController> _iVal = [];
  final List<String?> _iIds = [];

  final List<TextEditingController> _hAttr = [];
  final List<TextEditingController> _hVal = [];
  final List<String?> _hIds = [];

  final List<Uint8List> _newImageBytes = [];
  List<String> _uploadedUrls = [];

  // ── List state ────────────────────────────────────────────
  List<dynamic> _products = [];
  int _page = 1;
  int _perPage = 10;
  int _total = 0;
  bool _loading = false;
  bool _saving = false;
  Map<String, dynamic>? _editingProd;
  String _search = '';
  String? _filterCatId;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchMainCats();
    _fetchTypes();
    _fetchBrands();
    _addVariant();
    _addInfo();
    _addHighlight();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.dispose();
    for (final c in [
      ..._vName,
      ..._vPrice,
      ..._vSell,
      ..._vWhole,
      ..._vStock,
      ..._iAttr,
      ..._iVal,
      ..._hAttr,
      ..._hVal,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Field helpers ─────────────────────────────────────────
  void _addVariant() {
    _vName.add(TextEditingController());
    _vPrice.add(TextEditingController());
    _vSell.add(TextEditingController());
    _vWhole.add(TextEditingController());
    _vStock.add(TextEditingController());
    _vIds.add(null);
  }

  void _removeVariant(int i) {
    _vName[i].dispose();
    _vPrice[i].dispose();
    _vSell[i].dispose();
    _vWhole[i].dispose();
    _vStock[i].dispose();
    setState(() {
      _vName.removeAt(i);
      _vPrice.removeAt(i);
      _vSell.removeAt(i);
      _vWhole.removeAt(i);
      _vStock.removeAt(i);
      _vIds.removeAt(i);
    });
  }

  void _addInfo() {
    _iAttr.add(TextEditingController());
    _iVal.add(TextEditingController());
    _iIds.add(null);
  }

  void _removeInfo(int i) {
    _iAttr[i].dispose();
    _iVal[i].dispose();
    setState(() {
      _iAttr.removeAt(i);
      _iVal.removeAt(i);
      _iIds.removeAt(i);
    });
  }

  void _addHighlight() {
    _hAttr.add(TextEditingController());
    _hVal.add(TextEditingController());
    _hIds.add(null);
  }

  void _removeHighlight(int i) {
    _hAttr[i].dispose();
    _hVal[i].dispose();
    setState(() {
      _hAttr.removeAt(i);
      _hVal.removeAt(i);
      _hIds.removeAt(i);
    });
  }

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetchProducts() async {
    setState(() => _loading = true);
    try {
      var url = '${ApiConstants.VIEW_ALL_PRODUCTS}?page=$_page&limit=$_perPage';
      if (_search.isNotEmpty) url += '&search=$_search';
      if (_filterCatId != null && _filterCatId != 'all') {
        url += '&category_id=$_filterCatId';
      }
      final res = await AdminApi.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _products = data['products'];
          _total = int.tryParse(data['total'].toString()) ?? 0;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchMainCats() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.MAIN_VIEW_CATEGORY));
      if (res.statusCode == 200 && mounted) {
        setState(() => _mainCats = jsonDecode(res.body) as List);
      }
    } catch (_) {}
  }

  Future<void> _fetchSubCats(String parentId) async {
    try {
      final res = await AdminApi.get(
        Uri.parse('${ApiConstants.VIEW_SUBCATEGORIES}?parent_id=$parentId'),
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        setState(() {
          _subCats = data['data'] ?? [];
          if (!_subCats.any((s) => s['id'].toString() == _selectedSubCatId)) {
            _selectedSubCatId = null;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTypes() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.VIEW_PRODUCT_TYPES));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(
          () => _typeOptions = List<Map<String, dynamic>>.from(
            data['data'],
          ).map((t) => t['name'].toString()).toList(),
        );
      }
    } catch (_) {}
  }

  Future<void> _fetchBrands() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.BRANDS_ALL));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _brands = data['data'] ?? []);
      }
    } catch (_) {}
  }

  Future<void> _saveHandler() async {
    if (_nameCtrl.text.isEmpty || _selectedCatId == null) {
      _snack('Fill product name and category', AppColors.warningColor);
      return;
    }
    setState(() => _saving = true);
    try {
      if (_editingProd != null) {
        await _updateProduct();
      } else {
        await _createProduct();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _createProduct() async {
    final body = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'main_category_id': _selectedCatId,
      if (_selectedSubCatId != null) 'subcategory_id': _selectedSubCatId,
      if (_selectedBrandId != null) 'brand_id': _selectedBrandId,
      'types': _selectedTypes.join(','),
      'images': _uploadedUrls,
    };
    final res = await AdminApi.postJson(
      Uri.parse(ApiConstants.SAVE_PRODUCT),
      body: body,
    );
    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      final pid = data['id'].toString();
      await _uploadAllImages(pid);
      await _saveAllVariants(pid);
      await _saveAllDetails(pid);
      _snack('Product added!', AppColors.successColor);
      _clearForm();
      _fetchProducts();
    } else {
      _snack(data['message'] ?? 'Failed', AppColors.errorColor);
    }
  }

  Future<void> _updateProduct() async {
    final pid = _editingProd!['id'].toString();
    final variants = <Map<String, dynamic>>[];
    for (int i = 0; i < _vName.length; i++) {
      variants.add({
        'id': _vIds.length > i ? _vIds[i] : null,
        'name': _vName[i].text,
        'price': _vPrice[i].text,
        'selling_price': _vSell[i].text,
        'wholesale_price': _vWhole[i].text,
        'stock_quantity': _vStock[i].text,
      });
    }
    final info = <Map<String, dynamic>>[];
    for (int i = 0; i < _iAttr.length; i++) {
      info.add({
        'id': _iIds.length > i ? _iIds[i] : null,
        'attribute': _iAttr[i].text,
        'value': _iVal[i].text,
      });
    }
    final highlights = <Map<String, dynamic>>[];
    for (int i = 0; i < _hAttr.length; i++) {
      highlights.add({
        'id': _hIds.length > i ? _hIds[i] : null,
        'attribute': _hAttr[i].text,
        'value': _hVal[i].text,
      });
    }
    final body = {
      'id': pid,
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'main_category_id': _selectedCatId,
      if (_selectedSubCatId != null) 'subcategory_id': _selectedSubCatId,
      if (_selectedBrandId != null) 'brand_id': _selectedBrandId,
      'types': _selectedTypes.join(','),
      'images': _uploadedUrls,
      'variants': variants,
      'info': info,
      'highlights': highlights,
    };
    final res = await AdminApi.postJson(
      Uri.parse(ApiConstants.UPDATE_PRODUCT),
      body: body,
    );
    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      await _uploadAllImages(pid);
      _snack('Product updated!', AppColors.successColor);
      _clearForm();
      _fetchProducts();
    } else {
      _snack(data['message'] ?? 'Failed', AppColors.errorColor);
    }
  }

  Future<void> _uploadAllImages(String pid) async {
    for (final bytes in _newImageBytes) {
      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.SAVE_IMAGE));
      request.fields['product_id'] = pid;
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: 'img.png'));
      await AdminApi.multipart(Uri.parse(ApiConstants.SAVE_IMAGE), request);
    }
  }

  Future<void> _saveAllVariants(String pid) async {
    for (int i = 0; i < _vName.length; i++) {
      if (_vName[i].text.isEmpty) continue;
      await AdminApi.post(
        Uri.parse(ApiConstants.SAVE_VARIANT),
        body: {
          'product_id': pid,
          'name': _vName[i].text,
          'price': _vPrice[i].text,
          'selling_price': _vSell[i].text,
          'wholesale_price': _vWhole[i].text,
          'stock_quantity': _vStock[i].text,
        },
      );
    }
  }

  Future<void> _saveAllDetails(String pid) async {
    for (int i = 0; i < _iAttr.length; i++) {
      if (_iAttr[i].text.isEmpty || _iVal[i].text.isEmpty) continue;
      await AdminApi.post(
        Uri.parse(ApiConstants.SAVE_PRODUCT_INFO),
        body: {
          'product_id': pid,
          'attribute': _iAttr[i].text,
          'value': _iVal[i].text,
        },
      );
    }
    for (int i = 0; i < _hAttr.length; i++) {
      if (_hAttr[i].text.isEmpty || _hVal[i].text.isEmpty) continue;
      await AdminApi.post(
        Uri.parse(ApiConstants.SAVE_PRODUCT_HIGHLIGHT),
        body: {
          'product_id': pid,
          'attribute': _hAttr[i].text,
          'value': _hVal[i].text,
        },
      );
    }
  }

  Future<void> _deleteProduct(String pid) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete Product',
      message: 'This product and all its data will be removed.',
    );
    if (!ok) return;
    setState(() => _loading = true);
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.DELETE_PRODUCTS),
        body: {'id': pid},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Product deleted', AppColors.successColor);
        _fetchProducts();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _editProduct(Map<String, dynamic> p) {
    // Clear
    for (final c in [
      ..._vName,
      ..._vPrice,
      ..._vSell,
      ..._vWhole,
      ..._vStock,
      ..._iAttr,
      ..._iVal,
      ..._hAttr,
      ..._hVal,
    ]) {
      c.dispose();
    }
    _vName.clear();
    _vPrice.clear();
    _vSell.clear();
    _vWhole.clear();
    _vStock.clear();
    _vIds.clear();
    _iAttr.clear();
    _iVal.clear();
    _iIds.clear();
    _hAttr.clear();
    _hVal.clear();
    _hIds.clear();

    setState(() {
      _editingProd = p;
      _nameCtrl.text = p['name'] ?? '';
      _descCtrl.text = p['description'] ?? '';
      _selectedCatId = p['main_category_id']?.toString();
      _selectedSubCatId = p['subcategory_id']?.toString();
      _selectedBrandId = p['brand_id']?.toString();
      if (_selectedCatId != null) _fetchSubCats(_selectedCatId!);

      // Variants
      for (final v in (p['variants'] ?? [])) {
        _vName.add(TextEditingController(text: v['name'] ?? ''));
        _vPrice.add(TextEditingController(text: v['price']?.toString() ?? ''));
        _vSell.add(
          TextEditingController(text: v['selling_price']?.toString() ?? ''),
        );
        _vWhole.add(
          TextEditingController(text: v['wholesale_price']?.toString() ?? ''),
        );
        _vStock.add(
          TextEditingController(
            text:
                v['stock_quantity']?.toString() ?? v['stock']?.toString() ?? '',
          ),
        );
        _vIds.add(v['id']?.toString());
      }
      if (_vName.isEmpty) _addVariant();

      // Info
      for (final i in (p['info'] ?? [])) {
        _iAttr.add(TextEditingController(text: i['attribute'] ?? ''));
        _iVal.add(TextEditingController(text: i['value'] ?? ''));
        _iIds.add(i['id']?.toString());
      }
      if (_iAttr.isEmpty) _addInfo();

      // Highlights
      for (final h in (p['highlights'] ?? [])) {
        _hAttr.add(TextEditingController(text: h['attribute'] ?? ''));
        _hVal.add(TextEditingController(text: h['value'] ?? ''));
        _hIds.add(h['id']?.toString());
      }
      if (_hAttr.isEmpty) _addHighlight();

      // Images + types
      _uploadedUrls = List<String>.from((p['images'] ?? []));
      _newImageBytes.clear();
      _selectedTypes = (p['types'] ?? '')
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
          .cast<String>();
    });
  }

  void _clearForm() {
    for (final c in [
      ..._vName,
      ..._vPrice,
      ..._vSell,
      ..._vWhole,
      ..._vStock,
      ..._iAttr,
      ..._iVal,
      ..._hAttr,
      ..._hVal,
    ]) {
      c.dispose();
    }
    _vName.clear();
    _vPrice.clear();
    _vSell.clear();
    _vWhole.clear();
    _vStock.clear();
    _vIds.clear();
    _iAttr.clear();
    _iVal.clear();
    _iIds.clear();
    _hAttr.clear();
    _hVal.clear();
    _hIds.clear();
    _newImageBytes.clear();
    _uploadedUrls.clear();
    setState(() {
      _editingProd = null;
      _selectedCatId = null;
      _selectedSubCatId = null;
      _selectedBrandId = null;
      _subCats.clear();
      _selectedTypes.clear();
      _nameCtrl.clear();
      _descCtrl.clear();
    });
    _addVariant();
    _addInfo();
    _addHighlight();
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

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Products',
      subtitle: '$_total products',
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _search = '';
              _searchCtrl.clear();
              _page = 1;
            });
            _fetchProducts();
          },
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: product list ─────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Search + category filter
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
                        label: Text('Search', style: GoogleFonts.jost()),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _categoryFilter(),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total: $_total products',
                      style: GoogleFonts.jost(
                        fontSize: 12.sp,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(child: _buildList()),
                  if (_total > _perPage) ...[
                    SizedBox(height: 10.h),
                    _pagination(),
                  ],
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          // ── Right: form ────────────────────────────────
          SizedBox(
            width: 380.w,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category filter dropdown ──────────────────────────────
  Widget _categoryFilter() {
    final ids = ['all', ..._mainCats.map((c) => c['id'].toString())];
    final val = ids.contains(_filterCatId ?? 'all')
        ? (_filterCatId ?? 'all')
        : 'all';
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: GoogleFonts.jost(
          fontSize: 13.sp,
          color: AppColors.primaryTextColor,
        ),
        icon: Icon(
          Icons.expand_more_rounded,
          size: 18.sp,
          color: AppColors.hintTextColor,
        ),
        items: [
          DropdownMenuItem(
            value: 'all',
            child: Text(
              'All Categories',
              style: GoogleFonts.jost(fontSize: 13.sp),
            ),
          ),
          ..._mainCats.map(
            (c) => DropdownMenuItem<String>(
              value: c['id'].toString(),
              child: Text(c['name'], style: GoogleFonts.jost(fontSize: 13.sp)),
            ),
          ),
        ],
        onChanged: (v) {
          setState(() {
            _filterCatId = v;
            _page = 1;
          });
          _fetchProducts();
        },
      ),
    );
  }

  // ── Product list ──────────────────────────────────────────
  Widget _buildList() {
    if (_loading) return _shimmer();
    if (_products.isEmpty) {
      return const EmptyState(
        icon: Icons.shopping_bag_outlined,
        message: 'No products found',
      );
    }
    return ListView.separated(
      itemCount: _products.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, i) => _ProductTile(
        product: _products[i],
        onEdit: () => _editProduct(_products[i]),
        onDelete: () => _deleteProduct(_products[i]['id'].toString()),
      ),
    );
  }

  Widget _shimmer() => ListView.builder(
    itemCount: 6,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        height: 72.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    ),
  );

  Widget _pagination() {
    final total = (_total / _perPage).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: _page > 1 ? AppColors.primaryColor : AppColors.hintTextColor,
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
    );
  }

  // ── Product form ──────────────────────────────────────────
  Widget _buildForm() {
    final validCatId =
        _mainCats.any((c) => c['id'].toString() == _selectedCatId)
        ? _selectedCatId
        : null;
    final validSubId =
        _subCats.any((s) => s['id'].toString() == _selectedSubCatId)
        ? _selectedSubCatId
        : null;
    final validBrandId =
        _brands.any((b) => b['id'].toString() == _selectedBrandId)
        ? _selectedBrandId
        : null;

    return SectionCard(
      title: _editingProd == null ? 'Add Product' : 'Edit Product',
      trailing: _editingProd != null
          ? TextButton(
              onPressed: _clearForm,
              child: Text('Cancel', style: GoogleFonts.jost()),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          const FormLabel('Product Name', required: true),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.jost(fontSize: 13.sp),
            decoration: const InputDecoration(hintText: 'e.g. Fresh Milk'),
          ),
          SizedBox(height: 14.h),

          // Description
          const FormLabel('Description'),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            style: GoogleFonts.jost(fontSize: 13.sp),
            decoration: const InputDecoration(
              hintText: 'Product description...',
            ),
          ),
          SizedBox(height: 14.h),

          // Main category
          const FormLabel('Category', required: true),
          _dropdown(
            value: validCatId,
            hint: 'Select category',
            items: _mainCats
                .map(
                  (c) => DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child: Text(
                      c['name'],
                      style: GoogleFonts.jost(fontSize: 13.sp),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedCatId = v;
                _selectedSubCatId = null;
              });
              if (v != null) _fetchSubCats(v);
            },
          ),
          SizedBox(height: 12.h),

          // Sub category
          const FormLabel('Sub Category'),
          _dropdown(
            value: validSubId,
            hint: 'Select subcategory (optional)',
            items: _subCats
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s['id'].toString(),
                    child: Text(
                      s['name'],
                      style: GoogleFonts.jost(fontSize: 13.sp),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedSubCatId = v),
          ),
          SizedBox(height: 12.h),

          // Brand
          const FormLabel('Brand'),
          _dropdown(
            value: validBrandId,
            hint: 'Select brand (optional)',
            items: [
              const DropdownMenuItem<String>(
                  value: null, child: Text('No brand')),
              ..._brands.map(
                (b) => DropdownMenuItem<String>(
                  value: b['id'].toString(),
                  child: Text(
                    b['name'] ?? '',
                    style: GoogleFonts.jost(fontSize: 13.sp),
                  ),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _selectedBrandId = v),
          ),
          SizedBox(height: 14.h),

          // Product types
          const FormLabel('Product Types'),
          _typeOptions.isEmpty
              ? Text(
                  'Loading...',
                  style: GoogleFonts.jost(
                    fontSize: 12.sp,
                    color: AppColors.hintTextColor,
                  ),
                )
              : Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: _typeOptions.map((t) {
                    final sel = _selectedTypes.contains(t);
                    return FilterChip(
                      label: Text(t, style: GoogleFonts.jost(fontSize: 11.sp)),
                      selected: sel,
                      selectedColor: AppColors.primaryColor.withValues(
                        alpha: 0.15,
                      ),
                      checkmarkColor: AppColors.primaryColor,
                      onSelected: (v) => setState(() {
                        if (v)
                          _selectedTypes.add(t);
                        else
                          _selectedTypes.remove(t);
                      }),
                    );
                  }).toList(),
                ),
          SizedBox(height: 14.h),

          // Images
          const FormLabel('Images'),
          if (_uploadedUrls.isNotEmpty) ...[
            SizedBox(
              height: 70.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _uploadedUrls.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: AppNetworkImage(
                        _uploadedUrls[i],
                        width: 70.w,
                        height: 70.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70.w,
                          height: 70.h,
                          color: AppColors.backgroundColor,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 20.sp,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _uploadedUrls.removeAt(i)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
          if (_newImageBytes.isNotEmpty) ...[
            SizedBox(
              height: 70.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _newImageBytes.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.memory(
                        _newImageBytes[i],
                        width: 70.w,
                        height: 70.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _newImageBytes.removeAt(i)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
          OutlinedButton.icon(
            onPressed: () async {
              final bytes = await ImagePickerWeb.getImageAsBytes();
              if (bytes == null) return;
              if (bytes.lengthInBytes > 1024 * 1024) {
                _snack('Max 1 MB per image', AppColors.warningColor);
                return;
              }
              setState(() => _newImageBytes.add(bytes));
            },
            icon: Icon(Icons.add_photo_alternate_outlined, size: 16.sp),
            label: Text('Add Image', style: GoogleFonts.jost()),
          ),
          SizedBox(height: 16.h),

          // Variants
          _sectionHeader('Variants', () {
            setState(() => _addVariant());
          }),
          ...List.generate(_vName.length, (i) => _variantRow(i)),
          SizedBox(height: 14.h),

          // Info
          _sectionHeader('Product Info', () {
            setState(() => _addInfo());
          }),
          ...List.generate(
            _iAttr.length,
            (i) => _kvRow(_iAttr[i], _iVal[i], () => _removeInfo(i)),
          ),
          SizedBox(height: 14.h),

          // Highlights
          _sectionHeader('Highlights', () {
            setState(() => _addHighlight());
          }),
          ...List.generate(
            _hAttr.length,
            (i) => _kvRow(_hAttr[i], _hVal[i], () => _removeHighlight(i)),
          ),
          SizedBox(height: 20.h),

          // Save button
          SizedBox(
            width: double.infinity,
            child: _saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveHandler,
                    child: Text(
                      _editingProd == null ? 'Add Product' : 'Update Product',
                      style: GoogleFonts.jost(fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onAdd) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.jost(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 16.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 4.w),
              Text(
                'Add',
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _variantRow(int i) => Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: AppColors.borderColor),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _miniField(_vName[i], 'Name')),
            SizedBox(width: 8.w),
            if (_vName.length > 1)
              GestureDetector(
                onTap: () => _removeVariant(i),
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 18.sp,
                  color: AppColors.errorColor,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: _miniField(_vPrice[i], 'MRP ₹')),
            SizedBox(width: 8.w),
            Expanded(child: _miniField(_vSell[i], 'Selling ₹')),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: _miniField(_vWhole[i], 'Wholesale ₹')),
            SizedBox(width: 8.w),
            Expanded(child: _miniField(_vStock[i], 'Stock')),
          ],
        ),
      ],
    ),
  );

  Widget _kvRow(
    TextEditingController attr,
    TextEditingController val,
    VoidCallback onRemove,
  ) => Row(
    children: [
      Expanded(child: _miniField(attr, 'Attribute')),
      SizedBox(width: 8.w),
      Expanded(child: _miniField(val, 'Value')),
      SizedBox(width: 4.w),
      GestureDetector(
        onTap: onRemove,
        child: Icon(
          Icons.remove_circle_outline_rounded,
          size: 18.sp,
          color: AppColors.errorColor,
        ),
      ),
      SizedBox(height: 8.h),
    ],
  );

  Widget _miniField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    style: GoogleFonts.jost(fontSize: 12.sp),
    decoration: InputDecoration(
      hintText: hint,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      isDense: true,
    ),
  );

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) => Container(
    height: 44.h,
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: AppColors.borderColor),
    ),
    child: DropdownButton<String>(
      value: value,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      hint: Text(
        hint,
        style: GoogleFonts.jost(
          fontSize: 13.sp,
          color: AppColors.hintTextColor,
        ),
      ),
      style: GoogleFonts.jost(
        fontSize: 13.sp,
        color: AppColors.primaryTextColor,
      ),
      icon: Icon(
        Icons.expand_more_rounded,
        size: 18.sp,
        color: AppColors.hintTextColor,
      ),
      items: items,
      onChanged: onChanged,
    ),
  );
}

// ── Product list tile ─────────────────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final images = (product['images'] as List?)?.cast<String>() ?? [];
    final variants = (product['variants'] as List?) ?? [];
    final catName = product['main_category_name'] ?? product['category'] ?? '—';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: images.isNotEmpty
                ? AppNetworkImage(
                    images.first,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '—',
                  style: GoogleFonts.jost(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  catName,
                  style: GoogleFonts.jost(
                    fontSize: 11.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 11.sp,
                      color: AppColors.hintTextColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${variants.length} variant${variants.length == 1 ? '' : 's'}',
                      style: GoogleFonts.jost(
                        fontSize: 11.sp,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                    if ((product['types'] ?? '').toString().isNotEmpty) ...[
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.label_rounded,
                        size: 11.sp,
                        color: AppColors.hintTextColor,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          product['types'] ?? '',
                          style: GoogleFonts.jost(
                            fontSize: 11.sp,
                            color: AppColors.hintTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Edit
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primaryColor,
              size: 18.sp,
            ),
            tooltip: 'Edit',
            onPressed: onEdit,
          ),
          // Delete
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.errorColor,
              size: 18.sp,
            ),
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.shopping_bag_rounded,
      color: AppColors.primaryColor,
      size: 22,
    ),
  );
}
