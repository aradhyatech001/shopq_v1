import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../CustomWidgets/product_card.dart';
import '../../utils/api_constants.dart';
import '../../utils/colors.dart';
import '../bottomNavScreen.dart';
import 'cartScreen.dart';
import '../../utils/api_helper.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<dynamic> wishlistProducts = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String userEmail = "";
  String userName = "";
  String userID = "";

  List<Map<String, dynamic>> cartList = [];

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
        userID = info['id']!;
      });
      fetchCartQuantity(userID);
      fetchWishlist(userID);
    }
  }

  /// ✅ Cart quantity fetch
  Future<void> fetchCartQuantity(String id) async {
    final url = Uri.parse('${ApiConstants.GET_CART_ITEMS}?user_id=$id');
    try {
      final _authHeaders = await ApiHelper.getAuthHeaders();
      final response = await http.get(url, headers: _authHeaders);
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

  Future<void> fetchWishlist(String userID) async {
    if (userID.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('${ApiConstants.GET_WISHLIST}?user_id=$userID');
      final _authHeaders = await ApiHelper.getAuthHeaders();
      final response = await http.get(url, headers: _authHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (data['products'] != null && data['products'].isNotEmpty) {
            setState(() {
              wishlistProducts = List<Map<String, dynamic>>.from(
                data['products'],
              );
            });
          } else {
            setState(() {
              wishlistProducts = [];
            });
          }
        } else {
          setState(() {
            wishlistProducts = [];
          });
        }
      } else {
        setState(() {
          wishlistProducts = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
      setState(() {
        wishlistProducts = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      final url = Uri.parse(ApiConstants.REMOVE_FROM_WISHLIST);
      final response = await ApiHelper.postJson(url.toString(), body: {'user_id': userID, 'product_id': productId}, auth: true);

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // ✅ सिर्फ local list update करो, दोबारा full fetch की ज़रूरत नहीं
        setState(() {
          wishlistProducts.removeWhere(
            (item) => item['product_id'].toString() == productId,
          );
        });
      }
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
    }
  }

  Future<void> _refreshWishlist() async {
    setState(() {
      isRefreshing = true;
    });
    await fetchWishlist(userID);
    setState(() {
      isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: Stack(
        children: [
          userID.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 50.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Please login to view your wishlist',
                        style: GoogleFonts.jost(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshWishlist,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : wishlistProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 50.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Your wishlist is empty',
                                style: GoogleFonts.jost(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(height: 17.h),
                            Container(
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
                              child: Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 16.w),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BottomNavScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 25.h,
                                        width: 28.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 7.w),
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              size: 15.sp,
                                              color: AppColors.iconColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Text(
                                      "Wishlist",
                                      style: GoogleFonts.jost(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Spacer(),

                                    SizedBox(width: 16.w),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(
                              child: GridView.builder(
                                padding: EdgeInsets.all(12.w),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12.w,
                                      mainAxisSpacing: 12.h,
                                      childAspectRatio: 0.40,
                                    ),
                                itemCount: wishlistProducts.length,
                                itemBuilder: (context, index) {
                                  final product = wishlistProducts[index];
                                  return ProductCard(
                                    product: product,
                                    userId: userID,
                                    onCartUpdated: () {
                                      fetchCartQuantity(
                                        userID,
                                      ); // ✅ Real-time update
                                    },
                                    onWishlistUpdated: () {
                                      fetchWishlist(userID);
                                    },

                                    onCategoryBack: () {
                                      setState(() {
                                        fetchCartQuantity(userID);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),

          // ✅ Floating Cart Button (Only show if cartList is not empty)
          if (cartList.isNotEmpty)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.slowMiddle,
              bottom: cartList.isNotEmpty ? 20.h : -100.h, // Hide below screen
              left: 110.w,
              right: 110.w,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: cartList.isNotEmpty ? 1.0 : 0.0, // Fade in/out
                child: InkWell(
                  onTap: () async {
                    if (!mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                    setState(() {
                      fetchCartQuantity(userID);
                    });
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
                              color: AppColors.primaryTextColor,
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
}
