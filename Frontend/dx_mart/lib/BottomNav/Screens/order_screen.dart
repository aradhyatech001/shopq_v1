import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../OrderSummary/order_summary.dart';
import '../../TrackOrder/track_order.dart';
import '../../utils/api_constants.dart';
import '../../utils/colors.dart';
import '../../utils/order_status.dart';
import '../bottomNavScreen.dart';
import '../../utils/api_helper.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool isLoading = true;
  List orders = [];

  late final TabController _tabController;
  String userName = "";
  String userEmail = "";
  String userId = "";

  // Silent polling so a status change made by the vendor/admin shows up here
  // without the user having to pull-to-refresh.
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    fetchUserData();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted && userId.isNotEmpty) fetchOrders(userId, silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh as soon as the user comes back to the app.
    if (state == AppLifecycleState.resumed && userId.isNotEmpty) {
      fetchOrders(userId, silent: true);
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
        fetchOrders(userId);
      }
    }
  }

  Future<void> fetchOrders(String userid, {bool silent = false}) async {
    try {
      final response = await ApiHelper.post(ApiConstants.GET_ORDER_BY_USER, body: {"user_id": userId.toString()}, auth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          orders = (data["orders"] ?? []) as List;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted && !silent) setState(() => isLoading = false);
    }
  }

  bool _isCompleteStatus(String? statusRaw) => OrderStatus.isComplete(statusRaw);

  void _showRatingBottomSheet(String orderId) {
    int rating = 0;
    TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.w,
                right: 16.w,
                top: 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Rate Your Order',
                      style: GoogleFonts.jost(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Text(
                      'How was your experience with order #$orderId?',
                      style: GoogleFonts.jost(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            size: 30.sp,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Add Comment (Optional)',
                    style: GoogleFonts.jost(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onPressed: () {
                        // Handle submit rating
                        debugPrint('Rating: $rating');
                        debugPrint('Comment: ${commentController.text}');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thank you for your rating!')),
                        );
                      },
                      child: Text(
                        'Submit',
                        style: GoogleFonts.jost(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = orders
        .where((o) => !_isCompleteStatus((o["order"]?["status"]).toString()))
        .toList();
    final completeOrders = orders
        .where((o) => _isCompleteStatus((o["order"]?["status"]).toString()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          SizedBox(height: 17.h),
          // Header
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
              padding: EdgeInsets.only(top: 12.h),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomNavScreen(),
                        ),
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
                    "My Order",
                    style: GoogleFonts.jost(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),
          _Tabs(tabController: _tabController),
          SizedBox(height: 8.h),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _OrderList(
                        orders: activeOrders,
                        emptyText: "No active orders",
                        buildCard: _buildActiveOrderCard,
                      ),
                      _OrderList(
                        orders: completeOrders,
                        emptyText: "No completed orders",
                        buildCard: _buildCompletedOrderCard,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(Map orderMap) {
    final orderData = orderMap["order"] ?? {};
    final orderItems = (orderMap["items"] ?? []) as List;

    final finalAmount =
        orderData['final_amount'] ??
        orderData['grand_total'] ??
        orderData['amount'] ??
        '';
    final orderId =
        orderData['id']?.toString() ?? orderData['order_id']?.toString() ?? '';
    final createdAt =
        orderData['order_datetime']?.toString() ??
        orderData['order_date']?.toString() ??
        '';
    final status = orderData['status']?.toString() ?? '';
    final itemCount = orderItems.fold<int>(
      0,
      (sum, it) => sum + (int.tryParse(it['quantity']?.toString() ?? '0') ?? 0),
    );
    final images = orderItems
        .map<String>((it) => (it['image_url'] ?? it['image'] ?? '').toString())
        .where((u) => u.isNotEmpty)
        .toList();

    final showImages = images.take(2).toList();
    final extraCount = images.length > 3
        ? images.length - 2
        : (images.length == 3 ? 1 : 0);

    // Date formatting
    String dateText = '';
    String timeText = '';
    try {
      DateTime parsedDate = DateFormat("dd-MM-yyyy hh:mm a").parse(createdAt);
      dateText = DateFormat("dd MMM").format(parsedDate);
      timeText = DateFormat("hh:mm a").format(parsedDate);
    } catch (e) {
      debugPrint("Date parsing error: $e");
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSummary(orderMap: orderMap),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFECECEC)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "$itemCount Items",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Order id - #000$orderId",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Text(
                        '₹${(double.tryParse(finalAmount) ?? 0).toStringAsFixed(0)}',
                        style: GoogleFonts.jost(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "•",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        dateText,
                        style: GoogleFonts.jost(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "•",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        timeText,
                        style: GoogleFonts.jost(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      ...showImages.map((url) => _Thumb(url: url)),
                      if (images.length >= 3)
                        _ThirdThumbWithOverlay(
                          url: images[2],
                          overlayText: extraCount > 0 ? "+$extraCount" : null,
                        ),
                      Spacer(),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackOrder(status: status, orderId: orderData["id"]?.toString() ?? ""),
                            ),
                          );
                        },
                        child: Container(
                          width: 120.w,
                          height: 27.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Center(
                            child: Text(
                              'Track Order',
                              style: GoogleFonts.jost(
                                fontSize: 11.sp,
                                color: AppColors.primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedOrderCard(Map orderMap) {
    final orderData = orderMap["order"] ?? {};
    final orderItems = (orderMap["items"] ?? []) as List;

    final finalAmount =
        orderData['final_amount'] ??
        orderData['grand_total'] ??
        orderData['amount'] ??
        '';
    final orderId =
        orderData['id']?.toString() ?? orderData['order_id']?.toString() ?? '';
    final createdAt =
        orderData['order_datetime']?.toString() ??
        orderData['order_date']?.toString() ??
        '';
    final status = orderData['status']?.toString() ?? '';
    final itemCount = orderItems.fold<int>(
      0,
      (sum, it) => sum + (int.tryParse(it['quantity']?.toString() ?? '0') ?? 0),
    );
    final images = orderItems
        .map<String>((it) => (it['image_url'] ?? it['image'] ?? '').toString())
        .where((u) => u.isNotEmpty)
        .toList();

    final showImages = images.take(2).toList();
    final extraCount = images.length > 3
        ? images.length - 2
        : (images.length == 3 ? 1 : 0);

    // Date formatting
    String dateText = '';
    String timeText = '';
    try {
      DateTime parsedDate = DateFormat("dd-MM-yyyy hh:mm a").parse(createdAt);
      dateText = DateFormat("dd MMM").format(parsedDate);
      timeText = DateFormat("hh:mm a").format(parsedDate);
    } catch (e) {
      debugPrint("Date parsing error: $e");
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackOrder(status: status, orderId: orderData["id"]?.toString() ?? ""),
                    ),
                  );
                },
                child: Container(
                  width: 35.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF38A169).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(Icons.check, color: AppColors.successColor),
                ),
              ),

              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "$itemCount Items",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Order id - #000$orderId",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Text(
                          '₹${(double.tryParse(finalAmount) ?? 0).toStringAsFixed(0)}',
                          style: GoogleFonts.jost(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "•",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          dateText,
                          style: GoogleFonts.jost(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "•",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          timeText,
                          style: GoogleFonts.jost(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              ...showImages.map((url) => _Thumb(url: url)),
              if (images.length >= 3)
                _ThirdThumbWithOverlay(
                  url: images[2],
                  overlayText: extraCount > 0 ? "+$extraCount" : null,
                ),
              Spacer(),

              InkWell(
                onTap: () => _showRatingBottomSheet(orderId),
                child: Container(
                  width: 100.w,
                  height: 27.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.r),
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 1.7.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Rate Now',
                      style: GoogleFonts.jost(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================== SMALL WIDGETS ===================

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: TabBar(
        controller: tabController,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3.w, color: AppColors.primaryColor),
          insets: EdgeInsets.zero,
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        tabs: [
          Tab(
            child: Text(
              'Active',
              style: GoogleFonts.jost(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Tab(
            child: Text(
              'Complete',
              style: GoogleFonts.jost(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.emptyText,
    required this.buildCard,
  });

  final List orders;
  final String emptyText;
  final Widget Function(Map order) buildCard;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(emptyText, style: TextStyle(fontSize: 14.sp)),
      );
    }
    return RefreshIndicator(
      onRefresh: () async =>
          await Future.delayed(const Duration(milliseconds: 400)),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: orders.length,
        itemBuilder: (_, i) => buildCard(orders[i] as Map),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConstants.imageUrl(url);
    return Container(
      width: 40.w,
      height: 40.w,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 0.1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: resolved.isEmpty
          ? const Icon(Icons.image_not_supported_outlined)
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                resolved,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
    );
  }
}

class _ThirdThumbWithOverlay extends StatelessWidget {
  const _ThirdThumbWithOverlay({required this.url, this.overlayText});
  final String url;
  final String? overlayText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Thumb(url: url),
        if (overlayText != null)
          Positioned(
            child: Container(
              width: 40.w,
              height: 35.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                overlayText!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
