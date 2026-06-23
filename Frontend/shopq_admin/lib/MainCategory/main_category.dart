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


class MainCategory extends StatefulWidget {
  const MainCategory({super.key});

  @override
  State<MainCategory> createState() => _MainCategoryState();
}

class _MainCategoryState extends State<MainCategory> {
  // ── Form state ────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _editingId;
  String? _editingImageUrl;
  bool _saving = false;

  // ── List state ────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  List _all = [];
  List _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────
  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.MAIN_VIEW_CATEGORY));
      if (res.statusCode == 200 && mounted) {
        final list = jsonDecode(res.body) as List;
        setState(() {
          _all = list;
          _filtered = List.from(list);
          _loading = false;
        });
      }
    } catch (e) {
      _snack('Failed to load categories', AppColors.errorColor);
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_all)
          : _all
                .where((c) => c['name'].toString().toLowerCase().contains(q))
                .toList();
    });
  }

  // ── CRUD ──────────────────────────────────────────────────
  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Category name is required', AppColors.warningColor);
      return;
    }
    setState(() => _saving = true);
    try {
      final url = _editingId == null
          ? ApiConstants.MAIN_ADD_CATEGORY
          : ApiConstants.MAIN_EDIT_CATEGORY;
      final body = <String, String>{
        'category_name': name,
        if (_editingId != null) 'category_id': _editingId!,
        if (_imageBytes != null) 'data': base64Encode(_imageBytes!),
        if (_imageFileName != null) 'name': _imageFileName!,
      };
      final res = await AdminApi.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (data['success'] == 'true' || data['success'] == true) {
        _snack(
          _editingId == null ? 'Category added!' : 'Category updated!',
          AppColors.successColor,
        );
        _resetForm();
        _fetch();
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
      title: 'Delete Category',
      message: 'This category and its subcategories will be removed.',
    );
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.MAIN_DELETE_CATEGORY),
        body: {'id': id},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == 'true' || data['success'] == true) {
        _snack('Category deleted', AppColors.successColor);
        _fetch();
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
      _imageFileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.png';
    });
  }

  void _startEdit(Map<String, dynamic> cat) => setState(() {
    _editingId = cat['id'].toString();
    _nameCtrl.text = cat['name'] ?? '';
    _editingImageUrl = cat['image'];
    _imageBytes = null;
    _imageFileName = null;
  });

  void _resetForm() => setState(() {
    _editingId = null;
    _imageBytes = null;
    _imageFileName = null;
    _editingImageUrl = null;
    _nameCtrl.clear();
  });

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
      title: 'Main Categories',
      subtitle: '${_filtered.length} categories',
      actions: [
        IconButton(
          onPressed: _fetch,
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
                  AdminSearchBar(
                    controller: _searchCtrl,
                    hint: 'Search categories...',
                    onClear: _filter,
                  ),
                  SizedBox(height: 16.h),
                  Expanded(child: _buildList()),
                ],
              ),
            ),
          ),

          // Divider
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

  // ── List ──────────────────────────────────────────────────
  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_filtered.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        message: 'No categories found',
        hint: _searchCtrl.text.isNotEmpty ? 'Try a different search' : null,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _CategoryTile(
        cat: _filtered[i],
        onEdit: () => _startEdit(_filtered[i]),
        onDelete: () => _delete(_filtered[i]['id'].toString()),
      ),
    );
  }

  // ── Form ──────────────────────────────────────────────────
  Widget _buildForm() {
    return SectionCard(
      title: _editingId == null ? 'Add Category' : 'Edit Category',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormLabel('Category Name', required: true),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.jost(fontSize: 13.sp),
            decoration: const InputDecoration(
              hintText: 'e.g. Fruits & Vegetables',
            ),
          ),
          SizedBox(height: 18.h),

          const FormLabel('Image'),
          Text(
            'Max 100 KB · 1:1 ratio recommended',
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
            height: 160,
          ),
          SizedBox(height: 20.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _save,
                        child: Text(
                          _editingId == null
                              ? 'Add Category'
                              : 'Update Category',
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

// ── Category list tile ────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final Map<String, dynamic> cat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.cat,
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
              child: cat['image'] != null && cat['image'].toString().isNotEmpty
                  ? AppNetworkImage(
                      cat['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
          SizedBox(width: 14.w),

          // Name
          Expanded(
            child: Text(
              cat['name'] ?? '',
              style: GoogleFonts.jost(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  Widget _fallback() =>
      Icon(Icons.category_rounded, color: AppColors.primaryColor, size: 22);
}
