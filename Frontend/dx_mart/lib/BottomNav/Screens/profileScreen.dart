import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Auth/edit_profile.dart';
import '../../Auth/loginScreen.dart';
import '../../Coupon/coupon_screen.dart';
import '../../DeliveryAddress/delivery_address_screen.dart';
import '../../Help/help_screen.dart';
import '../../ProfileScreen/about_screen.dart';
import '../../ProfileScreen/privacy_policy.dart';
import '../../ProfileScreen/return_policy.dart';
import '../../ProfileScreen/terms_condition.dart';
import '../../utils/colors.dart';
import '../../utils/api_constants.dart';
import '../../utils/api_helper.dart';
import 'categoryScreen.dart';
import 'order_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userEmail = "";
  String userName = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final info = await ApiHelper.getUserInfo();
    if (info['id']!.isNotEmpty && mounted) {
      setState(() {
        userEmail = info['email']!;
        userName = info['name']!;
      });
    }
  }

  Future<void> logoutUser() async {
    // Revoke token on the server first
    try {
      await ApiHelper.post(ApiConstants.LOGOUT, auth: true);
    } catch (_) {}
    // Clear token via ApiHelper, then wipe all cached user data
    await ApiHelper.clearToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('auth_token');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.hintTextColor, fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logoutUser();
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24.sp, color: AppColors.primaryColor),
              SizedBox(height: 6.h),
              Text(
                label,
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 50.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundColor: AppColors.primaryColor,
                    child: SvgPicture.asset(
                      'assets/svg/profile.svg',
                      color: AppColors.primaryTextColor,
                      width: 25.w,
                      height: 25.h,
                    ),
                  ),

                  SizedBox(width: 10.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Row(
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.jost(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.edit,
                              size: 18.sp,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(
                                email: userEmail,
                                fullName: userName,
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        userEmail,
                        style: GoogleFonts.jost(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            Container(color: Colors.grey.withValues(alpha: 0.5), height: 0.5),

            // ── Quick Navigation tiles (previously bottom nav) ──────
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Links',
                    style: GoogleFonts.jost(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hintTextColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _buildNavTile(
                        icon: Icons.grid_view_rounded,
                        label: 'Categories',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryScreen(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _buildNavTile(
                        icon: Icons.receipt_long_rounded,
                        label: 'Orders',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderScreen(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _buildNavTile(
                        icon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WishlistScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
            Container(color: Colors.grey.withValues(alpha: 0.5), height: 0.5),

            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 25.h),
              child: Column(
                children: [
                  // Order
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderScreen()),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_order.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Orders',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  // Delivery Address
                  SizedBox(height: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryAddressScreen(),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_location.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          ' Delivery Address',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  // Coupon
                  SizedBox(height: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CouponScreen()),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_coupon.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Coupon',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  // Help
                  SizedBox(height: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpScreen()),
                      );
                    },

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_help.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          ' Help',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  // About
                  SizedBox(height: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutScreen()),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_about.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          ' About',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  // Terms & Condition
                  SizedBox(height: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsCondition(),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_term_condition.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          ' Terms & Condition',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  // Privacy Policy
                  SizedBox(height: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicy(),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_privacy_policy.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          ' Privacy Policy',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  // Return Policy
                  SizedBox(height: 20.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReturnPolicy()),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 16.h),
                        SvgPicture.asset(
                          'assets/svg/p_return_policy.svg',
                          height: 18.h,
                          width: 18.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          ' Shipping Policy',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 17.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.w),
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    height: 0.7,
                  ),

                  SizedBox(height: 30.w),

                  InkWell(
                    onTap: showLogoutDialog,
                    child: Container(
                      width: double.infinity,
                      height: 39.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/p_logout.svg',
                            color: AppColors.iconColor,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Log out',
                            style: GoogleFonts.jost(
                              fontSize: 14.sp,
                              color: AppColors.primaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),  
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}