import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/api_helper.dart';

import '../BottomNav/Screens/cartScreen.dart';
import '../CustomWidgets/product_card.dart';
import '../SearchProduct/search_product.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class CategoryViewScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final int? initialSubCategoryId; // pre-select a subcategory

  const CategoryViewScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.initialSubCategoryId,
  });

  @override
  State<CategoryViewScreen> createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends State<CategoryViewScreen> {
  late int selectedCategoryId;
  late String selectedCategoryName;
  List products = [];
  List _subCategories = [];
  int? _selectedSubCategoryId; // null = "All"
  bool _isLoadingProducts = false;
  bool _isLoadingSubcategories = true;
  List<Map<String, dynamic>> cartList = [];

  String userEmail = "";
  String userName = "";
  String userID = "";

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.categoryId ?? 0;
    selectedCategoryName = widget.categoryName ?? "";
    _selectedSubCategoryId = widget.initialSubCategoryId;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final info = await ApiHelper.getUserInfo();
    if (mounted) {
      if (info['id']!.isNotEmpty) {
        setState(() {
          userEmail = info['email']!;
          userName = info['name']!;
          userID = info['id']!;
        });
        fetchCartQuantity(userID);
      }
      _initializeData();
    }
  }

  Future<void> fetchCartQuantity(String id) async {
    final url = Uri.parse('${ApiConstants.GET_CART_ITEMS}?user_id=$id');
    try {
      final response = await ApiHelper.get(url.toString(), auth: true);
      final data = jsonDecode(response.body);
      if (data['success']) {
        if (mounted) {
          setState(
            () =>
                cartList = List<Map<String, dynamic>>.from(data['cart'] ?? []),
          );
        }
      } else {
        if (mounted) setState(() => cartList = []);
      }
    } catch (e) {
      if (mounted) setState(() => cartList = []);
    }
  }

  Future<void> _initializeData() async {
    if (selectedCategoryId != 0) {
      await _fetchSubCategories(selectedCategoryId);
      await fetchProductsByCategory(
        selectedCategoryId,
        subCategoryId: _selectedSubCategoryId,
      );
    }
  }

  Future<void> _fetchSubCategories(int categoryId) async {
    if (mounted) setState(() => _isLoadingSubcategories = true);
    try {
      final url = Uri.parse(
        '${ApiConstants.VIEW_SUBCATEGORIES}?parent_id=$categoryId',
      );
      final res = await http.get(url);
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() {
          _subCategories = (data['data'] as List? ?? []);
          _isLoadingSubcategories = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingSubcategories = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSubcategories = false);
    }
  }

  Future<void> fetchProductsByCategory(
    int categoryId, {
    int? subCategoryId,
  }) async {
    if (mounted) {
      setState(() {
        _isLoadingProducts = true;
        products = [];
      });
    }

    String urlStr =
        '${ApiConstants.VIEW_ALL_PRODUCTS_BY_CATEGORY}?category_id=$categoryId';
    if (subCategoryId != null) urlStr += '&subcategory_id=$subCategoryId';

    try {
      final res = await http.get(Uri.parse(urlStr));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            products = data is List ? data : (data['products'] ?? []);
            _processProductVariants();
          });
        }
      } else {
        if (mounted) setState(() => products = []);
      }
    } catch (e) {
      if (mounted) setState(() => products = []);
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  void _processProductVariants() {
    for (var product in products) {
      if (product['variants'] != null && product['variants'].isNotEmpty) {
        product['selectedVariantName'] = product['variants'][0]['name'];
        product['selectedPrice'] = double.tryParse(
          product['variants'][0]['selling_price'].toString(),
        );
      } else {
        product['selectedVariantName'] = null;
        product['selectedPrice'] = null;
      }
    }
  }

  Widget _buildSubCategoryImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 44.w,
        height: 44.h,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.category_outlined,
          size: 24.sp,
          color: AppColors.primaryColor,
        ),
      );
    }
    return Icon(
      Icons.category_outlined,
      size: 24.sp,
      color: AppColors.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Column(
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
                        onTap: () => Navigator.pop(context),
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
                      Expanded(
                        child: Text(
                          selectedCategoryName.isNotEmpty
                              ? selectedCategoryName
                              : "Categories",
                          style: GoogleFonts.jost(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Product count badge
                      if (!_isLoadingProducts && products.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${products.length} items',
                              style: GoogleFonts.jost(
                                fontSize: 11.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // Search (matches reference header)
                      Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SearchProduct()),
                          ),
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(Icons.search_rounded,
                              size: 24.sp, color: AppColors.primaryTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Main content ────────────────────────────────────────
              Expanded(
                child: Row(
                  children: [
                    // ── LEFT SIDEBAR: Subcategories ─────────────────
                    Container(
                      width: 80.w,
                      margin: EdgeInsets.only(top: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.r),
                        ),
                        border: Border.all(
                          color: const Color(0xffE8E6E6),
                          width: 1,
                        ),
                      ),
                      child: _isLoadingSubcategories
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount:
                                  _subCategories.length + 1, // +1 for "All"
                              itemBuilder: (context, index) {
                                final bool isAll = index == 0;
                                final bool isSelected = isAll
                                    ? _selectedSubCategoryId == null
                                    : int.tryParse(
                                            _subCategories[index - 1]['id']
                                                .toString(),
                                          ) ==
                                          _selectedSubCategoryId;

                                final String label = isAll
                                    ? 'All'
                                    : (_subCategories[index - 1]['name'] ?? '');
                                final String? imageUrl = isAll
                                    ? null
                                    : _subCategories[index - 1]['image'];

                                return GestureDetector(
                                  onTap: () {
                                    if (isAll) {
                                      if (_selectedSubCategoryId != null) {
                                        setState(
                                          () => _selectedSubCategoryId = null,
                                        );
                                        fetchProductsByCategory(
                                          selectedCategoryId,
                                        );
                                      }
                                    } else {
                                      final subId = int.tryParse(
                                        _subCategories[index - 1]['id']
                                            .toString(),
                                      );
                                      if (subId != _selectedSubCategoryId) {
                                        setState(
                                          () => _selectedSubCategoryId = subId,
                                        );
                                        fetchProductsByCategory(
                                          selectedCategoryId,
                                          subCategoryId: subId,
                                        );
                                      }
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 8.h,
                                        ),
                                        color: isSelected
                                            ? AppColors.primaryColor.withValues(
                                                alpha: 0.05,
                                              )
                                            : Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Image / icon
                                            Container(
                                              width: 48.w,
                                              height: 48.h,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primaryColor
                                                          .withValues(
                                                            alpha: 0.12,
                                                          )
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                child: Center(
                                                  child: isAll
                                                      ? Icon(
                                                          Icons
                                                              .grid_view_rounded,
                                                          size: 22.sp,
                                                          color: isSelected
                                                              ? AppColors
                                                                    .primaryColor
                                                              : Colors.grey,
                                                        )
                                                      : _buildSubCategoryImage(
                                                          imageUrl,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            Text(
                                              label,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.jost(
                                                fontSize: 10.5.sp,
                                                color: isSelected
                                                    ? AppColors.primaryColor
                                                    : AppColors
                                                          .primaryTextColor,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Selected indicator bar on right edge
                                      Positioned(
                                        right: 0,
                                        top: 8.h,
                                        bottom: 8.h,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          width: isSelected ? 3.w : 0,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.r),
                                              bottomLeft: Radius.circular(10.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    // ── RIGHT: Product grid ─────────────────────────
                    Expanded(
                      child: _isLoadingProducts
                          ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            )
                          : products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 50.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    "No products found",
                                    style: GoogleFonts.jost(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    _selectedSubCategoryId != null
                                        ? "Try selecting 'All'"
                                        : "Products will appear here",
                                    style: GoogleFonts.jost(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.all(10.w),
                              itemCount: products.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: 235.h,
                                    crossAxisSpacing: 6.w,
                                    mainAxisSpacing: 8.h,
                                  ),
                              itemBuilder: (context, index) {
                                return ProductCard(
                                  product: products[index],
                                  userId: userID,
                                  onCartUpdated: () =>
                                      fetchCartQuantity(userID),
                                  onCategoryBack: () =>
                                      setState(() => fetchCartQuantity(userID)),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Floating View Cart button ───────────────────────────
          if (cartList.isNotEmpty)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.slowMiddle,
              bottom: 40.h,
              left: 110.w,
              right: 110.w,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen()),
                ),
                child: Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.gray,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Center(
                            child: Text(
                              cartList.length.toString(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "View Cart",
                          style: GoogleFonts.jost(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: AppColors.iconColor,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
