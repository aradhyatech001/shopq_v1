import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../CategoryViewScreen/categoryViewScreen.dart';
import '../../utils/api_constants.dart';
import '../../utils/colors.dart';
import '../bottomNavScreen.dart';
import '../../utils/api_helper.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> _categoriesWithSubs = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await ApiHelper.get('${ApiConstants.MAIN_VIEW_CATEGORY}?with_subs=1');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && mounted) {
          setState(() {
            _categoriesWithSubs = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Unexpected response format';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Connection error: $e';
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          SizedBox(height: 20.h),
          // ── AppBar ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavScreen(),
                      ),
                    ),
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
                            size: 15.sp,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'All Categories',
                    style: GoogleFonts.jost(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _fetchCategories,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : _hasError
                ? _buildErrorWidget()
                : _categoriesWithSubs.isEmpty
                ? Center(
                    child: Text(
                      'No categories found',
                      style: GoogleFonts.jost(
                        fontSize: 15.sp,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildGroupedCategoryList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Grouped list: parent category header + subcategory 4-col grid ──
  Widget _buildGroupedCategoryList() {
    final sections = <Widget>[];

    for (final cat in _categoriesWithSubs) {
      final subs = List<Map<String, dynamic>>.from(
        cat['subcategories'] as List? ?? [],
      );
      final catId = int.tryParse(cat['id'].toString()) ?? 0;

      // Section header (parent category name)
      sections.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
          child: Row(
            children: [
              if (cat['image'] != null && cat['image'].toString().isNotEmpty)
                Container(
                  width: 28.w,
                  height: 28.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.network(
                      cat['image'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.category_outlined,
                        size: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              Text(
                cat['name']?.toString() ?? '',
                style: GoogleFonts.jost(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

      if (subs.isEmpty) {
        // No subcategories — show the parent itself as a card tapping to CategoryViewScreen
        sections.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryViewScreen(
                    categoryId: catId,
                    categoryName: cat['name']?.toString() ?? '',
                  ),
                ),
              ),
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    'Shop ${cat['name'] ?? ''}',
                    style: GoogleFonts.jost(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        // 4-column subcategory grid
        sections.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.72,
                crossAxisSpacing: 6.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: subs.length,
              itemBuilder: (ctx, i) {
                final sub = subs[i];
                final subId = int.tryParse(sub['id'].toString());
                final imgUrl = sub['image']?.toString() ?? '';

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryViewScreen(
                        categoryId: catId,
                        categoryName: sub['name']?.toString() ?? '',
                        initialSubCategoryId: subId,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 60.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: imgUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.category_outlined,
                                    color: AppColors.primaryColor,
                                    size: 22.sp,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.category_outlined,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        sub['name']?.toString() ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jost(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }

      sections.add(SizedBox(height: 8.h));
    }

    sections.add(SizedBox(height: 20.h));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
          SizedBox(height: 10.h),
          Text(
            'Error loading categories',
            style: GoogleFonts.jost(
              fontSize: 16.sp,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(fontSize: 13.sp),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: _fetchCategories,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: Text('Retry', style: GoogleFonts.jost(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
