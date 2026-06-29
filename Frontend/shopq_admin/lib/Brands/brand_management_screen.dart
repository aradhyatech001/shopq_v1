import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../CustomWidgets/app_network_image.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

/// Admin → Brands: manage product brands (Lux, Parle, Amul, Tata, …).
class BrandManagementScreen extends StatefulWidget {
  const BrandManagementScreen({super.key});

  @override
  State<BrandManagementScreen> createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  List _brands = [];
  bool _loading = true;

  final _nameCtrl = TextEditingController();
  String? _editingId;
  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _existingImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.BRANDS_ALL));
      final data = jsonDecode(res.body);
      if (data['success'] == true) _brands = data['data'] ?? [];
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _editingId = null;
    _nameCtrl.clear();
    _imageBytes = null;
    _imageFileName = null;
    _existingImage = null;
  }

  void _startEdit(Map b) {
    setState(() {
      _editingId = b['id'].toString();
      _nameCtrl.text = b['name']?.toString() ?? '';
      _imageBytes = null;
      _imageFileName = null;
      _existingImage = b['image']?.toString();
    });
  }

  Future<void> _pickImage() async {
    final info = await ImagePickerWeb.getImageInfo();
    if (info?.data == null) return;
    setState(() {
      _imageBytes = info!.data;
      _imageFileName =
          'brand_${DateTime.now().millisecondsSinceEpoch}_${info.fileName ?? 'logo.png'}';
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Brand name is required', AppColors.warningColor);
      return;
    }
    setState(() => _saving = true);
    try {
      final url = _editingId == null
          ? ApiConstants.BRAND_ADD
          : ApiConstants.BRAND_EDIT;
      final body = <String, String>{
        'name': name,
        if (_editingId != null) 'id': _editingId!,
        if (_imageBytes != null) 'data': base64Encode(_imageBytes!),
        if (_imageFileName != null) 'filename': _imageFileName!,
      };
      final res = await AdminApi.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack(_editingId == null ? 'Brand added!' : 'Brand updated!',
            AppColors.successColor);
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

  Future<void> _toggle(Map b) async {
    await AdminApi.post(Uri.parse(ApiConstants.BRAND_TOGGLE),
        body: {'id': b['id'].toString()});
    _fetch();
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final item = _brands.removeAt(oldIndex);
      _brands.insert(newIndex, item);
    });
    final payload = [
      for (int i = 0; i < _brands.length; i++)
        {'id': _brands[i]['id'], 'position': i + 1}
    ];
    try {
      await AdminApi.postJson(Uri.parse(ApiConstants.BRAND_REORDER),
          body: {'brands': payload});
    } catch (_) {}
  }

  Future<void> _delete(Map b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete brand?', style: GoogleFonts.jost()),
        content: Text(
            'Products linked to "${b['name']}" will be unlinked.',
            style: GoogleFonts.jost()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.jost())),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.errorColor),
              child: Text('Delete', style: GoogleFonts.jost(color: Colors.white))),
        ],
      ),
    );
    if (ok != true) return;
    await AdminApi.post(Uri.parse(ApiConstants.BRAND_DELETE),
        body: {'id': b['id'].toString()});
    _snack('Brand deleted', AppColors.successColor);
    _fetch();
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── List ──────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Brands',
                        style: GoogleFonts.jost(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTextColor)),
                    SizedBox(width: 8.w),
                    Text('drag to reorder',
                        style: GoogleFonts.jost(
                            fontSize: 11.sp, color: AppColors.hintTextColor)),
                    const Spacer(),
                    IconButton(
                        onPressed: _fetch,
                        icon: const Icon(Icons.refresh_rounded),
                        color: AppColors.secondaryTextColor),
                  ]),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _brands.isEmpty
                            ? Center(
                                child: Text('No brands yet',
                                    style: GoogleFonts.jost(
                                        color: AppColors.secondaryTextColor)))
                            : ReorderableListView.builder(
                                buildDefaultDragHandles: true,
                                itemCount: _brands.length,
                                onReorder: _reorder,
                                itemBuilder: (_, i) => Padding(
                                  key: ValueKey(_brands[i]['id']),
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: _brandCard(_brands[i] as Map),
                                ),
                              ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            // ── Form ──────────────────────────────────────────────
            Expanded(flex: 2, child: _form()),
          ],
        ),
      ),
    );
  }

  Widget _brandCard(Map b) {
    final active = b['is_active'] == 1 || b['is_active'] == true;
    final img = b['image']?.toString() ?? '';
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: img.isEmpty
                ? Icon(Icons.sell_rounded, color: AppColors.hintTextColor, size: 22.sp)
                : AppNetworkImage(img, fit: BoxFit.cover),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b['name']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jost(
                        fontSize: 14.sp, fontWeight: FontWeight.w700)),
                Text('${b['products_count'] ?? 0} products',
                    style: GoogleFonts.jost(
                        fontSize: 11.sp, color: AppColors.secondaryTextColor)),
              ],
            ),
          ),
          Switch(
            value: active,
            activeThumbColor: AppColors.primaryColor,
            onChanged: (_) => _toggle(b),
          ),
          IconButton(
              icon: Icon(Icons.edit_outlined, size: 18.sp, color: Colors.blueGrey),
              onPressed: () => _startEdit(b)),
          IconButton(
              icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red.shade300),
              onPressed: () => _delete(b)),
        ],
      ),
    );
  }

  Widget _form() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_editingId == null ? 'Add Brand' : 'Edit Brand',
              style: GoogleFonts.jost(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 14.h),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.jost(),
            decoration: InputDecoration(
              labelText: 'Brand name (e.g. Amul)',
              labelStyle: GoogleFonts.jost(fontSize: 13.sp),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 14.h),
          Row(children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 80.w,
                height: 80.w,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : (_existingImage != null && _existingImage!.isNotEmpty
                        ? AppNetworkImage(_existingImage!, fit: BoxFit.cover)
                        : Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.hintTextColor, size: 26.sp)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text('Tap to upload a logo (optional).',
                  style: GoogleFonts.jost(
                      fontSize: 12.sp, color: AppColors.secondaryTextColor)),
            ),
          ]),
          SizedBox(height: 18.h),
          Row(children: [
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryColor),
              child: _saving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(_editingId == null ? 'Add Brand' : 'Update',
                      style: GoogleFonts.jost(color: Colors.white)),
            ),
            if (_editingId != null) ...[
              SizedBox(width: 8.w),
              TextButton(
                  onPressed: () => setState(_resetForm),
                  child: Text('Cancel', style: GoogleFonts.jost())),
            ],
          ]),
        ],
      ),
    );
  }
}
