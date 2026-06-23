import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/network/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _obscure2 = true;
  Uint8List? _logoBytes;
  String? _logoName;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 80,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoName = xFile.name;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      _showSnack('Passwords do not match');
      return;
    }
    setState(() => _loading = true);

    try {
      final body = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'shop_name': _shopCtrl.text.trim(),
        'shop_description': _descCtrl.text.trim(),
        'password': _passCtrl.text,
      };
      if (_logoBytes != null && _logoName != null) {
        body['logo_data'] = base64Encode(_logoBytes!);
        body['logo_name'] = _logoName!;
      }
      final res = await VendorApiHelper.postJson(ApiConstants.VENDOR_REGISTER, body: body);
      final data = res.data as Map<String, dynamic>;
      if (!mounted) return;

      if (data['success'] == true) {
        if (data['token'] != null) {
          SessionManager.saveSession(data['token'].toString(), Map<String, dynamic>.from(data['vendor'] as Map));
          if (!mounted) return;
          Get.offAllNamed(AppRoutes.home);
        } else {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: Text(
                'Registration Submitted',
                style: GoogleFonts.jost(fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Your account is pending admin approval. You can sign in once approved.',
                style: GoogleFonts.jost(fontSize: 13.sp),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (!mounted) return;
        _showSnack(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Network error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final controller in [
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _shopCtrl,
      _descCtrl,
      _passCtrl,
      _confirmCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.maxWidth(context);
    final isDesktop = Responsive.isDesktop(context);

    final formCard = Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 36.sp,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Create Vendor Account',
                    style: GoogleFonts.jost(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Get your shop online and manage orders from one dashboard.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jost(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5),
                  image: _logoBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_logoBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _logoBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.primary,
                            size: 26.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Upload logo',
                            style: GoogleFonts.jost(
                              color: AppColors.primary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            SizedBox(height: 22.h),
            _sectionTitle('Personal information'),
            SizedBox(height: 12.h),
            _field(_nameCtrl, 'Full name', Icons.person_outline, required: true),
            SizedBox(height: 14.h),
            _field(
              _emailCtrl,
              'Email address',
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: 14.h),
            _field(
              _phoneCtrl,
              'Phone number',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 22.h),
            _sectionTitle('Store details'),
            SizedBox(height: 12.h),
            _field(_shopCtrl, 'Shop name', Icons.storefront_rounded, required: true),
            SizedBox(height: 14.h),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: _inputDeco('Shop description (optional)', Icons.description_outlined),
            ),
            SizedBox(height: 22.h),
            _sectionTitle('Set password'),
            SizedBox(height: 12.h),
            _passwordField(
              _passCtrl,
              'Password',
              obscure: _obscure,
              toggle: () => setState(() => _obscure = !_obscure),
            ),
            SizedBox(height: 14.h),
            _passwordField(
              _confirmCtrl,
              'Confirm password',
              obscure: _obscure2,
              toggle: () => setState(() => _obscure2 = !_obscure2),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Create account'),
              ),
            ),
            SizedBox(height: 18.h),
            Center(
              child: Text(
                'Once approved by admin, you can log in and manage your store.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jost(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final sidePanel = Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join ShopQ',
            style: GoogleFonts.jost(
              fontSize: 16.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Start selling fast with a polished vendor dashboard',
            style: GoogleFonts.jost(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.05,
            ),
          ),
          SizedBox(height: 24.h),
          _featureTile('Submit store details once'),
          _featureTile('Add products quickly'),
          _featureTile('Enable live deliveries'),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: sidePanel),
                          SizedBox(width: 28.w),
                          Expanded(child: formCard),
                        ],
                      )
                    : Column(
                        children: [
                          sidePanel,
                          SizedBox(height: 24.h),
                          formCard,
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String label) {
    return Text(
      label,
      style: GoogleFonts.jost(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: _inputDeco(label, icon).copyWith(counterText: ''),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null),
    );
  }

  Widget _passwordField(
    TextEditingController ctrl,
    String label, {
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: (value) =>
          value == null || value.length < 6 ? 'Min 6 characters' : null,
      decoration: _inputDeco(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.hintTextColor,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.hintTextColor),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }

  Widget _featureTile(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.jost(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
