import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

/// Per-tab storefront builder. Lets the admin add / order / configure the
/// sections (banner, category grid, brand grid, product-type row) shown in a
/// home tab on the customer app. Reads/writes /admin/home-sections.
class SectionBuilderScreen extends StatefulWidget {
  final Map tab; // {id, name, type, category_name, ...}
  const SectionBuilderScreen({super.key, required this.tab});

  @override
  State<SectionBuilderScreen> createState() => _SectionBuilderScreenState();
}

class _SectionBuilderScreenState extends State<SectionBuilderScreen> {
  List _sections = [];
  List _productTypes = [];
  List _categories = [];
  List _banners = [];
  bool _loading = true;

  int get _tabId => widget.tab['id'] as int;

  static const Map<String, String> _typeLabels = {
    'category_grid': 'Category Grid',
    'brand_grid': 'Brand Grid',
    'shop_grid': 'Shop Grid',
    'product_type': 'Product-Type Row',
    'products': 'Products Row',
    'banner': 'Banner',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AdminApi.get(Uri.parse('${ApiConstants.HOME_SECTIONS}?tab_id=$_tabId')),
        AdminApi.get(Uri.parse(ApiConstants.VIEW_PRODUCT_TYPES)),
        AdminApi.get(Uri.parse(ApiConstants.MAIN_VIEW_CATEGORY)),
        AdminApi.get(Uri.parse(ApiConstants.VIEW_BANNER)),
      ]);
      final s = jsonDecode(results[0].body);
      final t = jsonDecode(results[1].body);
      final c = jsonDecode(results[2].body);
      final b = jsonDecode(results[3].body);
      if (!mounted) return;
      setState(() {
        _sections = s['success'] == true ? (s['data'] ?? []) : [];
        _productTypes = t['success'] == true ? (t['data'] ?? []) : [];
        // /admin/categories may return {success,data:[]} or a bare list.
        _categories = c is List ? c : (c['data'] ?? []);
        _banners = b['success'] == true ? (b['data']?['offer_banners'] ?? []) : [];
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    await AdminApi.post(Uri.parse(ApiConstants.HOME_SECTIONS_DELETE), body: {'id': '$id'});
    _load();
  }

  Future<void> _toggle(int id) async {
    await AdminApi.post(Uri.parse(ApiConstants.HOME_SECTIONS_TOGGLE), body: {'id': '$id'});
    _load();
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m, style: GoogleFonts.jost())));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sections · ${widget.tab['name']}',
                style: GoogleFonts.jost(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTextColor)),
            Text('What shows in this tab, top to bottom',
                style: GoogleFonts.jost(
                    fontSize: 11.sp, color: AppColors.secondaryTextColor)),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryTextColor),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: FilledButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add Section', style: GoogleFonts.jost(fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryColor),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard_customize_outlined,
                          size: 56.sp, color: AppColors.hintTextColor),
                      SizedBox(height: 12.h),
                      Text('No sections yet',
                          style: GoogleFonts.jost(
                              fontSize: 15.sp, color: AppColors.secondaryTextColor)),
                      SizedBox(height: 4.h),
                      Text('Add banners, category grids and product rows.',
                          style: GoogleFonts.jost(
                              fontSize: 12.sp, color: AppColors.hintTextColor)),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add),
                        label: Text('Add first section', style: GoogleFonts.jost()),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _sections.length,
                  onReorder: _onReorder,
                  itemBuilder: (_, i) => _sectionCard(_sections[i], i, key: ValueKey(_sections[i]['id'])),
                ),
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _sections.removeAt(oldIndex);
      _sections.insert(newIndex, item);
    });
    final payload = [
      for (int i = 0; i < _sections.length; i++)
        {'id': _sections[i]['id'], 'position': i + 1}
    ];
    await AdminApi.postJson(Uri.parse(ApiConstants.HOME_SECTIONS_REORDER),
        body: {'sections': payload});
  }

  Widget _sectionCard(Map s, int index, {required Key key}) {
    final active = s['is_active'] == 1 || s['is_active'] == true;
    final type = s['section_type']?.toString() ?? '';
    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ListTile(
        leading: Container(
          width: 40.w, height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(_iconFor(type), color: AppColors.primaryColor, size: 20.sp),
        ),
        title: Text(
          (s['title']?.toString().isNotEmpty == true) ? s['title'] : (_typeLabels[type] ?? type),
          style: GoogleFonts.jost(fontWeight: FontWeight.w700, fontSize: 14.sp),
        ),
        subtitle: Text(
          _subtitleFor(s),
          style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.secondaryTextColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: active,
              activeColor: AppColors.primaryColor,
              onChanged: (_) => _toggle(s['id'] as int),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 18.sp, color: Colors.blueGrey),
              onPressed: () => _openForm(existing: s),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red.shade300),
              onPressed: () => _delete(s['id'] as int),
            ),
            Icon(Icons.drag_handle, color: Colors.grey, size: 18.sp),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'banner': return Icons.image_rounded;
      case 'category_grid': return Icons.grid_view_rounded;
      case 'brand_grid': return Icons.sell_rounded;
      case 'shop_grid': return Icons.storefront_rounded;
      default: return Icons.view_carousel_rounded;
    }
  }

  String _subtitleFor(Map s) {
    final type = s['section_type']?.toString() ?? '';
    final label = _typeLabels[type] ?? type;
    if (type == 'product_type') return '$label · ${s['product_type'] ?? 'any'} · limit ${s['product_limit']}';
    if (type == 'banner') {
      final count = (s['banner_count'] ?? (s['banner_ids'] is List ? (s['banner_ids'] as List).length : 0)) as int;
      if (count > 0) return '$label · $count banner${count == 1 ? '' : 's'}';
      return '$label · ${(s['banner_image'] ?? '').toString().isNotEmpty ? '1 banner' : 'none selected'}';
    }
    return '$label · limit ${s['product_limit']}';
  }

  // ── Add / Edit form (right side sheet) ──────────────────────────────────────
  void _openForm({Map? existing}) {
    showAdminSideSheet(
      context,
      width: 480,
      child: _SectionForm(
        tabId: _tabId,
        productTypes: _productTypes,
        categories: _categories,
        banners: _banners,
        existing: existing,
        onSaved: () { _load(); },
        snack: _snack,
      ),
    );
  }
}

class _SectionForm extends StatefulWidget {
  final int tabId;
  final List productTypes;
  final List categories;
  final List banners;
  final Map? existing;
  final VoidCallback onSaved;
  final void Function(String) snack;

  const _SectionForm({
    required this.tabId,
    required this.productTypes,
    required this.categories,
    required this.banners,
    required this.onSaved,
    required this.snack,
    this.existing,
  });

  @override
  State<_SectionForm> createState() => _SectionFormState();
}

class _SectionFormState extends State<_SectionForm> {
  final _titleCtrl = TextEditingController();
  final _limitCtrl = TextEditingController(text: '10');
  String _type = 'product_type';
  String? _productType;
  int? _categoryId;
  int? _subcategoryId;
  List _subcategories = [];
  bool _loadingSubs = false;
  bool _saving = false;

  // Banner section now references one or many existing banners.
  final Set<int> _selectedBannerIds = {};

  static const _types = [
    'product_type', 'products', 'category_grid', 'brand_grid', 'shop_grid', 'banner',
  ];
  static const _typeNames = {
    'product_type': 'Product-Type Row (e.g. Best Selling, Buy 1 Get 1, 50% Off)',
    'products': 'Products Row (no type — by category/subcategory)',
    'category_grid': 'Category Grid (sub-categories)',
    'brand_grid': 'Brand Grid (top categories)',
    'shop_grid': 'Shop Grid (best shops near you)',
    'banner': 'Banner (pick one or more banners)',
  };

  // Types that take category/subcategory scope + a product row.
  bool get _isProductRow => _type == 'product_type' || _type == 'products';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e['title'] ?? '';
      _limitCtrl.text = '${e['product_limit'] ?? 10}';
      _type = e['section_type'] ?? 'product_type';
      _productType = e['product_type'];
      _categoryId = e['main_category_id'] is int
          ? e['main_category_id']
          : int.tryParse('${e['main_category_id'] ?? ''}');
      _subcategoryId = e['subcategory_id'] is int
          ? e['subcategory_id']
          : int.tryParse('${e['subcategory_id'] ?? ''}');
      final ids = e['banner_ids'];
      if (ids is List) {
        for (final id in ids) {
          final v = id is int ? id : int.tryParse('$id');
          if (v != null) _selectedBannerIds.add(v);
        }
      }
      if (_categoryId != null) _loadSubcategories(_categoryId!);
    }
  }

  Future<void> _loadSubcategories(int categoryId) async {
    setState(() => _loadingSubs = true);
    try {
      final res = await AdminApi.get(
          Uri.parse('${ApiConstants.VIEW_SUBCATEGORIES}?parent_id=$categoryId'));
      final data = jsonDecode(res.body);
      if (!mounted) return;
      final subs = data['success'] == true ? (data['data'] ?? []) : [];
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
    _titleCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // A banner section must reference at least one banner.
    if (_type == 'banner' && _selectedBannerIds.isEmpty) {
      widget.snack('Select at least one banner to show');
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, String>{
        if (widget.existing != null) 'id': '${widget.existing!['id']}',
        'home_tab_id': '${widget.tabId}',
        'title': _titleCtrl.text.trim(),
        'section_type': _type,
        'product_limit': _limitCtrl.text.trim().isEmpty ? '10' : _limitCtrl.text.trim(),
        if (_type == 'product_type' && _productType != null) 'product_type': _productType!,
        if (_isProductRow && _categoryId != null) 'main_category_id': '$_categoryId',
        if (_isProductRow && _subcategoryId != null) 'subcategory_id': '$_subcategoryId',
        if (_type == 'banner') 'banner_ids': jsonEncode(_selectedBannerIds.toList()),
      };
      final url = widget.existing != null
          ? ApiConstants.HOME_SECTIONS_EDIT
          : ApiConstants.HOME_SECTIONS_ADD;
      final res = await AdminApi.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (data['success'] == true) {
        widget.onSaved();
        Navigator.pop(context);
        widget.snack('Section saved');
      } else {
        widget.snack(data['message'] ?? 'Failed');
      }
    } catch (e) {
      widget.snack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AdminSideSheet(
      title: isEdit ? 'Edit Section' : 'Add Section',
      subtitle: 'What shows in this part of the tab',
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.jost())),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryColor),
          child: _saving
              ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isEdit ? 'Update' : 'Add', style: GoogleFonts.jost(color: Colors.white)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              _label('Section Type'),
              DropdownButtonFormField<String>(
                value: _type,
                isExpanded: true,
                decoration: _deco(),
                items: _types
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_typeNames[t]!,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jost())))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? 'product_type'),
              ),
              SizedBox(height: 12.h),
              _label('Title (heading shown to users)'),
              TextField(controller: _titleCtrl, style: GoogleFonts.jost(), decoration: _deco(hint: 'e.g. Best Selling')),
              SizedBox(height: 12.h),

              if (_type == 'product_type') ...[
                _label('Product Type'),
                DropdownButtonFormField<String>(
                  value: _productType,
                  isExpanded: true,
                  decoration: _deco(),
                  items: widget.productTypes
                      .map<DropdownMenuItem<String>>((t) => DropdownMenuItem(
                          value: t['name']?.toString(),
                          child: Text(t['name'] ?? '', style: GoogleFonts.jost())))
                      .toList(),
                  onChanged: (v) => setState(() => _productType = v),
                ),
                SizedBox(height: 12.h),
              ],

              if (_isProductRow || _type == 'category_grid') ...[
                _label('Category scope (optional — defaults to the tab\'s category)'),
                DropdownButtonFormField<int>(
                  value: _categoryId,
                  isExpanded: true,
                  decoration: _deco(),
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('Inherit from tab')),
                    ...widget.categories.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(
                        value: c['id'] is int ? c['id'] : int.tryParse('${c['id']}'),
                        child: Text(c['name'] ?? '', style: GoogleFonts.jost()))),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _categoryId = v;
                      _subcategoryId = null;
                      _subcategories = [];
                    });
                    if (v != null) _loadSubcategories(v);
                  },
                ),
                SizedBox(height: 12.h),
              ],

              // Subcategory filter for product rows (e.g. Basmati Rice, Fortune, Curd & Yogurt)
              if (_isProductRow && (_loadingSubs || _subcategories.isNotEmpty)) ...[
                _label('Subcategory / brand (optional)'),
                _loadingSubs
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(children: [
                          SizedBox(width: 14.w, height: 14.w, child: const CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 10.w),
                          Text('Loading…', style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.secondaryTextColor)),
                        ]),
                      )
                    : DropdownButtonFormField<int>(
                        value: _subcategoryId,
                        isExpanded: true,
                        decoration: _deco(),
                        items: [
                          const DropdownMenuItem<int>(value: null, child: Text('All in category')),
                          ..._subcategories.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(
                              value: s['id'] is int ? s['id'] : int.tryParse('${s['id']}'),
                              child: Text(s['name'] ?? '', style: GoogleFonts.jost()))),
                        ],
                        onChanged: (v) => setState(() => _subcategoryId = v),
                      ),
                SizedBox(height: 12.h),
              ],

              if (_type != 'banner') ...[
                _label('Item limit'),
                TextField(
                  controller: _limitCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.jost(),
                  decoration: _deco(hint: '10'),
                ),
              ],
              if (_type == 'banner') ...[
                _label('Banners to show (${_selectedBannerIds.length} selected)'),
                Text(
                  'Pick one or more. Several selected → shown as a sliding carousel. '
                  'Create banners in Storefront → Banners.',
                  style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hintTextColor),
                ),
                SizedBox(height: 10.h),
                if (widget.banners.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Text('No banners yet. Add some in Banners first.',
                        style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.secondaryTextColor)),
                  )
                else
                  ...widget.banners.map(_bannerOption),
              ],
            ],
          ),
    );
  }

  /// A selectable banner row: thumbnail + category + check.
  Widget _bannerOption(dynamic b) {
    final id = b['id'] is int ? b['id'] : int.tryParse('${b['id']}');
    if (id == null) return const SizedBox.shrink();
    final selected = _selectedBannerIds.contains(id);
    final img = (b['banner_image'] ?? '').toString();
    final cat = (b['main_category_name'] ?? b['category_name'] ?? 'Banner').toString();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: () => setState(() {
          selected ? _selectedBannerIds.remove(id) : _selectedBannerIds.add(id);
        }),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor.withValues(alpha: 0.08) : AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected ? AppColors.primaryColor : AppColors.borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: SizedBox(
                  width: 64.w,
                  height: 40.h,
                  child: img.isEmpty
                      ? Container(color: AppColors.borderColor, child: Icon(Icons.image, size: 16.sp, color: AppColors.hintTextColor))
                      : Image.network(img, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.borderColor, child: Icon(Icons.broken_image, size: 16.sp, color: AppColors.hintTextColor))),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(cat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w600)),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: selected ? AppColors.primaryColor : AppColors.hintTextColor,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(t, style: GoogleFonts.jost(fontSize: 12.sp, fontWeight: FontWeight.w600)),
      );

  InputDecoration _deco({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.jost(color: AppColors.hintTextColor),
        isDense: true,
        filled: true,
        fillColor: AppColors.backgroundColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      );
}
