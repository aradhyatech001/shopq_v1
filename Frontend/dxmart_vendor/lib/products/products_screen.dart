import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/vendor_api_helper.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List _products   = [];
  List _categories = [];
  List _types      = [];
  bool _loading    = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        VendorApiHelper.get(ApiConstants.VENDOR_PRODUCTS),
        VendorApiHelper.get(ApiConstants.CATEGORIES),
        VendorApiHelper.get(ApiConstants.PRODUCT_TYPES),
      ]);
      if (!mounted) return;
      final pData = jsonDecode(results[0].body);
      final cData = jsonDecode(results[1].body);
      final tData = jsonDecode(results[2].body);
      setState(() {
        _products   = pData['success'] == true ? pData['products'] ?? [] : [];
        _categories = cData is List ? List.from(cData) : [];  // GET /categories returns plain array
        _types      = tData['success'] == true ? tData['data']     ?? [] : [];  // key is 'data'
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    try {
      final res  = await VendorApiHelper.postJson(ApiConstants.VENDOR_PRODUCT_DELETE, body: {'id': id});
      final data = jsonDecode(res.body);
      if (mounted) { _snack(data['message'] ?? 'Deleted'); _load(); }
    } catch (e) {
      if (mounted) _snack('Error: $e');
    }
  }

  Future<void> _toggleStock(int id, bool currentlyActive) async {
    try {
      await VendorApiHelper.postJson(ApiConstants.VENDOR_PRODUCT_STOCK, body: {'product_id': id, 'is_active': currentlyActive ? 0 : 1});
      _load();
    } catch (_) {}
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.jost())));

  void _openForm({Map? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductForm(
        categories: _categories,
        types: _types,
        existing: existing,
        onSaved: _load,
      ),
    );
  }

  /// Lowest selling price across a product's variants, formatted for display.
  String? _priceLabel(Map p) {
    final variants = (p['variants'] as List?) ?? [];
    if (variants.isEmpty) return null;
    double? min;
    for (final v in variants) {
      final sp = double.tryParse('${v['selling_price']}');
      if (sp != null && (min == null || sp < min)) min = sp;
    }
    if (min == null) return null;
    return '₹${min.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  // ── Page header ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Products',
                                  style: GoogleFonts.jost(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${_products.length} product${_products.length == 1 ? '' : 's'}',
                                  style: GoogleFonts.jost(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh_rounded,
                                color: AppColors.textSecondary),
                          ),
                          FilledButton.icon(
                            onPressed: () => _openForm(),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              'Add',
                              style: GoogleFonts.jost(fontWeight: FontWeight.w600),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Content ───────────────────────────────────
                  if (_products.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 56.sp, color: AppColors.hint),
                            SizedBox(height: 12.h),
                            Text('No products yet',
                                style: GoogleFonts.jost(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp)),
                            SizedBox(height: 16.h),
                            OutlinedButton.icon(
                              onPressed: () => _openForm(),
                              icon: const Icon(Icons.add),
                              label: Text('Add first product',
                                  style: GoogleFonts.jost()),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                      sliver: SliverList.separated(
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) => _productCard(_products[i]),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _productCard(Map p) {
    final isActive = p['is_active'] == 1 || p['is_active'] == true;
    final images   = (p['images'] as List?) ?? [];
    final price    = _priceLabel(p);
    final variantCount = ((p['variants'] as List?) ?? []).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.borderColor),
                image: images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                            ApiConstants.imageUrl(images[0])),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: images.isEmpty
                  ? Icon(Icons.image_not_supported_outlined,
                      color: AppColors.hint, size: 22.sp)
                  : null,
            ),
            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['name'] ?? '',
                    style: GoogleFonts.jost(
                        fontWeight: FontWeight.w600, fontSize: 14.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((p['category_name'] ?? '').toString().isNotEmpty)
                    Text(
                      p['category_name'],
                      style: GoogleFonts.jost(
                          fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (price != null)
                        Text(
                          price,
                          style: GoogleFonts.jost(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      if (price != null) SizedBox(width: 8.w),
                      Text(
                        '$variantCount variant${variantCount == 1 ? '' : 's'}',
                        style: GoogleFonts.jost(
                            fontSize: 11.sp, color: AppColors.textSecondary),
                      ),
                      if ((p['types'] ?? '').toString().isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              p['types'].toString(),
                              style: GoogleFonts.jost(
                                  fontSize: 10.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Stock toggle
            Column(
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isActive,
                    onChanged: (_) => _toggleStock(p['id'], isActive),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Text(
                  isActive ? 'In Stock' : 'Out',
                  style: GoogleFonts.jost(
                      fontSize: 9.sp,
                      color: isActive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),

            // Menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  color: AppColors.textSecondary, size: 20.sp),
              onSelected: (val) {
                if (val == 'edit') _openForm(existing: p);
                if (val == 'delete') _confirmDelete(p);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    const Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 8.w),
                    Text('Edit', style: GoogleFonts.jost()),
                  ]),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    SizedBox(width: 8.w),
                    Text('Delete',
                        style: GoogleFonts.jost(color: AppColors.error)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: Text('Delete Product',
            style: GoogleFonts.jost(fontWeight: FontWeight.w700)),
        content: Text('Delete "${p['name']}"? This cannot be undone.',
            style: GoogleFonts.jost(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.jost()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () { Navigator.pop(context); _delete(p['id']); },
            child: Text('Delete', style: GoogleFonts.jost()),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Variant / key-value row models (hold their own controllers)
// ─────────────────────────────────────────────────────────────────────────────

class _VariantRow {
  final int? id;
  final TextEditingController name, price, selling, wholesale, stock;

  _VariantRow({
    this.id,
    String name = '',
    String price = '',
    String selling = '',
    String wholesale = '',
    String stock = '',
  })  : name = TextEditingController(text: name),
        price = TextEditingController(text: price),
        selling = TextEditingController(text: selling),
        wholesale = TextEditingController(text: wholesale),
        stock = TextEditingController(text: stock);

  void dispose() {
    name.dispose();
    price.dispose();
    selling.dispose();
    wholesale.dispose();
    stock.dispose();
  }

  bool get isEmpty => name.text.trim().isEmpty && selling.text.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name.text.trim(),
        'price': double.tryParse(price.text.trim()) ?? 0,
        'selling_price': double.tryParse(selling.text.trim()) ?? 0,
        'wholesale_price': double.tryParse(wholesale.text.trim()) ?? 0,
        'stock': int.tryParse(stock.text.trim()) ?? 0,
      };
}

class _KvRow {
  final int? id;
  final TextEditingController attr, value;

  _KvRow({this.id, String attr = '', String value = ''})
      : attr = TextEditingController(text: attr),
        value = TextEditingController(text: value);

  void dispose() {
    attr.dispose();
    value.dispose();
  }

  bool get isEmpty => attr.text.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'attribute': attr.text.trim(),
        'value': value.text.trim(),
      };
}

class _NewImage {
  final Uint8List bytes;
  final String name;
  _NewImage(this.bytes, this.name);
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit product form  (variants, highlights, info, multi-image)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductForm extends StatefulWidget {
  final List categories;
  final List types;
  final Map? existing;
  final VoidCallback onSaved;

  const _ProductForm({
    required this.categories,
    required this.types,
    this.existing,
    required this.onSaved,
  });

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _categoryId;
  int? _subcategoryId;
  List _subcategories = [];
  bool _loadingSubs = false;
  final Set<String> _selectedTypes = {};

  final List<_VariantRow> _variants = [];
  final List<_KvRow> _highlights = [];
  final List<_KvRow> _info = [];

  final List<String> _existingImages = []; // relative storage paths
  final List<_NewImage> _newImages = [];

  bool _saving = false;
  int? _savedId;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _nameCtrl.text = p['name'] ?? '';
      _descCtrl.text = p['description'] ?? '';
      _categoryId    = p['main_category_id'];
      _subcategoryId = p['subcategory_id'] is int
          ? p['subcategory_id']
          : int.tryParse('${p['subcategory_id'] ?? ''}');
      _savedId       = p['id'];
      if (_categoryId != null) _loadSubcategories(_categoryId!);

      for (final t in (p['types']?.toString() ?? '').split(',')) {
        final trimmed = t.trim();
        if (trimmed.isNotEmpty) _selectedTypes.add(trimmed);
      }
      for (final v in (p['variants'] as List?) ?? []) {
        _variants.add(_VariantRow(
          id: v['id'],
          name: '${v['name'] ?? ''}',
          price: _num(v['price']),
          selling: _num(v['selling_price']),
          wholesale: _num(v['wholesale_price']),
          stock: '${v['stock'] ?? ''}',
        ));
      }
      for (final h in (p['highlights'] as List?) ?? []) {
        _highlights.add(_KvRow(id: h['id'], attr: '${h['attribute'] ?? ''}', value: '${h['value'] ?? ''}'));
      }
      for (final i in (p['info'] as List?) ?? []) {
        _info.add(_KvRow(id: i['id'], attr: '${i['attribute'] ?? ''}', value: '${i['value'] ?? ''}'));
      }
      for (final img in (p['images'] as List?) ?? []) {
        _existingImages.add('$img');
      }
    }
    if (_variants.isEmpty) _variants.add(_VariantRow());
  }

  /// Trims a "100.00" style numeric string to "100" for nicer editing.
  String _num(dynamic v) {
    if (v == null) return '';
    final d = double.tryParse('$v');
    if (d == null) return '$v';
    return d == d.roundToDouble() ? d.toStringAsFixed(0) : '$d';
  }

  /// Loads subcategories for the chosen category (for the subcategory dropdown).
  Future<void> _loadSubcategories(int categoryId) async {
    setState(() => _loadingSubs = true);
    try {
      final res  = await VendorApiHelper.get('${ApiConstants.SUBCATEGORIES}?parent_id=$categoryId');
      final data = jsonDecode(res.body);
      if (!mounted) return;
      final subs = data['success'] == true ? (data['data'] ?? []) : [];
      // Drop a stale selection that isn't in the new category.
      final ids = subs.map((s) => s['id']).toList();
      setState(() {
        _subcategories = subs;
        if (!ids.contains(_subcategoryId)) _subcategoryId = null;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingSubs = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    for (final v in _variants) v.dispose();
    for (final h in _highlights) h.dispose();
    for (final i in _info) i.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final variants = _variants.where((v) => !v.isEmpty).map((v) => v.toJson()).toList();
    if (variants.isEmpty) {
      _snack('Add at least one variant (name + selling price)');
      return;
    }

    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        if (_savedId != null) 'id': _savedId,
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'main_category_id': _categoryId,
        if (_subcategoryId != null) 'subcategory_id': _subcategoryId,
        'types': _selectedTypes.join(', '),
        'variants': variants,
        'highlights': _highlights.where((h) => !h.isEmpty).map((h) => h.toJson()).toList(),
        'info': _info.where((i) => !i.isEmpty).map((i) => i.toJson()).toList(),
        // On update, send the surviving existing images so the server prunes removed ones.
        if (_savedId != null) 'images': _existingImages,
      };

      final url = _savedId != null
          ? ApiConstants.VENDOR_PRODUCT_UPDATE
          : ApiConstants.VENDOR_PRODUCT_INSERT;
      final res  = await VendorApiHelper.postJson(url, body: body);
      final data = jsonDecode(res.body);
      if (!mounted) return;

      if (data['success'] == true) {
        final productId = _savedId ?? data['id'];
        // Upload any newly-picked images.
        for (final img in _newImages) {
          if (productId == null) break;
          await VendorApiHelper.postJson(ApiConstants.VENDOR_PRODUCT_IMAGE, body: {
            'product_id': productId,
            'data': base64Encode(img.bytes),
            'name': img.name,
          });
        }
        widget.onSaved();
        if (mounted) Navigator.pop(context);
      } else {
        _snack(data['message'] ?? 'Failed');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage(maxWidth: 1000, imageQuality: 80);
    if (files.isEmpty) return;
    for (final f in files) {
      final bytes = await f.readAsBytes();
      _newImages.add(_NewImage(bytes, f.name));
    }
    if (mounted) setState(() {});
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.jost())));

  @override
  Widget build(BuildContext context) {
    final isEdit = _savedId != null;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      padding: EdgeInsets.only(
        left: 20.w, right: 20.w, top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40.w, height: 4.h,
                      decoration: BoxDecoration(
                          color: AppColors.borderColor,
                          borderRadius: BorderRadius.circular(2.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isEdit ? 'Edit Product' : 'Add Product',
                    style: GoogleFonts.jost(fontWeight: FontWeight.w700, fontSize: 18.sp),
                  ),
                  SizedBox(height: 18.h),

                  // ── Basics ───────────────────────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    style: GoogleFonts.jost(),
                    decoration: _deco('Product Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 2,
                    style: GoogleFonts.jost(),
                    decoration: _deco('Description (optional)'),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    isExpanded: true,
                    decoration: _deco('Category'),
                    items: widget.categories.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'] is int ? c['id'] : int.tryParse(c['id'].toString()),
                        child: Text(c['name'] ?? '', style: GoogleFonts.jost()),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _categoryId = v;
                        _subcategoryId = null;
                        _subcategories = [];
                      });
                      if (v != null) _loadSubcategories(v);
                    },
                    validator: (v) => v == null ? 'Select a category' : null,
                  ),
                  SizedBox(height: 12.h),

                  // ── Subcategory (depends on selected category) ─
                  if (_loadingSubs)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(children: [
                        SizedBox(
                          width: 14.w, height: 14.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10.w),
                        Text('Loading subcategories…',
                            style: GoogleFonts.jost(
                                fontSize: 12.sp, color: AppColors.textSecondary)),
                      ]),
                    )
                  else if (_subcategories.isNotEmpty)
                    DropdownButtonFormField<int>(
                      value: _subcategoryId,
                      isExpanded: true,
                      decoration: _deco('Subcategory (optional)'),
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text('None',
                              style: GoogleFonts.jost(color: AppColors.textSecondary)),
                        ),
                        ..._subcategories.map<DropdownMenuItem<int>>((s) {
                          return DropdownMenuItem<int>(
                            value: s['id'] is int ? s['id'] : int.tryParse('${s['id']}'),
                            child: Text(s['name'] ?? '', style: GoogleFonts.jost()),
                          );
                        }),
                      ],
                      onChanged: (v) => setState(() => _subcategoryId = v),
                    ),
                  if (_subcategories.isNotEmpty || _loadingSubs) SizedBox(height: 16.h)
                  else SizedBox(height: 4.h),

                  // ── Product types ────────────────────────────
                  if (widget.types.isNotEmpty) ...[
                    _sectionLabel('Product Types'),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: widget.types.map((t) {
                        final name = t['name']?.toString() ?? '';
                        final selected = _selectedTypes.contains(name);
                        return GestureDetector(
                          onTap: () => setState(() {
                            selected ? _selectedTypes.remove(name) : _selectedTypes.add(name);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 130),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.background,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: selected ? AppColors.primary : AppColors.borderColor,
                              ),
                            ),
                            child: Text(
                              name,
                              style: GoogleFonts.jost(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 18.h),
                  ],

                  // ── Variants ─────────────────────────────────
                  _sectionHeader('Variants & Pricing', onAdd: () {
                    setState(() => _variants.add(_VariantRow()));
                  }),
                  SizedBox(height: 8.h),
                  ..._variants.asMap().entries.map((e) => _variantCard(e.key, e.value)),
                  SizedBox(height: 18.h),

                  // ── Images ───────────────────────────────────
                  _sectionLabel('Images'),
                  SizedBox(height: 8.h),
                  _imagesRow(),
                  SizedBox(height: 18.h),

                  // ── Highlights ───────────────────────────────
                  _sectionHeader('Highlights', onAdd: () {
                    setState(() => _highlights.add(_KvRow()));
                  }),
                  SizedBox(height: 8.h),
                  if (_highlights.isEmpty)
                    _emptyHint('No highlights. Tap + to add (e.g. Brand → Acme).'),
                  ..._highlights.asMap().entries.map((e) => _kvCard(_highlights, e.key, e.value, 'Attribute', 'Value')),
                  SizedBox(height: 18.h),

                  // ── Product info ─────────────────────────────
                  _sectionHeader('Product Info', onAdd: () {
                    setState(() => _info.add(_KvRow()));
                  }),
                  SizedBox(height: 8.h),
                  if (_info.isEmpty)
                    _emptyHint('No info rows. Tap + to add (e.g. Shelf life → 6 months).'),
                  ..._info.asMap().entries.map((e) => _kvCard(_info, e.key, e.value, 'Attribute', 'Value')),
                  SizedBox(height: 22.h),

                  // ── Save ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: _saving
                          ? SizedBox(
                              width: 20.w, height: 20.w,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEdit ? 'Update Product' : 'Add Product',
                              style: GoogleFonts.jost(
                                  fontWeight: FontWeight.w600, fontSize: 15.sp, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.jost(
            fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      );

  Widget _sectionHeader(String text, {required VoidCallback onAdd}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel(text),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(children: [
                Icon(Icons.add, size: 15.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text('Add',
                    style: GoogleFonts.jost(
                        fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
          ),
        ],
      );

  Widget _emptyHint(String text) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(text,
            style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.hint)),
      );

  Widget _variantCard(int index, _VariantRow v) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: v.name,
                  style: GoogleFonts.jost(fontSize: 13.sp),
                  decoration: _deco('Variant (e.g. 500g)'),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              if (_variants.length > 1)
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18.sp, color: AppColors.error),
                  onPressed: () => setState(() {
                    _variants.removeAt(index).dispose();
                  }),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _numField(v.price, 'MRP')),
              SizedBox(width: 10.w),
              Expanded(child: _numField(v.selling, 'Selling ₹', required: true)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _numField(v.wholesale, 'Wholesale')),
              SizedBox(width: 10.w),
              Expanded(child: _numField(v.stock, 'Stock', integer: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label,
      {bool required = false, bool integer = false}) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        integer
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      style: GoogleFonts.jost(fontSize: 13.sp),
      decoration: _deco(label),
      validator: required
          ? (val) => (val == null || val.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _kvCard(List<_KvRow> list, int index, _KvRow row, String attrLabel, String valueLabel) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: row.attr,
              style: GoogleFonts.jost(fontSize: 13.sp),
              decoration: _deco(attrLabel),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextFormField(
              controller: row.value,
              style: GoogleFonts.jost(fontSize: 13.sp),
              decoration: _deco(valueLabel),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18.sp, color: AppColors.error),
            onPressed: () => setState(() => list.removeAt(index).dispose()),
          ),
        ],
      ),
    );
  }

  Widget _imagesRow() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        // existing images
        ..._existingImages.map((path) => _imageThumb(
              NetworkImage(ApiConstants.imageUrl(path)),
              onRemove: () => setState(() => _existingImages.remove(path)),
            )),
        // newly-picked images
        ..._newImages.map((img) => _imageThumb(
              MemoryImage(img.bytes),
              onRemove: () => setState(() => _newImages.remove(img)),
            )),
        // add tile
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: 76.w, height: 76.w,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 24.sp),
                Text('Add', style: GoogleFonts.jost(fontSize: 10.sp, color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageThumb(ImageProvider provider, {required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          width: 76.w, height: 76.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderColor),
            image: DecorationImage(image: provider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2, right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jost(color: AppColors.textSecondary, fontSize: 13.sp),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
      );
}
