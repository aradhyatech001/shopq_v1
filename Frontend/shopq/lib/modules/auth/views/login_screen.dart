
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

import '../../../core/storage/storage_service.dart';

import '../widgets/customButton.dart';
import '../widgets/customTextFiledWidgets.dart';
import '../widgets/custom_text.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? validateFields() {
    if (emailController.text.trim().isEmpty) {
      return "Please Enter Email";
    }
    if (passwordController.text.trim().isEmpty) {
      return "Please Enter Password";
    }

    return null;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.jost()),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiHelper.post(ApiConstants.LOGIN, body: {"email": emailController.text, "password": passwordController.text});

      final data = jsonDecode(response.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data["message"] ?? "Something went wrong",
            style: GoogleFonts.jost(color: AppColors.primaryTextColor),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: data["status"] == "success"
              ? AppColors.primaryColor
              : Colors.redAccent,
        ),
      );

      if (data["status"] == "success") {
        AppStorage.userEmail = emailController.text;
        if (data['token'] != null) {
          AppStorage.token = data['token'].toString();
          FcmHelper.syncAfterLogin();
        }
        if (data['user'] != null) {
          AppStorage.userId   = data['user']['id']?.toString() ?? '';
          AppStorage.userName = data['user']['name']?.toString() ?? '';
        }

        emailController.clear();
        passwordController.clear();
        if (!mounted) return;
        final pincodeSet = AppStorage.pincodeCode.isNotEmpty || AppStorage.pincodeId > 0;
        Get.offAllNamed(pincodeSet ? AppRoutes.home : AppRoutes.location);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void handleSubmit() {
    final error = validateFields();
    if (error != null) {
      showError(error);
    } else {
      login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 80.h),

            Image.asset('assets/images/logo.png', width: 180.w, height: 110.h),

            SizedBox(height: 40.h),

            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: "Email Address", fontSize: 12.sp),
                  SizedBox(height: 7.h),

                  CustomTextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    preFixIcon: 'assets/svg/email.svg',
                    hintText: "example@gmail.com",
                  ),

                  SizedBox(height: 17.h),
                  CustomText(text: "Password", fontSize: 12.sp),

                  SizedBox(height: 7.h),

                  CustomTextField(
                    controller: passwordController,
                    hintText: "********",
                    keyboardType: TextInputType.text,
                    preFixIcon: 'assets/svg/password.svg',
                    isObscure: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  CustomButton(
                    text: 'Login',
                    onPressed: () {
                      handleSubmit();
                    },
                  ),

                  SizedBox(height: 10.h),

                  Center(
                    child: InkWell(
                      child: CustomText(
                        text: "Forget Password",
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                      onTap: () {
                        Get.toNamed(AppRoutes.forgotPassword);
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Don’t have an account?',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: AppColors.primaryTextColor,
                  ),
                ),

                SizedBox(width: 6.w),
                InkWell(
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.signup);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}