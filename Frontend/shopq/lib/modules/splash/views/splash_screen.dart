import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../app/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    Timer(const Duration(seconds: 1), _checkLogin);
  }

  void _checkLogin() {
    final userEmail  = AppStorage.userEmail;
    final pincodeSet = AppStorage.pincodeCode.isNotEmpty || AppStorage.pincodeId > 0;

    if (userEmail.isNotEmpty) {
      Get.offAllNamed(pincodeSet ? AppRoutes.home : AppRoutes.location);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Image.asset('assets/images/logo.png',
            width: 180.w, height: 180.h),
      ),
    );
  }
}
