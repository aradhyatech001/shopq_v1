import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login_screen.dart';
import 'orders/orders_screen.dart';
import 'utils/colors.dart';
import 'utils/session_manager.dart';

void main() => runApp(const DeliveryApp());

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        title: 'DxMart Delivery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          textTheme: GoogleFonts.jostTextTheme(),
          useMaterial3: true,
        ),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const OrdersScreen(),
        },
        home: const _Splash(),
      ),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
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
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 48.sp),
            ),
            SizedBox(height: 22.h),
            Text('DxMart Delivery',
                style: GoogleFonts.jost(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 6.h),
            Text('Rider partner app',
                style: GoogleFonts.jost(color: Colors.white70, fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }
}
