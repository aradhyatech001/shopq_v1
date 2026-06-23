import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

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
              child: Icon(Icons.delivery_dining_rounded,
                  color: Colors.white, size: 48.sp),
            ),
            SizedBox(height: 22.h),
            Text('ShopQ Delivery',
                style: GoogleFonts.jost(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 6.h),
            Text('Rider partner app',
                style: GoogleFonts.jost(color: Colors.white70, fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }
}
