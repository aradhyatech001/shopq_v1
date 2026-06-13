
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BottomNav/bottomNavScreen.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _pincodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isChecking = false;
  bool _isConfirming = false;

  Map<String, dynamic>? _pincodeData; // non-null when found & serviceable
  String? _errorMsg;

  @override
  void dispose() {
    _pincodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _resetResult() {
    if (_pincodeData != null || _errorMsg != null) {
      setState(() {
        _pincodeData = null;
        _errorMsg = null;
      });
    }
  }

  Future<void> _checkPincode() async {
    final code = _pincodeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMsg = 'Please enter a valid 6-digit pincode');
      return;
    }

    _focusNode.unfocus();
    setState(() {
      _isChecking = true;
      _pincodeData = null;
      _errorMsg = null;
    });

    try {
      final response = await ApiHelper.get('${ApiConstants.CHECK_PINCODE}?code=$code');

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['serviceable'] == true) {
        final pincode = Map<String, dynamic>.from(data['pincode'] as Map);
        pincode['vendor_count'] = data['vendor_count'] ?? 0;
        setState(() {
          _pincodeData = pincode;
          _errorMsg = null;
        });
      } else if (data['success'] == true) {
        setState(() {
          _errorMsg = 'Sorry, we don\'t deliver to this pincode yet.';
          _pincodeData = null;
        });
      } else {
        setState(() {
          _errorMsg = 'Pincode not found. Please check and try again.';
          _pincodeData = null;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMsg = 'Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _confirmLocation() async {
    if (_pincodeData == null) return;
    setState(() => _isConfirming = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token  = prefs.getString('auth_token') ?? '';

      // Save pincode to backend only if user is logged in (has a token)
      if (token.isNotEmpty) {
        await ApiHelper.post(ApiConstants.SET_PINCODE, body: {'pincode_id': _pincodeData!['id'].toString()}, auth: true,
        );
      }

      await prefs.setString('pincode_id',       _pincodeData!['id'].toString());
      await prefs.setString('pincode_code',      _pincodeData!['code'].toString());
      await prefs.setString('pincode_area_name', _pincodeData!['area_name'] ?? '');
      await prefs.setString('pincode_city',      _pincodeData!['city'] ?? '');
      await prefs.setString('pincode_state',     _pincodeData!['state'] ?? '');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.',
              style: GoogleFonts.jost()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 48.h),

              // Illustration
              Image.asset(
                'assets/images/location.png',
                width: 160.w,
                height: 120.h,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 24.h),

              Text(
                'Enter Your Pincode',
                style: GoogleFonts.jost(
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'We\'ll check if delivery is available\nat your location',
                style: GoogleFonts.jost(
                  color: Colors.grey.shade500,
                  fontSize: 13.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 36.h),

              // Pincode input + Check button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pincodeController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.jost(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '_ _ _ _ _ _',
                        hintStyle: GoogleFonts.jost(
                          fontSize: 18.sp,
                          letterSpacing: 6,
                          color: Colors.grey.shade300,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 1.5),
                        ),
                      ),
                      onChanged: (_) => _resetResult(),
                      onSubmitted: (_) => _checkPincode(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _checkPincode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor:
                            AppColors.primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        elevation: 0,
                      ),
                      child: _isChecking
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Check',
                              style: GoogleFonts.jost(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              if (_errorMsg != null)
                Text(
                  _errorMsg!,
                  style: GoogleFonts.jost(
                    color: Colors.red.shade400,
                    fontSize: 13.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (_pincodeData != null)
                Column(
                  children: [
                    Text(
                      'Great news! We deliver to your area.',
                      style: GoogleFonts.jost(
                        color: Colors.green.shade600,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${_pincodeData!['area_name']}, ${_pincodeData!['city']}, ${_pincodeData!['state']}',
                      style: GoogleFonts.jost(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _isConfirming ? null : _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor:
                            AppColors.primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                        elevation: 0,
                      ),
                      child: _isConfirming
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator( 
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Confirm Location',
                              style: GoogleFonts.jost(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ), 
                    ),
                  ], 
                ),
            ],
          ),
        ),
      ),
    );
  }
}