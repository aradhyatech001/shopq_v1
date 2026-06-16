import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'utils/app_theme.dart';
import 'utils/colors.dart';
import 'utils/session_manager.dart';

void main() {
  runApp(const VendorApp());
}

class VendorApp extends StatelessWidget {
  const VendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The vendor app runs on both phones and the web/desktop. ScreenUtil scales
    // every .w/.h/.sp by (screenWidth / designWidth); a phone design size on a
    // ~1366px desktop blows everything up ~3.5×. Pick the design size to match
    // the form factor so 1 logical unit ≈ 1 px on each.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final Size design = w >= 1100
            ? const Size(1366, 768)   // desktop (matches the admin panel)
            : w >= 600
                ? const Size(834, 1112) // tablet
                : const Size(390, 844); // phone
        return ScreenUtilInit(
          designSize: design,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            title: 'DxMart Vendor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routes: {
              '/home': (_) => const HomeScreen(),
              '/login': (_) => const LoginScreen(),
            },
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final loggedIn = await SessionManager.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 44.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'DxMart Vendor',
              style: GoogleFonts.jost(
                color: Colors.white,
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Seller dashboard for web and mobile',
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
