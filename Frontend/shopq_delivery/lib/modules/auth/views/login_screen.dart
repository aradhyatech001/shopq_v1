import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Enter your phone/email and password');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiClient.postJson(
        ApiConstants.LOGIN,
        body: {'login': _loginCtrl.text.trim(), 'password': _passCtrl.text},
      );
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        data = {};
      }
      if (data['success'] == true) {
        StorageService.saveSession(
          data['token'] ?? '',
          Map<String, dynamic>.from(data['rider'] ?? {}),
        );
        FcmHelper.syncAfterLogin();
        Get.offAllNamed(AppRoutes.home);
      } else {
        setState(() => _error = data['message'] ?? 'Login failed');
      }
    } catch (_) {
      setState(() => _error = 'Connection failed. Check your network.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 32.h),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 38.sp),
                  ),
                  SizedBox(height: 20.h),
                  Text('Welcome rider',
                      style: GoogleFonts.jost(fontSize: 24.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4.h),
                  Text('Sign in to see your deliveries',
                      style: GoogleFonts.jost(fontSize: 14.sp, color: AppColors.textSecondary)),
                  SizedBox(height: 28.h),
                  _label('Phone or email'),
                  TextField(
                    controller: _loginCtrl,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.jost(fontSize: 14.sp),
                    decoration: _deco('e.g. 9876543210', Icons.person_outline),
                  ),
                  SizedBox(height: 16.h),
                  _label('Password'),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    onSubmitted: (_) => _login(),
                    style: GoogleFonts.jost(fontSize: 14.sp),
                    decoration: _deco('••••••••', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.hint, size: 20.sp),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  if (_error.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(_error,
                            style: GoogleFonts.jost(color: AppColors.error, fontSize: 13.sp))),
                      ]),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  SizedBox(
                    height: 50.h,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? SizedBox(width: 20.w, height: 20.w,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Sign in',
                              style: GoogleFonts.jost(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('Your login is created by the store/admin.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.hint)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(t, style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w600)),
      );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.jost(color: AppColors.hint),
        prefixIcon: Icon(icon, color: AppColors.hint, size: 20.sp),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}
