import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/admin_api.dart';

import '../HomeScreen/home_screen.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _error = '';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await SessionManager.getSavedCredentials();
    if (creds.isNotEmpty && mounted) {
      setState(() {
        _rememberMe = true;
        _emailCtrl.text = creds['email'] ?? '';
        _passwordCtrl.text = creds['password'] ?? '';
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.LOGIN),
        body: {
          'email': _emailCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          // Save the Sanctum bearer token (sent as Authorization header by AdminApi)
          await SessionManager.saveSession(
            sessionId: data['token'] ?? '',
            email: data['user']['email'] ?? '',
            name: data['user']['name'] ?? '',
          );
          if (_rememberMe) {
            await SessionManager.saveRememberMe(
              _emailCtrl.text.trim(),
              _passwordCtrl.text.trim(),
            );
          } else {
            await SessionManager.clearRememberMe();
          }
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 350),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else {
          if (mounted)
            setState(() => _error = data['message'] ?? 'Login failed');
        }
      } else {
        if (mounted)
          setState(() => _error = 'Server error (${res.statusCode})');
      }
    } catch (e) {
      if (mounted)
        setState(() => _error = 'Connection failed. Check your network.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Row(
        children: [
          // ── Left branding panel ─────────────────────────
          _buildBrandPanel(),

          // ── Right login form ────────────────────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _buildForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Left brand panel ──────────────────────────────────────
  Widget _buildBrandPanel() {
    return Container(
      width: 420.w,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 44.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'DxMart',
            style: GoogleFonts.jost(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Admin Panel',
            style: GoogleFonts.jost(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 48.h),
          _buildFeatureBullet(Icons.speed_rounded, 'Real-time Dashboard'),
          SizedBox(height: 14.h),
          _buildFeatureBullet(
            Icons.inventory_2_rounded,
            'Product & Stock Management',
          ),
          SizedBox(height: 14.h),
          _buildFeatureBullet(Icons.receipt_long_rounded, 'Order Tracking'),
          SizedBox(height: 14.h),
          _buildFeatureBullet(Icons.people_rounded, 'User Management'),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: GoogleFonts.jost(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Login form ────────────────────────────────────────────
  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(36.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back',
              style: GoogleFonts.jost(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Sign in to your admin account',
              style: GoogleFonts.jost(
                fontSize: 14.sp,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 32.h),

            // Email
            _label('Email Address'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.jost(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'admin@dxmart.com',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.hintTextColor,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // Password
            _label('Password'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: GoogleFonts.jost(fontSize: 14.sp),
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.hintTextColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.hintTextColor,
                    size: 20.sp,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 4) return 'Password too short';
                return null;
              },
            ),
            SizedBox(height: 14.h),

            // Remember me
            Row(
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    activeColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    side: const BorderSide(color: AppColors.borderColor),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Remember me',
                  style: GoogleFonts.jost(
                    fontSize: 13.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Error banner
            if (_error.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.errorColor,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _error,
                        style: GoogleFonts.jost(
                          color: AppColors.errorColor,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Login button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: GoogleFonts.jost(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 24.h),
            Center(
              child: Text(
                '© 2025 DxMart. All rights reserved.',
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  color: AppColors.hintTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.jost(
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColor,
    ),
  );
}
