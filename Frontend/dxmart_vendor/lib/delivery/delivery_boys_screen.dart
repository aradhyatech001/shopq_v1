import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/vendor_api_helper.dart';
import '../utils/vendor_widgets.dart';

/// Vendor's own delivery riders — master-detail split (list left, add/edit form
/// right on wide screens; a full page on phones). Riders are created here and
/// just log into the delivery app. They can also be assigned to orders.
class DeliveryBoysScreen extends StatefulWidget {
  const DeliveryBoysScreen({super.key});

  @override
  State<DeliveryBoysScreen> createState() => _DeliveryBoysScreenState();
}

class _DeliveryBoysScreenState extends State<DeliveryBoysScreen> {
  List _riders = [];
  bool _loading = true;

  bool _formOpen = false;
  Map? _formRider; // null = adding

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await VendorApiHelper.get(ApiConstants.VENDOR_DELIVERY_BOYS_MINE);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) _riders = data['data'] ?? [];
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.jost()), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _delete(dynamic id) async {
    try {
      final res = await VendorApiHelper.postJson(ApiConstants.VENDOR_DELIVERY_BOYS_DELETE, body: {'id': id});
      final data = jsonDecode(res.body);
      _toast(data['message'] ?? 'Done');
      if (data['success'] == true) {
        if (_formRider != null && _formRider!['id'] == id) _closePanel();
        _load();
      }
    } catch (_) {
      _toast('Something went wrong');
    }
  }

  void _confirmDelete(Map r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: Text('Remove rider', style: GoogleFonts.jost(fontWeight: FontWeight.w700)),
        content: Text('Remove "${r['name']}" from your riders?', style: GoogleFonts.jost(fontSize: 14.sp)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.jost())),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () { Navigator.pop(ctx); _delete(r['id']); },
            child: Text('Remove', style: GoogleFonts.jost(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(Map r) async {
    final next = (r['status'] ?? 'active').toString() == 'active' ? 'inactive' : 'active';
    try {
      await VendorApiHelper.postJson(ApiConstants.VENDOR_DELIVERY_BOYS_EDIT, body: {'id': r['id'], 'status': next});
      _load();
    } catch (_) {}
  }

  void _openForm({Map? existing}) {
    final wide = MediaQuery.of(context).size.width >= 900;
    if (wide) {
      setState(() {
        _formOpen = true;
        _formRider = existing;
      });
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: _RiderForm(
              existing: existing,
              onSaved: _load,
              onClose: () => Navigator.pop(context),
            ),
          ),
        ),
      ));
    }
  }

  void _closePanel() => setState(() {
        _formOpen = false;
        _formRider = null;
      });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return VendorPage(
      title: 'Delivery Boys',
      subtitle: '${_riders.length} of your riders',
      actions: [
        IconButton(onPressed: _load, icon: Icon(Icons.refresh_rounded, size: 20.sp, color: AppColors.textSecondary)),
        IconButton(onPressed: () => _openForm(), icon: Icon(Icons.add_circle, size: 24.sp, color: AppColors.primary)),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : wide
              ? _splitView()
              : _listView(),
    );
  }

  Widget _listView() {
    if (_riders.isEmpty) {
      return const VEmpty(
        icon: Icons.delivery_dining_outlined,
        message: 'No riders yet',
        hint: 'Add your own, or assign from the platform pool',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _riders.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => _card(_riders[i]),
      ),
    );
  }

  Widget _splitView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 4, child: _listView()),
        const VerticalDivider(width: 1, color: AppColors.borderColor),
        Expanded(
          flex: 5,
          child: _formOpen
              ? _RiderForm(
                  key: ValueKey(_formRider?['id'] ?? 'new'),
                  existing: _formRider,
                  onSaved: _load,
                  onClose: _closePanel,
                )
              : const VEmpty(
                  icon: Icons.delivery_dining_outlined,
                  message: 'Select a rider to edit',
                  hint: 'or tap + to add a new one'),
        ),
      ],
    );
  }

  Widget _card(Map r) {
    final active = (r['status'] ?? 'active').toString() == 'active';
    final selected = _formOpen && _formRider != null && _formRider!['id'] == r['id'];
    return GestureDetector(
      onTap: () => _openForm(existing: r),
      child: Container(
        decoration: selected
            ? BoxDecoration(borderRadius: BorderRadius.circular(14.r), border: Border.all(color: AppColors.primary, width: 1.5))
            : null,
        padding: selected ? EdgeInsets.all(2.w) : EdgeInsets.zero,
        child: VCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name'] ?? '', style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2.h),
                    Text('${r['mobile'] ?? ''}${(r['pin_code'] ?? '').toString().isNotEmpty ? '  ·  ${r['pin_code']}' : ''}',
                        style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: active,
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => _toggle(r),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20.sp, color: AppColors.textSecondary),
                onSelected: (v) {
                  if (v == 'edit') _openForm(existing: r);
                  if (v == 'delete') _confirmDelete(r);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [
                    const Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 8.w),
                    Text('Edit', style: GoogleFonts.jost()),
                  ])),
                  PopupMenuItem(value: 'delete', child: Row(children: [
                    Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    SizedBox(width: 8.w),
                    Text('Delete', style: GoogleFonts.jost(color: AppColors.error)),
                  ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / edit rider form — used in the right panel (wide) or a pushed page (narrow).
// ─────────────────────────────────────────────────────────────────────────────
class _RiderForm extends StatefulWidget {
  final Map? existing;
  final VoidCallback onSaved;
  final VoidCallback? onClose;

  const _RiderForm({super.key, this.existing, required this.onSaved, this.onClose});

  @override
  State<_RiderForm> createState() => _RiderFormState();
}

class _RiderFormState extends State<_RiderForm> {
  late final TextEditingController _name, _mobile, _email, _pin, _pass;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?['name'] ?? '');
    _mobile = TextEditingController(text: e?['mobile'] ?? '');
    _email = TextEditingController(text: e?['email'] ?? '');
    _pin = TextEditingController(text: e?['pin_code'] ?? '');
    _pass = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _pin.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.jost()), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _mobile.text.trim().isEmpty || (!_isEdit && _pass.text.isEmpty)) {
      _toast('Name, mobile and password are required');
      return;
    }
    setState(() => _saving = true);
    try {
      final res = await VendorApiHelper.postJson(
        _isEdit ? ApiConstants.VENDOR_DELIVERY_BOYS_EDIT : ApiConstants.VENDOR_DELIVERY_BOYS_ADD,
        body: {
          if (_isEdit) 'id': widget.existing!['id'],
          'name': _name.text.trim(),
          'mobile': _mobile.text.trim(),
          'email': _email.text.trim(),
          'pin_code': _pin.text.trim(),
          if (_pass.text.isNotEmpty) 'password': _pass.text,
        },
      );
      final data = jsonDecode(res.body);
      _toast(data['message'] ?? 'Done');
      if (data['success'] == true) {
        widget.onSaved();
        widget.onClose?.call();
      }
    } catch (_) {
      _toast('Something went wrong');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 10.w, 14.h),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_isEdit ? 'Edit delivery boy' : 'Add delivery boy',
                      style: GoogleFonts.jost(fontWeight: FontWeight.w800, fontSize: 17.sp)),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 20.sp, color: AppColors.textSecondary),
                  onPressed: () => widget.onClose?.call(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _field(_name, 'Name'),
                      SizedBox(height: 12.h),
                      _field(_mobile, 'Mobile (10 digits)', type: TextInputType.phone, maxLen: 10, digits: true),
                      SizedBox(height: 12.h),
                      _field(_email, 'Email (optional)', type: TextInputType.emailAddress),
                      SizedBox(height: 12.h),
                      _field(_pin, 'Pincode (optional)', type: TextInputType.number, maxLen: 6, digits: true),
                      SizedBox(height: 12.h),
                      _field(_pass, _isEdit ? 'New password (leave blank to keep)' : 'Password', obscure: true),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: 14.h)),
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_isEdit ? 'Save changes' : 'Add rider',
                                  style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
        hintStyle: GoogleFonts.jost(color: AppColors.hint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
