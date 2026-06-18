import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

/// Admin management of the platform delivery fleet. Lists every rider
/// (platform-owned and vendor-owned) and lets the admin add/edit/remove the
/// platform pool (vendor_id = null).
class DeliveryBoysScreen extends StatefulWidget {
  const DeliveryBoysScreen({super.key});

  @override
  State<DeliveryBoysScreen> createState() => _DeliveryBoysScreenState();
}

class _DeliveryBoysScreenState extends State<DeliveryBoysScreen> {
  List _riders = [];
  bool _loading = true;

  // Right-panel Add/Edit form (split layout).
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  Map? _editing; // null = Add mode
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _pinCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.ADMIN_DELIVERY_BOYS));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) _riders = data['data'] ?? [];
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.jost(color: Colors.white)), backgroundColor: c),
    );
  }

  Future<void> _delete(dynamic id) async {
    final ok = await confirmDelete(context,
        title: 'Remove rider', message: 'This delivery boy will be removed.');
    if (!ok) return;
    try {
      final res = await AdminApi.post(Uri.parse(ApiConstants.ADMIN_DELIVERY_BOYS_DELETE),
          body: {'id': id.toString()});
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Removed', AppColors.successColor);
        _load();
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    }
  }

  Future<void> _toggleStatus(Map r) async {
    final next = (r['status'] ?? 'active').toString() == 'active' ? 'inactive' : 'active';
    try {
      await AdminApi.post(Uri.parse(ApiConstants.ADMIN_DELIVERY_BOYS_EDIT),
          body: {'id': r['id'].toString(), 'status': next});
      _load();
    } catch (_) {}
  }

  // ── Add / edit form (right split panel) ────────────────────
  // Loads a rider into the right panel for editing (no side sheet).
  void _startEdit(Map r) {
    setState(() {
      _editing = r;
      _nameCtrl.text = r['name']?.toString() ?? '';
      _mobileCtrl.text = r['mobile']?.toString() ?? '';
      _emailCtrl.text = r['email']?.toString() ?? '';
      _pinCtrl.text = r['pin_code']?.toString() ?? '';
      _passCtrl.clear();
    });
  }

  void _resetForm() {
    setState(() {
      _editing = null;
      _nameCtrl.clear();
      _mobileCtrl.clear();
      _emailCtrl.clear();
      _pinCtrl.clear();
      _passCtrl.clear();
    });
  }

  // Add (no editing) or update (editing) — one right panel does both.
  Future<void> _save() async {
    final isEdit = _editing != null;
    if (_nameCtrl.text.trim().isEmpty || _mobileCtrl.text.trim().isEmpty ||
        (!isEdit && _passCtrl.text.isEmpty)) {
      _snack('Name, mobile and password are required', AppColors.warningColor);
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, String>{
        if (isEdit) 'id': _editing!['id'].toString(),
        'name': _nameCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'pin_code': _pinCtrl.text.trim(),
        if (_passCtrl.text.isNotEmpty) 'password': _passCtrl.text,
      };
      final url = isEdit
          ? ApiConstants.ADMIN_DELIVERY_BOYS_EDIT
          : ApiConstants.ADMIN_DELIVERY_BOYS_ADD;
      final res = await AdminApi.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack(isEdit ? 'Updated' : 'Added', AppColors.successColor);
        _resetForm();
        _load();
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildForm() {
    final editing = _editing != null;
    return SectionCard(
      title: editing ? 'Edit delivery boy' : 'Add delivery boy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormLabel('Name', required: true),
          _field(_nameCtrl, 'Full name'),
          SizedBox(height: 14.h),
          const FormLabel('Mobile', required: true),
          _field(_mobileCtrl, '10-digit number', type: TextInputType.phone, maxLen: 10, digits: true),
          SizedBox(height: 14.h),
          const FormLabel('Email'),
          _field(_emailCtrl, 'email@example.com', type: TextInputType.emailAddress),
          SizedBox(height: 14.h),
          const FormLabel('Pincode'),
          _field(_pinCtrl, '6-digit pincode', type: TextInputType.number, maxLen: 6, digits: true),
          SizedBox(height: 14.h),
          FormLabel(editing ? 'New password (optional)' : 'Password', required: !editing),
          _field(_passCtrl, editing ? 'Leave blank to keep' : 'Set a password', obscure: true),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _save,
                        child: Text(editing ? 'Save' : 'Add',
                            style: GoogleFonts.jost(fontWeight: FontWeight.w600)),
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

  Widget _field(TextEditingController c, String hint,
      {TextInputType type = TextInputType.text, bool obscure = false, int? maxLen, bool digits = false}) {
    return TextField(
      controller: c,
      keyboardType: type,
      obscureText: obscure,
      maxLength: maxLen,
      inputFormatters: digits ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: GoogleFonts.jost(fontSize: 14.sp),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: GoogleFonts.jost(color: AppColors.hintTextColor),
        filled: true,
        fillColor: AppColors.backgroundColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Delivery Boys',
      subtitle: '${_riders.length} riders',
      actions: [
        IconButton(onPressed: _load, icon: Icon(Icons.refresh_rounded, color: AppColors.secondaryTextColor, size: 20.sp)),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left: rider list ──
                Expanded(
                  flex: 3,
                  child: _riders.isEmpty
                      ? const EmptyState(icon: Icons.delivery_dining_outlined, message: 'No delivery boys yet', hint: 'Add one using the form')
                      : ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _riders.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) => _card(_riders[i]),
                        ),
                ),
                const VerticalDivider(width: 1),
                // ── Right: add/edit form ──
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

  Widget _card(Map r) {
    final active = (r['status'] ?? 'active').toString() == 'active';
    final platform = r['vendor_id'] == null;
    final selected = _editing != null && _editing!['id'] == r['id'];
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryLight : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: selected ? AppColors.primaryColor : AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.delivery_dining_rounded, color: AppColors.primaryColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(child: Text(r['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w700))),
                  SizedBox(width: 8.w),
                  StatusBadge(
                    label: platform ? 'Platform' : 'Vendor #${r['vendor_id']}',
                    color: platform ? AppColors.primaryColor : AppColors.cardPurple,
                  ),
                ]),
                SizedBox(height: 2.h),
                Text('${r['mobile'] ?? ''}${(r['pin_code'] ?? '').toString().isNotEmpty ? '  ·  ${r['pin_code']}' : ''}',
                    style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.secondaryTextColor)),
              ],
            ),
          ),
          // Active toggle (platform riders only — vendor owns theirs)
          if (platform) ...[
            Switch(
              value: active,
              activeColor: AppColors.primaryColor,
              onChanged: (_) => _toggleStatus(r),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.primaryColor, size: 18.sp),
              onPressed: () => _startEdit(r),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.errorColor, size: 18.sp),
              onPressed: () => _delete(r['id']),
            ),
          ] else
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: StatusBadge(
                label: active ? 'Active' : 'Inactive',
                color: active ? AppColors.successColor : AppColors.errorColor,
              ),
            ),
        ],
      ),
    );
  }
}
