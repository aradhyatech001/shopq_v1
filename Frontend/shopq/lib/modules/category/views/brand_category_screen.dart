import 'dart:convert';
import 'package:shopq/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopq/modules/product/views/search_screen.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/app/theme/app_colors.dart';
import 'brand_view_screen.dart';

class BrandCategory extends StatefulWidget {
  const BrandCategory({super.key});

  @override
  State<BrandCategory> createState() => _BrandCategoryState();
}

class _BrandCategoryState extends State<BrandCategory> {
  List _brandsList = [];

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      final response = await ApiHelper.get(ApiConstants.VIEW_BRAND);
      if (response.statusCode == 200) {
        // CategoryController::view() returns a plain JSON array with fields:
        // id, name, image — NOT brand_name / brand_image
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          data = decoded['data'] as List;
        } else {
          data = [];
        }
        setState(() {
          _brandsList = data;
        });
      } else {
        debugPrint(
          'Failed to load brands. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error while fetching brands: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          SizedBox(height: 14.h),
          buildAppBar(),
          Expanded(
            child: _brandsList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.all(12.w),
                    child: GridView.builder(
                      padding: EdgeInsets.zero, // ✅ Extra top margin hata dega
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 2 brands in one row
                        crossAxisSpacing: 0.w,
                        mainAxisSpacing: 15.h,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _brandsList.length,
                      itemBuilder: (context, index) {
                        final brand = _brandsList[index];
                        return InkWell(
                          onTap: () {
                            // Backend returns 'name' field, not 'brand_name'
                            Get.to(() => BrandViewScreen(
                                  brandName: brand['name']?.toString() ?? '',
                                ));
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 0.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Brand Image — backend returns 'image' field (not 'brand_image')
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child:
                                          (brand['image'] != null &&
                                              brand['image']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? AppNetworkImage(
                                              brand['image'].toString(),
                                              height: 60.h,
                                              width: 60.w,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.image,
                                                    size: 40,
                                                  ),
                                            )
                                          : Icon(Icons.image, size: 40),
                                    ),
                                    SizedBox(height: 10.h),
                                    // Brand Name — backend returns 'name' field (not 'brand_name')
                                    Text(
                                      brand['name']?.toString() ?? "No Name",
                                      style: GoogleFonts.jost(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// ✅ Top AppBar
  Widget buildAppBar() {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16.w),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 25.h,
              width: 28.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 7.w),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.iconColor,
                    size: 15.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            "Brands",
            style: GoogleFonts.jost(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () {
              Get.to(() => SearchProduct());
            },
            child: Container(
              height: 25.h,
              width: 28.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 1.w),
                  child: Icon(
                    Icons.search,
                    color: AppColors.iconColor,
                    size: 15.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }
}