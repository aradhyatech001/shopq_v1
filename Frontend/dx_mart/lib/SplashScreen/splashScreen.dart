import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:shared_preferences/shared_preferences.dart';


import '../Auth/loginScreen.dart';
import '../BottomNav/bottomNavScreen.dart';
import '../LocationScreen/locationScreen.dart';
import '../utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // Status Bar & Navigation Bar Settings
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));



    Timer(Duration (seconds: 1), (){
      //
      checkLogin();

    });

  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userEmail = prefs.getString('user_email');
    // The pincode is what LocationScreen persists; reuse it so we never
    // re-ask once the user has picked one.
    String? pincode = prefs.getString('pincode_code') ?? prefs.getString('pincode_id');

    if (!mounted) return;

    if (userEmail != null) {
      // ✅ User is logged in
      if (pincode == null || pincode.isEmpty) {
        // 🔁 Pincode not selected yet
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LocationScreen()),
        );
      } else {
        // ✅ Pincode already stored — go straight to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavScreen()),
        );
      }
    } else {
      // 🔴 User not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset('assets/images/shopq_logo.jpeg',
              width: 180.w,height: 180.h,),


          ],
        ),
      ),
    );
  }
}
