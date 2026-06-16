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

  @override
  void initState() {
    super.initState();
    _load();
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

  // ── Add / edit form (side sheet) ───────────────────────────
  void _openForm({Map? existing}) {
    final isEdit = existing != null;
    final name = TextEditingController(text: existing?['name'] ?? '');
    final mobile = TextEditingController(text: existing?['mobile'] ?? '');
    final email = TextEditingController(text: existing?['email'] ?? '');
    final pin = TextEditingController(text: existing?['pin_code'] ?? '');
    final pass = TextEditingController();
    bool saving = false;

    showAdminSideSheet(
      context,
      child: StatefulBuilder(
        builder: (ctx, setS) => AdminSideSheet(
          title: isEdit ? 'Edit delivery boy' : 'Add delivery boy',
          subtitle: 'Platform fleet rider',
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.jost())),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (name.text.trim().isEmpty || mobile.text.trim().isEmpty ||
                          (!isEdit && pass.text.isEmpty)) {
                        _snack('Name, mobile and password are required', AppColors.warningColor);
                        return;
                      }
                      setS(() => saving = true);
                      try {
                        final body = <String, String>{
                          if (isEdit) 'id': existing['id'].toString(),
                          'name': name.text.trim(),
                          'mobile': mobile.text.trim(),
                          'email': email.text.trim(),
                          'pin_code': pin.text.trim(),
                          if (pass.text.isNotEmpty) 'password': pass.text,
                        };
                        final url = isEdit
                            ? ApiConstants.ADMIN_DELIVERY_BOYS_EDIT
                            : ApiConstants.ADMIN_DELIVERY_BOYS_ADD;
                        final res = await AdminApi.post(Uri.parse(url), body: body);
                        final data = jsonDecode(res.body);
                        if (data['success'] == true) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          _snack(isEdit ? 'Updated' : 'Added', AppColors.successColor);
                          _load();
                        } else {
                          _snack(data['message'] ?? 'Failed', AppColors.errorColor);
                        }
                      } catch (e) {
                        _snack('Error: $e', AppColors.errorColor);
                      } finally {
                        setS(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Save', style: GoogleFonts.jost(color: Colors.white)),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Name', required: true),
              _field(name, 'Full name'),
              SizedBox(height: 14.h),
              const FormLabel('Mobile', required: true),
              _field(mobile, '10-digit number', type: TextInputType.phone, maxLen: 10, digits: true),
              SizedBox(height: 14.h),
              const FormLabel('Email'),
              _field(email, 'email@example.com', type: TextInputType.emailAddress),
              SizedBox(height: 14.h),
              const FormLabel('Pincode'),
              _field(pin, '6-digit pincode', type: TextInputType.number, maxLen: 6, digits: true),
              SizedBox(height: 14.h),
              FormLabel(isEdit ? 'New password (optional)' : 'Password', required: !isEdit),
              _field(pass, isEdit ? 'Leave blank to keep' : 'Set a password', obscure: true),
            ],
          ),
        ),
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
        SizedBox(width: 6.w),
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add, size: 18),
          label: Text('Add', style: GoogleFonts.jost(fontWeight: FontWeight.w600)),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryColor),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _riders.isEmpty
              ? const EmptyState(icon: Icons.delivery_dining_outlined, message: 'No delivery boys yet', hint: 'Add one to the platform fleet')
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _riders.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) => _card(_riders[i]),
                ),
    );
  }

  Widget _card(Map r) {
    final active = (r['status'] ?? 'active').toString() == 'active';
    final platform = r['vendor_id'] == null;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
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
              onPressed: () => _openForm(existing: r),
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
