import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/api_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../BottomNav/Screens/cartScreen.dart';
import '../CustomWidgets/product_card.dart';
import '../CustomWidgets/skeletons.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class SearchProduct extends StatefulWidget {
  final String? category_name; // category name optional
  const SearchProduct({super.key, this.category_name});

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  TextEditingController searchController = TextEditingController();
  List products = [];
  bool isLoading = false;
  String currentSearchTerm = "";
  bool hasSearched = false;

  bool _isLoadingProducts = false;
  List<Map<String, dynamic>> cartList = [];

  String userEmail = "";
  String userName = "";
  String userID = "";

  // Voice recognition variables
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    fetchProducts(); // First load all products
    fetchUserData();
    _initializeSpeech();
  }

  // Initialize speech to text
  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        debugPrint('Speech error: $errorNotification');
        setState(() {
          _isListening = false;
        });
      },
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice search not available on this device')),
      );
    }
  }

  // Start listening for voice input
  void _startListening() async {
    if (!_speech.isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Voice search not available')));
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          if (result.finalResult) {
            searchController.text = _recognizedText;
            fetchProducts(search: _recognizedText);
            _isListening = false;
          }
        });
      },
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  // Stop listening
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> fetchProducts({String search = ""}) async {
    setState(() {
      isLoading = true;
      currentSearchTerm = search;
      hasSearched = true;
    });

    final response = await ApiHelper.get(
      "${ApiConstants.VIEW_ALL_PRODUCTS}?search=$search&page=1&limit=20",
      pincode: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success']) {
        setState(() {
          products = data['products'];
        });
      }
    }

    setState(() {
      isLoading = false;
    });
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

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
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

              // ✅ Top Custom AppBar with Search Bar
              buildAppBar(),

              SizedBox(height: 10.h),

              // ✅ Showing Results Text
              if (hasSearched && currentSearchTerm.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Showing Results for ",
                            style: GoogleFonts.jost(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.hintTextColor,
                            ),
                          ),
                          TextSpan(
                            text: '"$currentSearchTerm"',
                            style: GoogleFonts.jost(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 10.h),

              // ✅ Products Grid or No Results
              if (products.isNotEmpty) Expanded(child: buildSection(products)),

              if (hasSearched && products.isEmpty && !isLoading)
                Expanded(
                  child: Center(
                    child: Text(
                      "No products found",
                      style: GoogleFonts.jost(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                  ),
                ),

              if (isLoading)
                const Expanded(
                  child: ProductGridSkeleton(count: 9, crossAxisCount: 3),
                ),
            ],
          ),

          // Voice listening overlay
          if (_isListening)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, size: 64.sp, color: Colors.white),
                      SizedBox(height: 20.h),
                      Text(
                        "Listening...",
                        style: GoogleFonts.jost(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        _recognizedText,
                        style: GoogleFonts.jost(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),
                      ElevatedButton(
                        onPressed: _stopListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 15.h,
                          ),
                        ),
                        child: Text(
                          "Stop Listening",
                          style: GoogleFonts.jost(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ✅ Floating Cart Button (Only show if cartList is not empty)
          if (cartList.isNotEmpty && !_isListening)
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
                      color: AppColors.primaryColor,
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
                            color: AppColors.primaryTextColor,
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

  /// ✅ Custom Header with Search Bar
  Widget buildAppBar() {
    return Container(
      width: double.infinity,
      height: 110.h,
      decoration: BoxDecoration(color: AppColors.backgroundColor),
      child: Column(
        children: [
          SizedBox(height: 15.h),

          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Row(
              children: [
                SizedBox(width: 13.w),

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
                Spacer(),

                Text(
                  'Search',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                  ),
                ),
                Spacer(),

                SizedBox(width: 40.w),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              width: double.infinity,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.lineColor, width: 1.5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 20.sp,
                    color: AppColors.hintTextColor,
                  ),
                  SizedBox(width: 6.w),

                  /// ✅ Expanded TextField with Animated Placeholder
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // ✅ Animated Hint (visible only when empty)
                        if (searchController.text.isEmpty)
                          IgnorePointer(
                            child: AnimatedTextKit(
                              repeatForever: true,
                              pause: Duration(milliseconds: 2000),
                              animatedTexts: [
                                TyperAnimatedText(
                                  "Search for Grocery",
                                  textStyle: GoogleFonts.jost(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hintTextColor,
                                  ),
                                  speed: Duration(milliseconds: 80),
                                ),
                                TyperAnimatedText(
                                  "Search for Beauty",
                                  textStyle: GoogleFonts.jost(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hintTextColor,
                                  ),
                                  speed: Duration(milliseconds: 80),
                                ),
                                TyperAnimatedText(
                                  "Search for Snacks",
                                  textStyle: GoogleFonts.jost(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hintTextColor,
                                  ),
                                  speed: Duration(milliseconds: 80),
                                ),
                              ],
                            ),
                          ),

                        // ✅ TextField
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: TextField(
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            style: GoogleFonts.jost(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 8.h),
                            ),
                            onChanged: (value) {
                              setState(() {}); // update clear button
                            },
                            onSubmitted: (value) {
                              fetchProducts(search: value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ✅ Mic / Clear button
                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        fetchProducts();
                        setState(() {});
                      },
                      child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                    )
                  else
                    GestureDetector(
                      onTap: _startListening,
                      child: Icon(
                        Icons.mic,
                        size: 20.sp,
                        color: _isListening
                            ? AppColors.primaryColor
                            : AppColors.hintTextColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
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
