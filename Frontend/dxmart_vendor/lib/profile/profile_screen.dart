import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/login_screen.dart';
import '../subscription/subscription_screen.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/vendor_api_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map?    _vendor;
  Map?    _subscription;
  bool    _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res  = await VendorApiHelper.get(ApiConstants.VENDOR_PROFILE);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _vendor       = data['vendor'];
          _subscription = _vendor?['active_subscription'];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await VendorApiHelper.post(ApiConstants.VENDOR_LOGOUT);
    } catch (_) {}
    await VendorApiHelper.clearSession();
    if (mounted) _goLogin();
  }

  void _goLogin() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );

  void _editProfile() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProfileSheet(vendor: _vendor!, onSaved: _load),
  );

  void _changePassword() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ChangePasswordSheet(),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final logoUrl = _vendor?['logo']?.toString() ?? '';
    final status  = _vendor?['status'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile banner ─────────────────────────────────
            Container(
              color: AppColors.surface,
              child: Column(
                children: [
                  // Top actions row
                  Padding(
                    padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: Text(
                            'Profile',
                            style: GoogleFonts.jost(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh_rounded,
                                  color: AppColors.textSecondary),
                            ),
                            IconButton(
                              onPressed: _editProfile,
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.primary),
                              tooltip: 'Edit Profile',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Avatar + info
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 72.w, height: 72.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.borderColor, width: 2),
                          ),
                          child: logoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultAvatar(),
                                  ),
                                )
                              : _defaultAvatar(),
                        ),
                        SizedBox(width: 16.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _vendor?['name'] ?? '',
                                style: GoogleFonts.jost(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp),
                              ),
                              if ((_vendor?['shop_name'] ?? '').isNotEmpty)
                                Text(
                                  _vendor!['shop_name'],
                                  style: GoogleFonts.jost(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary),
                                ),
                              SizedBox(height: 6.h),
                              _statusBadge(status),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats row
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 12.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                          top: BorderSide(color: AppColors.borderColor)),
                    ),
                    child: Row(
                      children: [
                        _statItem(
                          Icons.email_outlined,
                          'Email',
                          _vendor?['email'] ?? '-',
                        ),
                        Container(
                            width: 1, height: 32.h,
                            color: AppColors.borderColor),
                        _statItem(
                          Icons.phone_outlined,
                          'Phone',
                          (_vendor?['phone']?.toString().isNotEmpty == true)
                              ? _vendor!['phone']
                              : 'Not set',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Subscription section ───────────────────────────
            _sectionCard([
              _tile(
                icon: _subscription != null
                    ? Icons.card_membership_rounded
                    : Icons.warning_amber_rounded,
                title: _subscription != null
                    ? '${_subscription!['plan_name']} Plan'
                    : 'No Active Subscription',
                subtitle: _subscription != null
                    ? '${_subscription!['days_remaining']} days remaining · expires ${_subscription!['end_date']}'
                    : 'Subscribe to start accepting orders',
                iconColor: _subscription != null
                    ? AppColors.primary
                    : AppColors.warning,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen()),
                ),
              ),
            ]),

            SizedBox(height: 8.h),

            // ── Shop info ──────────────────────────────────────
            _sectionHeader('Shop Information'),
            _sectionCard([
              _tile(
                icon: Icons.store_outlined,
                title: 'Shop Name',
                subtitle: _vendor?['shop_name']?.toString().isNotEmpty == true
                    ? _vendor!['shop_name']
                    : 'Not set',
              ),
              _tile(
                icon: Icons.description_outlined,
                title: 'Description',
                subtitle: _vendor?['shop_description']?.toString().isNotEmpty == true
                    ? _vendor!['shop_description']
                    : 'Not set',
              ),
            ]),

            SizedBox(height: 8.h),

            // ── Account actions ────────────────────────────────
            _sectionHeader('Account'),
            _sectionCard([
              _tile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                iconColor: AppColors.primary,
                onTap: _changePassword,
              ),
              _tile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: AppColors.error,
                textColor: AppColors.error,
                onTap: _confirmLogout,
              ),
            ]),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() => Icon(
    Icons.store_rounded,
    color: AppColors.primary,
    size: 30.sp,
  );

  Widget _statusBadge(String status) {
    Color c;
    switch (status) {
      case 'approved':  c = AppColors.success; break;
      case 'pending':   c = AppColors.warning; break;
      case 'suspended': c = AppColors.error;   break;
      default:          c = AppColors.hint;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.jost(
            fontSize: 10.sp, color: c, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) => Expanded(
    child: Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.jost(
                      fontSize: 10.sp, color: AppColors.textSecondary)),
              Text(
                value,
                style: GoogleFonts.jost(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionHeader(String t) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 6.h),
    child: Text(
      t.toUpperCase(),
      style: GoogleFonts.jost(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8),
    ),
  );

  Widget _sectionCard(List<Widget> children) => Container(
    color: AppColors.surface,
    child: Column(children: children),
  );

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color iconColor = AppColors.textSecondary,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
          child: Row(
            children: [
              Container(
                width: 38.w, height: 38.w,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.jost(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? AppColors.textPrimary),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.jost(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.hint, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r)),
        title:
            Text('Logout?', style: GoogleFonts.jost(fontWeight: FontWeight.w700)),
        content: Text('You will be signed out of your vendor account.',
            style: GoogleFonts.jost(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.jost()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () { Navigator.pop(context); _logout(); },
            child: Text('Logout', style: GoogleFonts.jost()),
          ),
        ],
      ),
    );
  }
}

// ── Edit Profile sheet ────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final Map vendor;
  final VoidCallback onSaved;

  const _EditProfileSheet(
      {required this.vendor, required this.onSaved});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _shopDescCtrl;
  bool _saving = false;
  Uint8List? _logoBytes;
  String?   _logoName;

  @override
  void initState() {
    super.initState();
    _nameCtrl     = TextEditingController(text: widget.vendor['name'] ?? '');
    _phoneCtrl    = TextEditingController(text: widget.vendor['phone']?.toString() ?? '');
    _shopNameCtrl = TextEditingController(text: widget.vendor['shop_name'] ?? '');
    _shopDescCtrl = TextEditingController(text: widget.vendor['shop_description'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _shopNameCtrl.dispose(); _shopDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final xFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 400, imageQuality: 80);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() { _logoBytes = bytes; _logoName = xFile.name; });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'name':             _nameCtrl.text.trim(),
        'phone':            _phoneCtrl.text.trim(),
        'shop_name':        _shopNameCtrl.text.trim(),
        'shop_description': _shopDescCtrl.text.trim(),
        if (_logoBytes != null && _logoName != null) ...{
          'logo_data': base64Encode(_logoBytes!),
          'logo_name': _logoName,
        },
      };
      final res  = await VendorApiHelper.postJson(ApiConstants.VENDOR_PROFILE_UPDATE, body: body);
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (data['success'] == true) {
        widget.onSaved();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Update failed',
              style: GoogleFonts.jost()),
          backgroundColor: AppColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e', style: GoogleFonts.jost()),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jost(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w, right: 20.w, top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 16.h),
            Text('Edit Profile',
                style: GoogleFonts.jost(
                    fontWeight: FontWeight.w700, fontSize: 18.sp)),
            SizedBox(height: 20.h),

            // Logo picker
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: 72.w, height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderColor, width: 1.5),
                  image: _logoBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_logoBytes!), fit: BoxFit.cover)
                      : null,
                ),
                child: _logoBytes == null
                    ? Icon(Icons.add_a_photo_outlined,
                        color: AppColors.primary, size: 22.sp)
                    : null,
              ),
            ),
            SizedBox(height: 16.h),

            // Fields
            TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.jost(),
                decoration: _deco('Full Name')),
            SizedBox(height: 12.h),
            TextFormField(
                controller: _phoneCtrl,
                style: GoogleFonts.jost(),
                keyboardType: TextInputType.phone,
                decoration: _deco('Phone')),
            SizedBox(height: 12.h),
            TextFormField(
                controller: _shopNameCtrl,
                style: GoogleFonts.jost(),
                decoration: _deco('Shop Name')),
            SizedBox(height: 12.h),
            TextFormField(
                controller: _shopDescCtrl,
                style: GoogleFonts.jost(),
                maxLines: 2,
                decoration: _deco('Shop Description')),
            SizedBox(height: 20.h),

            // Save
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: _saving
                    ? SizedBox(
                        width: 20.w, height: 20.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Save Changes',
                        style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Change Password sheet ─────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving       = false;
  bool _obscureCur   = true;
  bool _obscureNew   = true;
  bool _obscureCon   = true;

  @override
  void dispose() {
    _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cur = _currentCtrl.text.trim();
    final nw  = _newCtrl.text.trim();
    final con = _confirmCtrl.text.trim();
    if (cur.isEmpty || nw.isEmpty || con.isEmpty) {
      _snack('All fields are required'); return;
    }
    if (nw != con) { _snack('New passwords do not match'); return; }
    if (nw.length < 6) { _snack('Password must be at least 6 characters'); return; }

    setState(() => _saving = true);
    try {
      final res = await VendorApiHelper.postJson(ApiConstants.VENDOR_CHANGE_PASSWORD, body: {
        'current_password': cur,
        'password': nw,
        'password_confirmation': con,
      });
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (data['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password updated', style: GoogleFonts.jost()),
          backgroundColor: AppColors.success,
        ));
      } else {
        _snack(data['message'] ?? 'Failed');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.jost()),
          backgroundColor: AppColors.error));

  InputDecoration _deco(String label,
      {bool obscure = false, VoidCallback? toggleObscure}) =>
      InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jost(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.hint, size: 18.sp),
                onPressed: toggleObscure)
            : null,
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
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w, right: 20.w, top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
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
          Text('Change Password',
              style: GoogleFonts.jost(
                  fontWeight: FontWeight.w700, fontSize: 18.sp)),
          SizedBox(height: 20.h),

          TextField(
            controller: _currentCtrl,
            obscureText: _obscureCur,
            style: GoogleFonts.jost(),
            decoration: _deco('Current Password',
                obscure: _obscureCur,
                toggleObscure: () =>
                    setState(() => _obscureCur = !_obscureCur)),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _newCtrl,
            obscureText: _obscureNew,
            style: GoogleFonts.jost(),
            decoration: _deco('New Password',
                obscure: _obscureNew,
                toggleObscure: () =>
                    setState(() => _obscureNew = !_obscureNew)),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureCon,
            style: GoogleFonts.jost(),
            decoration: _deco('Confirm New Password',
                obscure: _obscureCon,
                toggleObscure: () =>
                    setState(() => _obscureCon = !_obscureCon)),
          ),
          SizedBox(height: 20.h),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: _saving
                  ? SizedBox(
                      width: 20.w, height: 20.w,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Update Password',
                      style: GoogleFonts.jost(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
