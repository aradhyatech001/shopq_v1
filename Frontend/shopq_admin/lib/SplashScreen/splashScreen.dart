import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Auth/login_screen.dart';
import '../HomeScreen/home_screen.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/session_manager.dart';
import '../utils/admin_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    Timer(const Duration(milliseconds: 2200), _navigate);
  }

  Future<void> _navigate() async {
    final loggedIn = await _validateSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            loggedIn ? const HomeScreen() : const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  /// Validates the stored session against the server.
  /// Returns true only if the server confirms the session is active.
  Future<bool> _validateSession() async {
    final hasSession = await SessionManager.hasLocalSession();
    if (!hasSession) return false;

    try {
      await SessionManager.getSessionId();
      final res = await AdminApi.get(Uri.parse(ApiConstants.ADMIN_ME)).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true;
      }
      // Session expired or invalid — clear it
      await SessionManager.clearSession();
      return false;
    } catch (_) {
      // Network error: fall through to login so admin can retry
      await SessionManager.clearSession();
      return false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Animated logo ──────────────────────────────
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: AppColors.elevatedShadow,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 52.sp,
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Animated title ─────────────────────────────
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      'ShopQ',
                      style: GoogleFonts.jost(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Admin Panel',
                      style: GoogleFonts.jost(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryTextColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 60.h),

            // ── Loading indicator ──────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
