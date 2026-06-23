import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class ProductTypeScreen extends StatefulWidget {
  const ProductTypeScreen({super.key});

  @override
  State<ProductTypeScreen> createState() => _ProductTypeScreenState();
}

class _ProductTypeScreenState extends State<ProductTypeScreen> {
  List<Map<String, dynamic>> _types = [];
  bool _isLoading = true;
  bool _isFormVisible = false;
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  bool _isSubmitting = false;
  int? _editingId;
  bool _isSavingOrder = false;

  @override
  void initState() {
    super.initState();
    _fetchTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // ─── API calls ────────────────────────────────────────────

  Future<void> _fetchTypes() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.VIEW_PRODUCT_TYPES));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _types = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      _snack('Error loading types: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitType() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _snack('Please enter a type name', AppColors.warningColor);
      return;
    }
    if (mounted) setState(() => _isSubmitting = true);
    try {
      final url = _editingId == null
          ? ApiConstants.ADD_PRODUCT_TYPE
          : ApiConstants.EDIT_PRODUCT_TYPE;
      final posVal = _positionController.text.trim();
      final posBody = posVal.isNotEmpty ? {'position': posVal} : <String, String>{};
      final body = _editingId == null
          ? {'name': name, ...posBody}
          : {'id': _editingId.toString(), 'name': name, ...posBody};
      final res = await AdminApi.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack(
          _editingId == null ? 'Type added' : 'Type updated',
          AppColors.successColor,
        );
        _resetForm();
        _fetchTypes();
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Save new drag-drop order to backend.
  Future<void> _saveOrder() async {
    if (mounted) setState(() => _isSavingOrder = true);
    try {
      final ids = _types.map((t) => t['id']).toList();
      final res = await AdminApi.postJson(
        Uri.parse(ApiConstants.REORDER_PRODUCT_TYPES),
        body: {'ordered_ids': ids},
      );
      final data = jsonDecode(res.body);
      if (data['success'] != true) {
        _snack('Could not save order', AppColors.errorColor);
      } else {
        _snack('Order saved', AppColors.successColor);
      }
    } catch (e) {
      _snack('Error saving order: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _isSavingOrder = false);
    }
  }

  void _startEdit(Map<String, dynamic> type) {
    if (mounted) {
      setState(() {
        _editingId = type['id'];
        _nameController.text = type['name'];
        _positionController.text = (type['position'] ?? '').toString();
        _isFormVisible = true;
      });
    }
  }

  void _confirmDelete(Map<String, dynamic> type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Type',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Delete "${type['name']}"? Products with this type will lose it.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteType(type['id']);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteType(int id) async {
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.DELETE_PRODUCT_TYPE),
        body: {'id': id.toString()},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Deleted', AppColors.successColor);
        _fetchTypes();
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    }
  }

  void _resetForm() {
    _nameController.clear();
    _positionController.clear();
    if (mounted)
      setState(() {
        _editingId = null;
        _isFormVisible = false;
      });
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _editingId == null ? 'Add New Type' : 'Edit Type',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              labelText: 'Type Name',
              labelStyle: GoogleFonts.poppins(
                color: AppColors.secondaryTextColor,
              ),
              hintText: 'e.g. Best Selling',
              hintStyle: GoogleFonts.poppins(color: AppColors.hintTextColor),
              prefixIcon: const Icon(
                Icons.label_outline,
                color: AppColors.hintTextColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              filled: true,
              fillColor: AppColors.backgroundColor,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _positionController,
            style: GoogleFonts.poppins(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Position (optional)',
              labelStyle: GoogleFonts.poppins(color: AppColors.secondaryTextColor),
              hintText: 'e.g. 1, 2, 3 …',
              hintStyle: GoogleFonts.poppins(color: AppColors.hintTextColor),
              prefixIcon: const Icon(Icons.format_list_numbered, color: AppColors.hintTextColor),
              helperText: 'Lower number = shown first. Leave empty to append at end.',
              helperStyle: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.hintTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              filled: true,
              fillColor: AppColors.backgroundColor,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitType,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          _editingId == null ? 'Add Type' : 'Update Type',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 20.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  side: const BorderSide(color: AppColors.secondaryTextColor),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_types.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.label_off_outlined,
              size: 80.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'No product types yet',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add your first type using the form',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.hintTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Hint bar ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          color: AppColors.primaryColor.withValues(alpha: 0.07),
          child: Row(
            children: [
              Icon(
                Icons.drag_indicator,
                size: 16.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                'Drag  ≡  to reorder — order is saved automatically',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.primaryColor,
                ),
              ),
              if (_isSavingOrder) ...[
                const Spacer(),
                SizedBox(
                  width: 14.w,
                  height: 14.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),

        // ── Reorderable list ──────────────────────────────
        Expanded(
          child: ReorderableListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: _types.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              setState(() {
                final item = _types.removeAt(oldIndex);
                _types.insert(newIndex, item);
              });
              _saveOrder();
            },
            proxyDecorator: (child, index, animation) => Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12.r),
              child: child,
            ),
            itemBuilder: (_, i) {
              final type = _types[i];
              return _TypeTile(
                key: ValueKey(type['id']),
                type: type,
                position: i + 1,
                onEdit: () => _startEdit(type),
                onDelete: () => _confirmDelete(type),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Product Types',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTypes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: !isWide && !_isFormVisible
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () => setState(() => _isFormVisible = true),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: isWide
          ? Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: _buildTypeList(),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: _buildForm(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _isFormVisible
          ? Padding(padding: EdgeInsets.all(16.w), child: _buildForm())
          : _buildTypeList(),
    );
  }
}

// ── Separate tile widget so position badge re-renders correctly ──────────────
class _TypeTile extends StatelessWidget {
  final Map<String, dynamic> type;
  final int position;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TypeTile({
    required super.key,
    required this.type,
    required this.position,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Icon(
              Icons.drag_indicator,
              color: Colors.grey.shade400,
              size: 22.sp,
            ),
          ),

          // Position badge
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                '$position',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Icon
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.label,
              color: AppColors.primaryColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Name
          Expanded(
            child: Text(
              type['name'] ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
          ),

          // Edit
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primaryColor,
              size: 20.sp,
            ),
            tooltip: 'Edit',
            onPressed: onEdit,
          ),

          // Delete
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.errorColor,
              size: 20.sp,
            ),
            tooltip: 'Delete',
            onPressed: onDelete,
          ),

          SizedBox(width: 12.w)
        ],
      ),
    );
  }
}
