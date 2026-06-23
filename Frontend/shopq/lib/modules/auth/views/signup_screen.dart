import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

import '../../../core/storage/storage_service.dart';

import '../widgets/customButton.dart';
import '../widgets/customTextFiledWidgets.dart';
import '../widgets/custom_text.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../app/theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? validateFields() {
    if (nameController.text.trim().isEmpty) {
      return "Please Enter Name";
    }
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

  Future<void> signup() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiHelper.post(ApiConstants.SIGNUP, body: {"name": nameController.text, "email": emailController.text, "password": passwordController.text, "date_time": DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())});

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        if (mounted) {
          _showSnackBar('Server error (${response.statusCode}). Try again.');
        }
        return;
      }

      final msg = data["message"]?.toString() ?? "Something went wrong";
      final isSuccess = data["status"] == "success";

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 3),
          backgroundColor: isSuccess
              ? AppColors.primaryColor
              : Colors.redAccent,
        ),
      );

      if (isSuccess) {
        // Signup doesn't issue a token — auto-login to get one
        await _autoLogin(emailController.text, passwordController.text);
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      if (mounted) _showSnackBar('Connection failed. Check your network.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Auto-login after successful signup to obtain a Sanctum token.
  /// The signup endpoint only creates the account; it does NOT issue a token.
  Future<void> _autoLogin(String email, String password) async {
    try {
      final response = await ApiHelper.post(ApiConstants.LOGIN, body: {"email": email, "password": password});
      final data = jsonDecode(response.body);
      if (data["status"] == "success") {
        AppStorage.userEmail = email;
        if (data['token'] != null) {
          ApiHelper.saveToken(data['token'].toString());
        }
        if (data['user'] != null) {
          AppStorage.userId = data['user']['id']?.toString() ?? '';
          AppStorage.userName = data['user']['name']?.toString() ?? '';
        }
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        if (!mounted) return;
        Get.offAllNamed(AppRoutes.location);
      } else {
        // Token fetch failed — still navigate but user will need to log in manually
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        if (!mounted) return;
        Get.offAllNamed(AppRoutes.location);
      }
    } catch (e) {
      debugPrint('Auto-login error after signup: $e');
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.location);
    }
  }

  void handleSubmit() {
    final error = validateFields();
    if (error != null) {
      showError(error);
    } else {
      signup();
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
                  CustomText(text: "Your Name", fontSize: 12.sp),
                  SizedBox(height: 7.h),

                  CustomTextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    preFixIcon: 'assets/svg/user.svg',
                    hintText: "Rohan Kumar",
                  ),

                  SizedBox(height: 17.h),

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
                        color: AppColors.primaryTextColor,
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
                    text: 'Sign Up',
                    onPressed: () {
                      handleSubmit();
                    },
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),

            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: AppColors.primaryTextColor,
                  ),
                ),

                SizedBox(width: 6.w),
                InkWell(
                  child: Text(
                    'Login',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  onTap: () => Get.back(),
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