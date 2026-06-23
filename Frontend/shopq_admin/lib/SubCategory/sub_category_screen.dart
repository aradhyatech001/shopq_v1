import 'dart:typed_data';
import 'package:shopq_admin/CustomWidgets/app_network_image.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({super.key});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  // ── Form state ────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _editingId;
  String? _editingImageUrl;
  String? _selectedParentId;
  bool _saving = false;

  // ── List state ────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  List _mainCats = [];
  List _all = [];
  List _filtered = [];
  bool _loading = true;
  String? _filterParentId;

  @override
  void initState() {
    super.initState();
    _fetchMainCategories();
    _fetchSubCategories();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────
  Future<void> _fetchMainCategories() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.MAIN_VIEW_CATEGORY));
      if (res.statusCode == 200 && mounted) {
        setState(() => _mainCats = jsonDecode(res.body) as List);
      }
    } catch (_) {}
  }

  Future<void> _fetchSubCategories({String? parentId}) async {
    if (mounted) setState(() => _loading = true);
    try {
      var url = '${ApiConstants.VIEW_SUBCATEGORIES}?admin=1';
      if (parentId != null && parentId != 'all') {
        url += '&parent_id=$parentId';
      }
      final res = await AdminApi.get(Uri.parse(url));
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List? ?? []);
        setState(() {
          _all = list;
          _filtered = List.from(list);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_all)
          : _all
                .where((s) => s['name'].toString().toLowerCase().contains(q))
                .toList();
    });
  }

  // ── CRUD ──────────────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Name is required', AppColors.warningColor);
      return;
    }
    if (_selectedParentId == null && _editingId == null) {
      _snack('Select a main category', AppColors.warningColor);
      return;
    }
    setState(() => _saving = true);
    try {
      final isEdit = _editingId != null;
      final url = isEdit
          ? ApiConstants.EDIT_SUBCATEGORY
          : ApiConstants.ADD_SUBCATEGORY;
      final body = <String, String>{
        'name': name,
        if (!isEdit && _selectedParentId != null)
          'parent_id': _selectedParentId!,
        if (isEdit) 'id': _editingId!,
        if (isEdit && _selectedParentId != null)
          'parent_id': _selectedParentId!,
        if (_imageBytes != null) 'data': base64Encode(_imageBytes!),
        if (_imageFileName != null) 'filename': _imageFileName!,
      };
      final res = await AdminApi.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (data['success'] == true || data['success'] == 'true') {
        _snack(isEdit ? 'Updated!' : 'Added!', AppColors.successColor);
        _resetForm();
        _fetchSubCategories(parentId: _filterParentId);
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String id) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete Subcategory',
      message: 'This subcategory will be permanently removed.',
    );
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.DELETE_SUBCATEGORY),
        body: {'id': id},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true || data['success'] == 'true') {
        _snack('Deleted', AppColors.successColor);
        _fetchSubCategories(parentId: _filterParentId);
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    }
  }

  Future<void> _pickImage() async {
    final bytes = await ImagePickerWeb.getImageAsBytes();
    if (bytes == null) return;
    if (bytes.lengthInBytes > 102400) {
      _snack('Image must be under 100 KB', AppColors.warningColor);
      return;
    }
    setState(() {
      _imageBytes = bytes;
      _imageFileName = 'sub_${DateTime.now().millisecondsSinceEpoch}.png';
    });
  }

  void _startEdit(Map<String, dynamic> sub) => setState(() {
    _editingId = sub['id'].toString();
    _nameCtrl.text = sub['name'] ?? '';
    _selectedParentId = (sub['parent_id'] ?? sub['main_category_id'])
        ?.toString();
    _editingImageUrl = sub['image'];
    _imageBytes = null;
    _imageFileName = null;
  });

  void _resetForm() => setState(() {
    _editingId = null;
    _selectedParentId = null;
    _imageBytes = null;
    _imageFileName = null;
    _editingImageUrl = null;
    _nameCtrl.clear();
  });

  String _parentName(dynamic id) {
    if (id == null) return '—';
    final m = _mainCats.firstWhere(
      (c) => c['id'].toString() == id.toString(),
      orElse: () => null,
    );
    return m?['name'] ?? id.toString();
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
      title: 'Sub Categories',
      subtitle: '${_filtered.length} subcategories',
      actions: [
        IconButton(
          onPressed: () => _fetchSubCategories(parentId: _filterParentId),
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
          tooltip: 'Refresh',
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: list ────────────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Filter + search row
                  Row(
                    children: [
                      Expanded(child: _buildFilterDropdown()),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: AdminSearchBar(
                          controller: _searchCtrl,
                          hint: 'Search subcategories...',
                          onClear: _filter,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(child: _buildList()),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          // ── Right: form ───────────────────────────────────
          SizedBox(
            width: 340.w,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter dropdown ───────────────────────────────────────
  Widget _buildFilterDropdown() {
    // Ensure value is valid
    final validIds = ['all', ..._mainCats.map((m) => m['id'].toString())];
    final current = validIds.contains(_filterParentId ?? 'all')
        ? (_filterParentId ?? 'all')
        : 'all';

    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButton<String>(
        value: current,
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
            (m) => DropdownMenuItem(
              value: m['id'].toString(),
              child: Text(m['name'], style: GoogleFonts.jost(fontSize: 13.sp)),
            ),
          ),
        ],
        onChanged: (val) {
          setState(() => _filterParentId = val == 'all' ? null : val);
          _fetchSubCategories(parentId: val == 'all' ? null : val);
        },
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────
  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_filtered.isEmpty) {
      return EmptyState(
        icon: Icons.account_tree_outlined,
        message: 'No subcategories found',
        hint: _filterParentId != null ? 'Try "All Categories"' : null,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final sub = _filtered[i];
        return _SubCatTile(
          sub: sub,
          parentName: _parentName(sub['parent_id'] ?? sub['main_category_id']),
          onEdit: () => _startEdit(sub),
          onDelete: () => _delete(sub['id'].toString()),
        );
      },
    );
  }

  // ── Form ──────────────────────────────────────────────────
  Widget _buildForm() {
    final validIds = _mainCats.map((m) => m['id'].toString()).toList();
    final validParent = validIds.contains(_selectedParentId)
        ? _selectedParentId
        : null;

    return SectionCard(
      title: _editingId == null ? 'Add Subcategory' : 'Edit Subcategory',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormLabel('Main Category', required: true),
          Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: DropdownButton<String>(
              value: validParent,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Text(
                'Select category',
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
              items: _mainCats
                  .map(
                    (m) => DropdownMenuItem<String>(
                      value: m['id'].toString(),
                      child: Text(
                        m['name'],
                        style: GoogleFonts.jost(fontSize: 13.sp),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedParentId = v),
            ),
          ),
          SizedBox(height: 16.h),

          const FormLabel('Subcategory Name', required: true),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.jost(fontSize: 13.sp),
            decoration: const InputDecoration(hintText: 'e.g. Leafy Greens'),
          ),
          SizedBox(height: 16.h),

          const FormLabel('Image'),
          Text(
            'Max 100 KB',
            style: GoogleFonts.jost(
              fontSize: 11.sp,
              color: AppColors.hintTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          ImagePickerTile(
            bytes: _imageBytes,
            networkUrl: _editingImageUrl,
            onTap: _pickImage,
            height: 140,
          ),
          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _save,
                        child: Text(
                          _editingId == null
                              ? 'Add Subcategory'
                              : 'Update Subcategory',
                          style: GoogleFonts.jost(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              if (_editingId != null) ...[
                SizedBox(width: 10.w),
                OutlinedButton(
                  onPressed: _resetForm,
                  child: Text('Cancel', style: GoogleFonts.jost()),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-category list tile ────────────────────────────────────────────────────
class _SubCatTile extends StatelessWidget {
  final Map<String, dynamic> sub;
  final String parentName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubCatTile({
    required this.sub,
    required this.parentName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.primaryLight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: sub['image'] != null && sub['image'].toString().isNotEmpty
                  ? AppNetworkImage(
                      sub['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
          SizedBox(width: 14.w),

          // Name + parent
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub['name'] ?? '',
                  style: GoogleFonts.jost(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 11.sp,
                      color: AppColors.hintTextColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      parentName,
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

  Widget _fallback() => Icon(
    Icons.account_tree_outlined,
    color: AppColors.primaryColor,
    size: 20,
  );
}
