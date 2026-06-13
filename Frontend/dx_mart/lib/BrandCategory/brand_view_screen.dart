import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/api_helper.dart';

import '../BottomNav/Screens/cartScreen.dart';
import '../CustomWidgets/product_card.dart';
import '../SearchProduct/search_product.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class BrandViewScreen extends StatefulWidget {
  final String brandName;
  const BrandViewScreen({super.key, required this.brandName});

  @override
  State<BrandViewScreen> createState() => _BrandViewScreenState();
}

class _BrandViewScreenState extends State<BrandViewScreen> {
  List allProducts = []; // pura products
  List filteredProducts = []; // brand filter ke baad products
  bool _isLoadingProducts = false;
  List<Map<String, dynamic>> cartList = [];

  String userEmail = "";
  String userName = "";
  String userID = "";

  @override
  void initState() {
    super.initState();
    fetchProducts(); // ek hi api call

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final info = await ApiHelper.getUserInfo();
    if (info['id']!.isNotEmpty && mounted) {
      setState(() {
        userEmail = info['email']!;
        userName = info['name']!;
        userID = info['id']!;
      });
      fetchCartQuantity(userID);
    }
  }

  /// ✅ Cart quantity fetch
  Future<void> fetchCartQuantity(String id) async {
    final url = Uri.parse('${ApiConstants.GET_CART_ITEMS}?user_id=$id');
    try {
      final response = await ApiHelper.get(url.toString(), auth: true);
      final data = jsonDecode(response.body);

      if (data['success']) {
        final cartItems = List<Map<String, dynamic>>.from(data['cart'] ?? []);
        setState(() {
          cartList = cartItems;
        });
      } else {
        setState(() {
          cartList = [];
        });
      }
    } catch (e) {
      setState(() {
        cartList = [];
      });
    }
  }

  Future<void> fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      // Fetch ALL products using pagination — pass a high limit to capture all
      // and filter by brand_name which is stored in product info attributes
      const int pageLimit = 100;
      var response = await ApiHelper.get('${ApiConstants.VIEW_ALL_PRODUCTS}?page=1&limit=$pageLimit');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final allFetched = List<dynamic>.from(data["products"] ?? []);

        // If there are more pages, fetch them too
        final int totalPages = data['totalPages'] ?? 1;
        if (totalPages > 1) {
          for (int page = 2; page <= totalPages; page++) {
            final r = await ApiHelper.get('${ApiConstants.VIEW_ALL_PRODUCTS}?page=$page&limit=$pageLimit');
            if (r.statusCode == 200) {
              final d = jsonDecode(r.body);
              allFetched.addAll(List<dynamic>.from(d["products"] ?? []));
            }
          }
        }

        if (mounted) {
          setState(() {
            allProducts = allFetched;
            filteredProducts = allProducts
                .where((p) => p["brand_name"]?.toString() == widget.brandName)
                .toList();
            _isLoadingProducts = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingProducts = false);
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
      if (mounted) setState(() => _isLoadingProducts = false);
    }
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

              // ✅ Top AppBar
              buildAppBar(),

              SizedBox(height: 20.h),

              // ✅ Products Grid OR Empty Message
              Expanded(
                child: _isLoadingProducts
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : filteredProducts.isNotEmpty
                        ? buildSection(filteredProducts)
                        : Center(
                            child: Text(
                              "No products found\nfor this brand!",
                              style: GoogleFonts.jost(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.hintTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
              ),
            ],
          ),

          // ✅ Floating Cart Button (Only show if cartList is not empty)
          if (cartList.isNotEmpty)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.slowMiddle,
              bottom: cartList.isNotEmpty ? 40.h : -100.h, // Hide below screen
              left: 110.w,
              right: 110.w,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: cartList.isNotEmpty ? 1.0 : 0.0, // Fade in/out
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor, // Transparent color
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: Offset(0, 4),
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
                          Spacer(),
                          Text(
                            "View Cart",
                            style: GoogleFonts.jost(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.iconColor,
                            ),
                          ),
                          Spacer(),
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
            ),
        ],
      ),
    );
  }

  /// ✅ Top AppBar extracted for clarity
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
            widget.brandName.toString(),
            style: GoogleFonts.jost(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchProduct()),
              );
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

  /// ✅ Grid Section
  Widget buildSection(List<dynamic> list) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.38,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final product = list[index];
          return ProductCard(
            product: product,
            userId: userID,
            onCartUpdated: () {
              fetchCartQuantity(userID);
            },
          );
        },
      ),
    );
  }
}
