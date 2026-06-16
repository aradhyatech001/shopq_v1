import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../CategoryViewScreen/categoryViewScreen.dart';
import '../../CustomWidgets/product_card.dart';
import '../../LocationScreen/locationScreen.dart';
import '../../SearchProduct/search_product.dart';
import '../../Shop/shop_detail_screen.dart';
import '../../utils/api_constants.dart';
import '../../utils/app_config.dart';
import '../../utils/colors.dart';
import '../../utils/api_helper.dart';
import 'cartScreen.dart';
import 'profileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Scroll controller for detecting scroll direction
  final ScrollController _scrollController = ScrollController();

  // Data variables
  String deliveryTime = '15 minutes';
  String district = '';
  String city = '';
  String userName = "";
  String userEmail = "";
  String userId = "";
  bool _isLoading = true;
  List _categoryList = [];
  List _sliderList = [];
  List<Map<String, dynamic>> _couponList = [];

  // Category position lists
  List<dynamic> mainFirstCategoryList = [];
  List<dynamic> mainSecondCategoryList = [];
  List<dynamic> mainThirdCategoryList = [];
  List<dynamic> mainFourthCategoryList = [];

  // Product type lists
  // Dynamic product type sections — keyed by type name
  List<String> _productTypeNames = [];
  Map<String, List> productTypeSections = {};
  List exclusiveOffersList = [];
  List newlyLaunchList = [];
  List readyToEatList = [];
  List<Map<String, dynamic>> cartList = [];

  // Home Tabs
  List<Map<String, dynamic>> _homeTabs = [];
  int _selectedTabIndex = 0;

  // Admin-configured per-tab layout (from /tab-layout). When a tab has
  // configured sections we render those instead of the hardcoded content.
  List _currentLayout = [];
  bool _loadingLayout = false;
  final Map<int, List> _layoutCache = {};
  List<dynamic> _tabCategoryProducts = [];
  bool _isLoadingTabContent = false;
  // Category tab subcategories (for circles row)
  List _tabSubCategories = [];
  // Categories tab (grouped by parent)
  List<Map<String, dynamic>> _categoriesWithSubs = [];

  // Banner images
  String? bannerImage;
  String? discount_bannerImage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        // Basic user data
        fetchUserData(),
        fetchDeliveryTime(),
        loadLocation(),

        // Categories and banners
        _fetchCategories(),
        _fetchHomeTabs(),
        _fetchCategoriesWithSubs(),

        _fetchSlider(),
        _fetchCoupons(),

        // Products
        loadAllTypes(),
      ]);
      // Load the admin-configured layout for the initially-selected tab.
      if (_homeTabs.isNotEmpty) {
        await _fetchTabLayout(_homeTabs[_selectedTabIndex]['id']);
      }
    } catch (e) {
      _showSnackBar("Error loading data: $e", AppColors.errorColor);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> fetchUserData() async {
    final info = await ApiHelper.getUserInfo();
    if (info['id']!.isNotEmpty) {
      if (mounted) {
        setState(() {
          userEmail = info['email']!;
          userName = info['name']!;
          userId = info['id']!;
        });
        fetchCartQuantity(userId);
      }
    }
  }

  /// ✅ Cart quantity fetch
  Future<void> fetchCartQuantity(String id) async {
    final url = Uri.parse('${ApiConstants.GET_CART_ITEMS}?user_id=$id');
    try {
      final response = await http.get(url);
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

  Future<void> loadLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Prefer the stored pincode (area / city / code); fall back to legacy keys.
    final area = prefs.getString('pincode_area_name') ?? '';
    final pCity = prefs.getString('pincode_city') ?? '';
    final code = prefs.getString('pincode_code') ?? '';
    setState(() {
      if (area.isNotEmpty || pCity.isNotEmpty || code.isNotEmpty) {
        district = area.isNotEmpty ? area : (pCity.isNotEmpty ? pCity : code);
        city = [pCity, code].where((e) => e.isNotEmpty).join(' · ');
      } else {
        district = prefs.getString('selected_district_name') ?? 'Set location';
        city = prefs.getString('selected_city_name') ?? '';
      }
    });
  }

  Future<void> fetchDeliveryTime() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.DELIVERY_TIME));
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() => deliveryTime = data['data']['time']);
      }
    } catch (e) {
      setState(() => deliveryTime = 'Error fetching time');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await ApiHelper.get(ApiConstants.MAIN_VIEW_CATEGORY);
      if (response.statusCode == 200) {
        setState(() => _categoryList = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> loadAllTypes() async {
    try {
      final res = await http.get(Uri.parse(ApiConstants.VIEW_PRODUCT_TYPES));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final types = List<Map<String, dynamic>>.from(data['data']);
          if (mounted) {
            setState(() {
              _productTypeNames = types
                  .map((t) => t['name'].toString())
                  .toList();
              productTypeSections = {for (var t in _productTypeNames) t: []};
            });
          }
          await Future.wait(_productTypeNames.map(fetchProductsByType));
        }
      }
    } catch (e) {
      debugPrint('Error loading product types: $e');
      // Fallback to defaults
      _productTypeNames = ['Everyday Essentials', 'Best Selling', 'Hot Deals'];
      if (mounted) {
        setState(
          () => productTypeSections = {for (var t in _productTypeNames) t: []},
        );
      }
      await Future.wait(_productTypeNames.map(fetchProductsByType));
    }
  }

  Future<void> fetchProductsByType(String type) async {
    final url = Uri.parse(
      '${ApiConstants.VIEW_PRODUCT_BY_TYPE}?type=$type&page=1&limit=10',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && mounted) {
          setState(() => productTypeSections[type] = body['products'] ?? []);
        }
      }
    } catch (e) {
      debugPrint("Error fetching $type products: $e");
    }
  }

  Future<void> _fetchSlider() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.VIEW_SLIDER));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() => _sliderList = jsonResponse['data']['offer_banners']);
        }
      }
    } catch (e) {
      debugPrint("Error fetching slider: $e");
    }
  }

  Future<void> _fetchCoupons() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.VIEW_COUPON));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          setState(
            () =>
                _couponList = List<Map<String, dynamic>>.from(decoded['data']),
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching coupons: $e");
    }
  }

  Future<void> _fetchHomeTabs() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.HOME_TABS));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && mounted) {
          setState(
            () =>
                _homeTabs = List<Map<String, dynamic>>.from(data['data'] ?? []),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching home tabs: $e');
    }
  }

  Future<void> _fetchCategoriesWithSubs() async {
    try {
      final res = await ApiHelper.get(
        '${ApiConstants.MAIN_VIEW_CATEGORY}?with_subs=1',
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        if (data is List) {
          setState(
            () => _categoriesWithSubs = List<Map<String, dynamic>>.from(data),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories with subs: $e');
    }
  }

  /// Loads the admin-configured section layout for a tab (cached per tab).
  Future<void> _fetchTabLayout(dynamic tabId) async {
    final id = tabId is int ? tabId : int.tryParse('$tabId') ?? 0;
    if (id == 0) return;
    if (_layoutCache.containsKey(id)) {
      setState(() => _currentLayout = _layoutCache[id]!);
      return;
    }
    setState(() => _loadingLayout = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.TAB_LAYOUT}?tab_id=$id'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final sections = data['success'] == true
            ? (data['sections'] as List? ?? [])
            : [];
        _layoutCache[id] = sections;
        if (mounted) setState(() => _currentLayout = sections);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingLayout = false);
    }
  }

  Future<void> _onTabSelected(int index) async {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
      _tabCategoryProducts = [];
      _tabSubCategories = [];
      _currentLayout = [];
    });
    final tab = _homeTabs[index];
    // Prefer admin-configured layout; the hardcoded fetches below act as a
    // fallback when a tab has no configured sections.
    _fetchTabLayout(tab['id']);
    if (tab['type'] == 'category' && tab['category_id'] != null) {
      // Category tab: fetch subcategories + products in parallel
      _fetchTabSubCategories(tab['category_id']);
      await _fetchTabProducts(tab['category_id']);
    } else if (tab['type'] == 'deals') {
      // Deals tab: no category filter — fetch ALL products, group by product type
      await _fetchTabProducts(0);
    }
  }

  Future<void> _fetchTabSubCategories(dynamic categoryId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.VIEW_SUBCATEGORIES}?parent_id=$categoryId',
      );
      final res = await http.get(url);
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() => _tabSubCategories = data['data'] as List? ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching tab subcategories: $e');
    }
  }

  Future<void> _fetchTabProducts(
    dynamic categoryId, {
    int? subCategoryId,
    String? type,
  }) async {
    if (mounted) setState(() => _isLoadingTabContent = true);
    try {
      String urlStr =
          '${ApiConstants.VIEW_ALL_PRODUCTS_BY_CATEGORY}?category_id=$categoryId';
      if (subCategoryId != null) urlStr += '&subcategory_id=$subCategoryId';
      if (type != null && type.isNotEmpty) {
        urlStr += '&type=${Uri.encodeComponent(type)}';
      }
      final res = await http.get(Uri.parse(urlStr));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _tabCategoryProducts = data['products'] ?? [];
            _isLoadingTabContent = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingTabContent = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTabContent = false);
    }
  }

  // ─── Icon mapping for tab icon keys ───
  /// Tab strip icon — admin-uploaded image/SVG if present, else mapped icon.
  Widget _buildTabIcon(Map tab, bool isSelected) {
    final color = isSelected ? Colors.white : Colors.white70;
    final iconImg = tab['icon_image']?.toString() ?? '';
    final fallback = Icon(
      _tabIcon(tab['icon'] ?? 'all'),
      size: 20.sp,
      color: color,
    );
    if (iconImg.isEmpty) return fallback;
    final url = ApiConstants.imageUrl(iconImg);
    if (iconImg.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        width: 22.w,
        height: 22.w,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (_) => fallback,
      );
    }
    return Image.network(
      url,
      width: 22.w,
      height: 22.w,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  IconData _tabIcon(String key) {
    switch (key) {
      case 'all':
        return Icons.shopping_bag_outlined;
      case 'grid':
        return Icons.grid_view_rounded;
      case 'leaf':
        return Icons.eco_outlined;
      case 'tractor':
        return Icons.agriculture_outlined;
      case 'apple':
        return Icons.local_florist_outlined;
      case 'flame':
        return Icons.local_fire_department_outlined;
      case 'soap':
        return Icons.soap_outlined;
      case 'rice':
        return Icons.grain_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      case 'beverage':
        return Icons.local_drink_outlined;
      case 'dairy':
        return Icons.breakfast_dining_outlined;
      case 'bakery':
        return Icons.bakery_dining_outlined;
      case 'personal':
        return Icons.face_retouching_natural_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'baby':
        return Icons.child_care_outlined;
      case 'pet':
        return Icons.pets_outlined;
      case 'deals':
        return Icons.local_offer_outlined;
      case 'summer':
        return Icons.wb_sunny_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  // ─── Tab bar widget ───
  // Tab bar widget (used inside SliverAppBar.bottom — white-on-primary style)
  Widget _buildTabBar() {
    if (_homeTabs.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: _homeTabs.length,
        itemBuilder: (context, index) {
          final tab = _homeTabs[index];
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => _onTabSelected(index),
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon: admin-uploaded image/SVG if set, else mapped icon
                  _buildTabIcon(tab, isSelected),
                  SizedBox(height: 3.h),
                  Text(
                    tab['name'],
                    style: GoogleFonts.jost(
                      fontSize: 10.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2.5,
                    width: isSelected ? 22.w : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Category tab content (Blinkit-style rich layout) ───
  Widget _buildCategoryTabContent(Map<String, dynamic> tab) {
    final bannerUrl = tab['banner_image']?.toString() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tab banner image (Summer Madness, Bachat Bazaar, Daily Fresh…)
        if (bannerUrl.isNotEmpty) _buildTabBanner(bannerUrl),

        // 2. Quality assurance row
        _buildQualityAssuranceRow(),

        // 3. Loading state
        if (_isLoadingTabContent)
          SizedBox(
            height: 300.h,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          )
        else ...[
          // 4. Subcategory grid (only for category type, not deals)
          if (tab['type'] != 'deals' && _tabSubCategories.isNotEmpty)
            _buildSubcategoryGrid(tab),

          // 5. Product type sections or empty state
          if (_tabCategoryProducts.isEmpty)
            SizedBox(
              height: 200.h,
              child: Center(
                child: Text(
                  'No products found',
                  style: GoogleFonts.jost(color: AppColors.hintTextColor),
                ),
              ),
            )
          else
            ..._buildProductTypeSections(tab),
        ],
      ],
    );
  }

  // ─── Tab banner image ───
  Widget _buildTabBanner(String url) {
    return ClipRRect(
      child: Image.network(
        url,
        width: double.infinity,
        height: 160.h,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }

  // ─── Quality Assurance Row ───
  Widget _buildQualityAssuranceRow() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _assuranceItem(
            Icons.currency_rupee_rounded,
            AppConfig.assurance1.replaceFirst(' ', '\n'),
          ),
          Container(
            width: 1,
            height: 32.h,
            color: AppColors.primaryColor.withValues(alpha: 0.2),
          ),
          _assuranceItem(
            Icons.verified_rounded,
            AppConfig.assurance2.replaceFirst(' ', '\n'),
          ),
          Container(
            width: 1,
            height: 32.h,
            color: AppColors.primaryColor.withValues(alpha: 0.2),
          ),
          _assuranceItem(
            Icons.loop_rounded,
            AppConfig.assurance3.replaceFirst(' ', '\n'),
          ),
        ],
      ),
    );
  }

  Widget _assuranceItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primaryColor),
        SizedBox(height: 3.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.jost(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  // ─── Subcategory square-card grid (max 8 items = 2 rows of 4) ───
  Widget _buildSubcategoryGrid(Map<String, dynamic> tab) {
    final categoryId = tab['category_id'] != null
        ? int.tryParse(tab['category_id'].toString()) ?? 0
        : 0;
    // Show max 8 subcategories (2 rows of 4, matching Blinkit)
    final subs = _tabSubCategories.take(8).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 4.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.82,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
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
                  categoryId: categoryId,
                  categoryName: sub['name']?.toString() ?? '',
                  initialSubCategoryId: subId,
                ),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
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
                ),
                SizedBox(height: 4.h),
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
    );
  }

  // ─── Group products by type and build sections ───
  List<Widget> _buildProductTypeSections(Map<String, dynamic> tab) {
    // Step 1: Collect ALL unique types present in the fetched products
    final Set<String> allFoundTypes = {};
    for (final product in _tabCategoryProducts) {
      final typesStr = product['types']?.toString() ?? '';
      for (final t in typesStr.split(',')) {
        final trimmed = t.trim();
        if (trimmed.isNotEmpty) allFoundTypes.add(trimmed);
      }
    }

    // Step 2: Admin-defined order first, then any extra types not in global list
    final orderedTypes = <String>[
      ..._productTypeNames.where((t) => allFoundTypes.contains(t)),
      ...allFoundTypes.where((t) => !_productTypeNames.contains(t)),
    ];

    // Step 3: Group products by every matching type
    final Map<String, List> grouped = {};
    final List untyped = [];

    for (final product in _tabCategoryProducts) {
      final typesStr = product['types']?.toString() ?? '';
      final productTypes = typesStr
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toSet();

      bool assigned = false;
      for (final typeName in orderedTypes) {
        if (productTypes.contains(typeName)) {
          grouped[typeName] = [...(grouped[typeName] ?? []), product];
          assigned = true;
        }
      }
      if (!assigned) untyped.add(product);
    }

    // Step 4: Build section widgets
    final sections = <Widget>[];
    for (final typeName in orderedTypes) {
      final list = grouped[typeName];
      if (list != null && list.isNotEmpty) {
        sections.add(_buildTabProductSection(typeName, list, tab));
      }
    }

    // Untyped products at the bottom
    if (untyped.isNotEmpty) {
      sections.add(_buildTabProductSection('More Products', untyped, tab));
    }

    return sections;
  }

  Widget _buildTabProductSection(
    String title,
    List products,
    Map<String, dynamic> tab,
  ) {
    final categoryId = tab['category_id'] != null
        ? int.tryParse(tab['category_id'].toString()) ?? 0
        : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.jost(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryViewScreen(
                      categoryId: categoryId,
                      categoryName: tab['name']?.toString() ?? '',
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.jost(
                        fontSize: 12.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11.sp,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        SizedBox(
          height: 240.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (ctx, i) => Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: SizedBox(
                width: 110.w,
                child: ProductCard(
                  product: products[i],
                  userId: userId,
                  onCartUpdated: () => fetchCartQuantity(userId),
                  onCategoryBack: () => fetchCartQuantity(userId),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Categories tab — grouped by parent with subcategory image cards ───
  Widget _buildCategoriesTabContent() {
    // Fallback to flat grid if grouped data not yet loaded
    final source = _categoriesWithSubs.isNotEmpty
        ? _categoriesWithSubs
        : _categoryList
              .map((c) => Map<String, dynamic>.from(c as Map))
              .toList();

    if (source.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Text(
            'No categories found',
            style: GoogleFonts.jost(color: AppColors.hintTextColor),
          ),
        ),
      );
    }

    // If we have grouped data (_categoriesWithSubs), render grouped
    if (_categoriesWithSubs.isNotEmpty) {
      final sections = <Widget>[];
      for (final cat in _categoriesWithSubs) {
        final subs = List<Map<String, dynamic>>.from(
          cat['subcategories'] as List? ?? [],
        );
        if (subs.isEmpty) continue;
        final catId = int.tryParse(cat['id'].toString()) ?? 0;

        sections.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0.h),
                child: Text(
                  cat['name']?.toString() ?? '',
                  style: GoogleFonts.jost(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 6.w,
                    mainAxisSpacing: 8.h,
                  ),
                  itemCount: subs.length,
                  itemBuilder: (ctx, i) {
                    final sub = subs[i];
                    final subId = int.tryParse(sub['id'].toString());
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
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.07,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child:
                                sub['image'] != null &&
                                    sub['image'].toString().isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Image.network(
                                      sub['image'].toString(),
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
                          SizedBox(height: 4.h),
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
              SizedBox(height: 6.h),
            ],
          ),
        );
      }
      return Column(children: sections);
    }

    // Fallback: flat 3-column grid
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
        ),
        itemCount: source.length,
        itemBuilder: (context, i) {
          final cat = source[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryViewScreen(
                  categoryId: int.tryParse(cat['id'].toString()) ?? 0,
                  categoryName: cat['name']?.toString() ?? '',
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 70.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child:
                      cat['image'] != null && cat['image'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            cat['image'].toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.category,
                              color: AppColors.primaryColor,
                              size: 28.sp,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.category,
                          color: AppColors.primaryColor,
                          size: 28.sp,
                        ),
                ),
                SizedBox(height: 4.h),
                Text(
                  cat['name']?.toString() ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jost(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    // Banner for the currently selected tab
    final currentTab = (_selectedTabIndex < _homeTabs.length)
        ? _homeTabs[_selectedTabIndex]
        : null;
    final tabBannerUrl = currentTab?['banner_image']?.toString() ?? '';
    // Header tints to the selected tab's admin-set bg_color (Blinkit-style),
    // falling back to the global primary color.
    final headerColor =
        AppColors.fromHex(currentTab?['bg_color']?.toString()) ??
        AppColors.primaryColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // ── Main scroll view ─────────────────────────────────
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── SliverAppBar ───────────────────────────────
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                // expandedHeight: tabBannerUrl.isNotEmpty ? 200.h : 130.h,
                backgroundColor: headerColor,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                elevation: 0,
                automaticallyImplyLeading: false,

                // Banner fills the expanded area
                flexibleSpace: tabBannerUrl.isNotEmpty
                    ? FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              ApiConstants.imageUrl(tabBannerUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  Container(color: AppColors.primaryColor),
                            ),
                            // Gradient overlay so title remains readable
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    headerColor.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,

                // Title: Deliver in + time
                titleSpacing: 20.w,
                title: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LocationScreen()),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Delivery In ',
                            style: GoogleFonts.jost(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ],
                      ),
                      Text(
                        deliveryTime,
                        style: GoogleFonts.leagueSpartan(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions: location + profile
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LocationScreen()),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(right: 6.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            district.isNotEmpty ? district : 'Location',
                            style: GoogleFonts.jost(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(right: 16.w),
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],

                // Search bar + tab bar pinned at bottom
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                    _homeTabs.isNotEmpty ? 92.h : 42.h,
                  ),
                  child: Container(
                    color: headerColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search bar
                        GestureDetector(
                          onTap: () async {
                            if (!mounted) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SearchProduct(),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 6.h,
                            ),
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.searchBorderHome,
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 20.sp,
                                    color: AppColors.hintTextColor,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      AppConfig.searchHint,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.jost(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.hintTextColor,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.mic,
                                    size: 18.sp,
                                    color: AppColors.hintTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Tabs
                        _buildTabBar(),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    // 1) Admin-configured layout takes priority.
                    if (_loadingLayout && _currentLayout.isEmpty) {
                      return SizedBox(
                        height: 300.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    }
                    if (_currentLayout.isNotEmpty) return _buildDynamicLayout();

                    // 2) Fallback to the built-in content per tab type.
                    if (_homeTabs.isEmpty) return _buildAllHomeContent();
                    final tab = _selectedTabIndex < _homeTabs.length
                        ? _homeTabs[_selectedTabIndex]
                        : null;
                    if (tab == null || tab['type'] == 'all') {
                      return _buildAllHomeContent();
                    }
                    if (tab['type'] == 'categories') {
                      return _buildCategoriesTabContent();
                    }
                    return _buildCategoryTabContent(tab);
                  },
                ),
              ),

              // Bottom padding for cart FAB
              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          ),

          // ── Cart FAB ───────────────────────────────────────
          if (cartList.isNotEmpty)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.slowMiddle,
              bottom: MediaQuery.of(context).padding.bottom + 10.h,
              left: 110.w,
              right: 110.w,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: InkWell(
                  onTap: () async {
                    if (!mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CartScreen()),
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
                            'View Cart',
                            style: GoogleFonts.jost(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          const Spacer(),
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

  // ─────────────────────────────────────────────────────────────
  // Admin-configured dynamic layout (driven by /tab-layout)
  // ─────────────────────────────────────────────────────────────
  Widget _buildDynamicLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        for (final s in _currentLayout) _buildLayoutSection(s as Map),
        // SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildLayoutSection(Map s) {
    switch (s['type']) {
      case 'banner':
        return _buildLayoutBanner(s);
      case 'category_grid':
      case 'brand_grid':
        return _buildLayoutGrid(s);
      case 'shop_grid':
        return _buildShopGrid(s);
      case 'product_row':
        final products = (s['products'] as List?) ?? [];
        if (products.isEmpty) return const SizedBox.shrink();
        final title = (s['title']?.toString().isNotEmpty == true)
            ? '${s['title']}${s['emoji'] != null ? ' ${s['emoji']}' : ''}'
            : 'Products';
        return buildSection(title, products);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLayoutBanner(Map s) {
    // New model: a banner section can carry one OR many banners. Fall back to
    // the legacy single image for older payloads.
    final List banners = (s['banners'] as List?) ?? [];
    final List list = banners.isNotEmpty
        ? banners
        : ((s['banner_image']?.toString() ?? '').isNotEmpty
              ? [
                  {
                    'banner_image': s['banner_image'],
                    'link_category_id': s['link_category_id'],
                  },
                ]
              : []);
    if (list.isEmpty) return const SizedBox.shrink();

    // Size/properties are admin-managed (optional). When unset, keep the app's
    // built-in defaults.
    final double height = AppConfig.bannerHeight(140).h;
    final double radius = AppConfig.bannerRadius(16).r;

    Widget tile(Map b) {
      final img = ApiConstants.imageUrl(b['banner_image']?.toString() ?? '');
      if (img.isEmpty) return const SizedBox.shrink();
      return GestureDetector(
        onTap: () {
          final catId = int.tryParse('${b['link_category_id'] ?? ''}');
          if (catId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryViewScreen(
                  categoryId: catId,
                  categoryName: s['title']?.toString() ?? 'Category',
                ),
              ),
            );
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.network(
            img,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    // Single banner → plain image. Multiple → sliding carousel.
    if (list.length == 1) {
      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 6.h),
        child: tile(list.first as Map),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: CarouselSlider(
        options: CarouselOptions(
          height: height,
          autoPlay: AppConfig.bannerAutoplay,
          viewportFraction: 0.9,
          enlargeCenterPage: false,
          autoPlayInterval: const Duration(seconds: 3),
          enableInfiniteScroll: list.length > 1,
        ),
        items: list
            .map(
              (b) => Builder(
                builder: (_) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: tile(b as Map),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLayoutGrid(Map s) {
    final items = (s['items'] as List?) ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((s['title']?.toString() ?? '').isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Text(
              s['title'],
              style: GoogleFonts.jost(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.82,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i] as Map;
              final img = item['image']?.toString() ?? '';
              final isSub = item['is_sub'] == true;
              final catId = int.tryParse('${item['category_id'] ?? ''}') ?? 0;
              final subId = isSub ? int.tryParse('${item['id'] ?? ''}') : null;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryViewScreen(
                      categoryId: catId,
                      categoryName: item['name']?.toString() ?? '',
                      initialSubCategoryId: subId,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                          image: img.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    ApiConstants.imageUrl(img),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: img.isEmpty
                            ? Icon(
                                Icons.category_outlined,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              )
                            : null,
                      ),
                    ),
                    // SizedBox(height: 4.h),
                    Text(
                      item['name']?.toString() ?? '',
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
      ],
    );
  }

  /// "Shop-wise shopping" — horizontal row of vendor shop cards.
  Widget _buildShopGrid(Map s) {
    final items = (s['items'] as List?) ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((s['title']?.toString() ?? '').isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
            child: Text(
              s['title'],
              style: GoogleFonts.jost(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        SizedBox(
          height: 116.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 12.w),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final shop = items[i] as Map;
              final logo = shop['logo']?.toString() ?? '';
              return GestureDetector(
                onTap: () {
                  final id = int.tryParse('${shop['id'] ?? ''}');
                  if (id == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopDetailScreen(
                        shopId: id,
                        shopName: shop['shop_name']?.toString(),
                        logo: logo,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 84.w,
                  margin: EdgeInsets.only(right: 10.w),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'shop-logo-${shop['id']}',
                        child: Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.08,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.lineColor),
                            image: logo.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      ApiConstants.imageUrl(logo),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: logo.isEmpty
                              ? Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primaryColor,
                                  size: 28.sp,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        shop['shop_name']?.toString() ?? '',
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),

        // Slider
        CarouselSlider(
          options: CarouselOptions(
            height: 130.h,
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 0.8,
            aspectRatio: 16 / 9,
            autoPlayInterval: Duration(seconds: 3),
            enableInfiniteScroll: true,
            scrollPhysics: BouncingScrollPhysics(),
          ),
          items: _sliderList.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: InkWell(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child:
                          item['banner_image'] != null &&
                              item['banner_image'].toString().isNotEmpty
                          ? Image.network(
                              item['banner_image'].toString(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 130.h,
                              errorBuilder: (_, _, _) =>
                                  Container(color: Colors.grey.shade200),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              height: 130.h,
                            ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryViewScreen(
                            categoryId:
                                int.tryParse(item['category_id'].toString()) ??
                                0,
                            categoryName:
                                item['category_name']?.toString() ?? 'Category',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }).toList(),
        ),

        // Category
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.only(right: 16.w, left: 16.w, top: 16.h),
          child: Row(
            children: [
              Text(
                "Category",
                style: GoogleFonts.jost(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  height: 1.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black,
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 190.h,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.72,
              ),
              itemCount: _categoryList.length,
              // itemCount: _categoryList.length > 8 ? 8 : _categoryList.length,
              itemBuilder: (context, index) {
                final item = _categoryList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryViewScreen(
                          categoryId: int.tryParse(item['id'].toString()) ?? 0,
                          categoryName: item['name']?.toString() ?? 'Category',
                        ),
                      ),
                    );
                  },

                  child: Column(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child:
                              item['image'] != null &&
                                  item['image'].toString().isNotEmpty
                              ? Image.network(
                                  item['image'].toString(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.category_outlined,
                                    color: AppColors.primaryColor,
                                    size: 24.sp,
                                  ),
                                )
                              : Icon(
                                  Icons.category_outlined,
                                  color: AppColors.primaryColor,
                                  size: 24.sp,
                                ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: 60.w,
                        child: Text(
                          item['name'] ?? '',
                          style: GoogleFonts.jost(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Products — interleaved with promo banners & subcategory rails
        SizedBox(height: 10.h),
        ..._buildInterleavedFeed(),

        // Coupons & Offers
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Text(
            'Coupons & Offers',
            style: GoogleFonts.jost(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 7.h),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 12.w),
            scrollDirection: Axis.horizontal,
            itemCount: _couponList.length,
            itemBuilder: (context, index) {
              final coupon = _couponList[index];

              final isPrivate = coupon['status'] == "Private";

              if (isPrivate) {
                // Agar private hai to skip karna hai
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  // Clipboard copy
                  Clipboard.setData(ClipboardData(text: coupon['code_name']));

                  // Toast show
                  Fluttertoast.showToast(
                    msg: "Coupon code copied!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  );
                },
                child: Container(
                  width: 280.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/coupons.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 15.w,
                          top: 6.h,
                          bottom: 4.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Coupon',
                              style: GoogleFonts.jost(
                                color: AppColors.secondaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 2.h,
                                ),
                                child: Center(
                                  child: Text(
                                    'Valid ${coupon['expri_date']}',
                                    style: GoogleFonts.jost(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.w, right: 6.w),
                        child: DottedLine(
                          dashColor: AppColors.secondaryColor,
                          lineThickness: 1.7,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 25.w,
                          right: 20.w,
                          top: 10.h,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/coupon.svg',
                                      width: 18.w,
                                      color: AppColors.secondaryColor,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      coupon['title'],
                                      style: GoogleFonts.jost(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  coupon['description'],
                                  style: GoogleFonts.jost(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 2.h,
                                ),
                                child: Center(
                                  child: Text(
                                    coupon['code_name'],
                                    style: GoogleFonts.jost(
                                      fontSize: 12.sp,
                                      color: const Color(0xffC17F06),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
            },
          ),
        ),

        SizedBox(height: 15.h),
      ],
    );
  }

  // ─── Mixed home feed: product sections interspersed with promo banners
  // and subcategory rails so the page isn't only product-type lists. ───
  List<Widget> _buildInterleavedFeed() {
    final sections = productTypeSections.entries
        .where((e) => e.value.isNotEmpty)
        .toList();
    if (sections.isEmpty) return [];

    final banners = List.from(_sliderList);
    final subCats = _categoriesWithSubs
        .where((c) => (c['subcategories'] as List?)?.isNotEmpty ?? false)
        .toList();

    int bannerIdx = 0;
    int subIdx = 0;
    int extraTurn = 0; // alternate between a banner and a subcategory rail

    final widgets = <Widget>[];
    for (int i = 0; i < sections.length; i++) {
      final e = sections[i];
      widgets.add(buildSection(e.key, e.value));

      // After every 2 product sections (but not after the last), drop in
      // either a promo banner or a subcategory rail, alternating.
      final isBreak = (i + 1) % 2 == 0 && i != sections.length - 1;
      if (!isBreak) continue;

      final wantBanner = extraTurn % 2 == 0;
      if (wantBanner && banners.isNotEmpty) {
        widgets.add(_buildInlineBanner(banners[bannerIdx++ % banners.length]));
        extraTurn++;
      } else if (subCats.isNotEmpty) {
        widgets.add(_buildSubcategoryRail(subCats[subIdx++ % subCats.length]));
        extraTurn++;
      } else if (banners.isNotEmpty) {
        widgets.add(_buildInlineBanner(banners[bannerIdx++ % banners.length]));
        extraTurn++;
      }
    }
    return widgets;
  }

  // ─── Inline promo banner (reuses an offer banner) ───
  Widget _buildInlineBanner(dynamic item) {
    final img = item['banner_image']?.toString() ?? '';
    if (img.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryViewScreen(
            categoryId: int.tryParse(item['category_id'].toString()) ?? 0,
            categoryName: item['category_name']?.toString() ?? 'Category',
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 6.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.network(
            img,
            width: double.infinity,
            height: 120.h,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  // ─── Horizontal subcategory rail for one category ───
  Widget _buildSubcategoryRail(Map<String, dynamic> cat) {
    final subs = List<Map<String, dynamic>>.from(
      cat['subcategories'] as List? ?? [],
    );
    if (subs.isEmpty) return const SizedBox.shrink();
    final catId = int.tryParse(cat['id'].toString()) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
          child: Text(
            cat['name']?.toString() ?? '',
            style: GoogleFonts.jost(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 104.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 12.w),
            itemCount: subs.length,
            itemBuilder: (ctx, i) {
              final sub = subs[i];
              final subId = int.tryParse(sub['id'].toString());
              final img = sub['image']?.toString() ?? '';
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
                child: Container(
                  width: 72.w,
                  margin: EdgeInsets.only(right: 10.w),
                  child: Column(
                    children: [
                      Container(
                        height: 64.w,
                        width: 64.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: img.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.category_outlined,
                                    color: AppColors.primaryColor,
                                    size: 24.sp,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.category_outlined,
                                color: AppColors.primaryColor,
                                size: 24.sp,
                              ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        sub['name']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jost(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSection(String title, List<dynamic> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            title,
            style: GoogleFonts.jost(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // SizedBox(height: 5.h),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            itemBuilder: (ctx, i) => Padding(
              padding: EdgeInsets.only(left: 16.w, right: i == list.length - 1 ? 16.w : 0),
              child: SizedBox(
                width: 110.w,
                child: ProductCard(
                  product: list[i],
                  userId: userId,
                  onCartUpdated: () => fetchCartQuantity(userId),
                  onCategoryBack: () => fetchCartQuantity(userId),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
