import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class BannerManagementScreen extends StatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List _banners = [];
  List _categories = [];
  bool _loading = true;
  bool _saving = false;

  String? _selectedCatId;
  Uint8List? _imageBytes;
  String? _imageFileName;
  Map? _editingBanner; // null = the panel is in "Add" mode

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([_fetchBanners(), _fetchCategories()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchBanners() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.VIEW_BANNER));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        _banners = data['data']['offer_banners'] ?? [];
      }
    } catch (_) {}
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.MAIN_VIEW_CATEGORY));
      if (res.statusCode == 200 && mounted) {
        _categories = jsonDecode(res.body) as List;
      }
    } catch (_) {}
  }

  // Loads a banner into the right panel for editing (no separate sheet).
  void _startEdit(Map banner) {
    final catIds = _categories.map((c) => c['id'].toString()).toList();
    final raw = banner['category_id']?.toString();
    setState(() {
      _editingBanner = Map<String, dynamic>.from(banner);
      _selectedCatId = catIds.contains(raw) ? raw : null;
      _imageBytes = null;
      _imageFileName = null;
    });
  }

  // Add (no editing banner) or update (editing) â€” one panel does both.
  Future<void> _saveBanner() async {
    final editing = _editingBanner != null;
    if (_selectedCatId == null) {
      _snack('Select a category', AppColors.warningColor);
      return;
    }
    if (!editing && _imageBytes == null) {
      _snack('Select a banner image', AppColors.warningColor);
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, String>{'category_id': _selectedCatId!};
      if (editing) body['id'] = _editingBanner!['id'].toString();
      if (_imageBytes != null) {
        body['data'] = base64Encode(_imageBytes!);
        body['name'] = _imageFileName ?? 'banner_${DateTime.now().millisecondsSinceEpoch}.png';
      }
      final res = await AdminApi.post(
        Uri.parse(editing ? ApiConstants.EDIT_BANNER : ApiConstants.ADD_BANNER),
        body: body,
      );
      final data = jsonDecode(res.body);
      if (data['success'] == 'true' || data['success'] == true) {
        _snack(editing ? 'Banner updated!' : 'Banner added!', AppColors.successColor);
        _resetForm();
        _loadAll();
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleBanner(Map<String, dynamic> banner) async {
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.TOGGLE_BANNER),
        body: {'id': banner['id'].toString()},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => banner['is_active'] = data['is_active']);
      }
    } catch (_) {}
  }

  Future<void> _deleteBanner(String id) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete Banner',
      message: 'This banner will be permanently removed.',
    );
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.DELETE_BANNER),
        body: {'id': id},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == 'true' || data['success'] == true) {
        _snack('Banner deleted', AppColors.successColor);
        _loadAll();
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    }
  }

  Future<void> _pickImage() async {
    final bytes = await ImagePickerWeb.getImageAsBytes();
    if (bytes == null) return;
    if (bytes.lengthInBytes > 204800) {
      _snack('Image must be under 200 KB', AppColors.warningColor);
      return;
    }
    setState(() {
      _imageBytes = bytes;
      _imageFileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.png';
    });
  }

  void _resetForm() => setState(() {
    _editingBanner = null;
    _selectedCatId = null;
    _imageBytes = null;
    _imageFileName = null;
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

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Banners',
      subtitle: '${_banners.length} banners',
      actions: [
        IconButton(
          onPressed: _loadAll,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // â”€â”€ Left: banner list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Expanded(
                  flex: 3,
                  child: _banners.isEmpty
                      ? const EmptyState(
                          icon: Icons.image_outlined,
                          message: 'No banners yet',
                          hint: 'Add one using the form',
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _banners.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (_, i) => _BannerTile(
                            banner: _banners[i],
                            onToggle: () => _toggleBanner(_banners[i]),
                            onEdit: () => _startEdit(_banners[i]),
                            onDelete: () =>
                                _deleteBanner(_banners[i]['id'].toString()),
                          ),
                        ),
                ),

                const VerticalDivider(width: 1),

                // â”€â”€ Right: add form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                SizedBox(
                  width: 320.w,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: _buildForm(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildForm() {
    final editing = _editingBanner != null;
    final currentImage = (_editingBanner?['banner_image'] ?? '').toString();
    return SectionCard(
      title: editing ? 'Edit Banner' : 'Add Banner',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormLabel('Category', required: true),
          _categoryDropdown(
            value: _selectedCatId,
            onChanged: (v) => setState(() => _selectedCatId = v),
          ),
          SizedBox(height: 16.h),

          const FormLabel('Banner Image', required: true),
          Text(
            '300Ã—150 recommended Â· Max 200 KB',
            style: GoogleFonts.jost(
              fontSize: 11.sp,
              color: AppColors.hintTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          // New pick wins; else current banner image (edit); else empty picker.
          if (_imageBytes == null && editing && currentImage.isNotEmpty)
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  currentImage,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140.h,
                    color: AppColors.backgroundColor,
                    child: const Icon(Icons.image, color: AppColors.hintTextColor),
                  ),
                ),
              ),
            )
          else
            ImagePickerTile(bytes: _imageBytes, onTap: _pickImage, height: 140),
          if (editing)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text('Tap the image to change it',
                  style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hintTextColor)),
            ),
          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveBanner,
                        child: Text(
                          editing ? 'Save' : 'Add Banner',
                          style: GoogleFonts.jost(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: _resetForm,
                child: Text(editing ? 'Cancel' : 'Reset', style: GoogleFonts.jost()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final ids = _categories.map((c) => c['id'].toString()).toList();
    final safe = ids.contains(value) ? value : null;
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButton<String>(
        value: safe,
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
        items: _categories
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
        onChanged: onChanged,
      ),
    );
  }
}

// â”€â”€ Banner tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BannerTile extends StatelessWidget {
  final Map<String, dynamic> banner;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerTile({
    required this.banner,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = banner['is_active'] == true || banner['is_active'] == 1;
    final imageUrl = (banner['banner_image'] ?? '').toString();
    final catName =
        banner['main_category_name'] ??
        banner['category_name'] ??
        'No Category';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive
              ? AppColors.successColor.withValues(alpha: 0.3)
              : AppColors.borderColor,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11.r),
                  topRight: Radius.circular(11.r),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 130.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: StatusBadge(
                  label: isActive ? 'Active' : 'Inactive',
                  color: isActive
                      ? AppColors.successColor
                      : AppColors.errorColor,
                ),
              ),
            ],
          ),

          // Controls
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    catName,
                    style: GoogleFonts.jost(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: isActive,
                  activeThumbColor: AppColors.primaryColor,
                  onChanged: (_) => onToggle(),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryColor,
                    size: 18.sp,
                  ),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.errorColor,
                    size: 18.sp,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 130,
    color: AppColors.backgroundColor,
    child: const Center(
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.hintTextColor,
      ),
    ),
  );
}
