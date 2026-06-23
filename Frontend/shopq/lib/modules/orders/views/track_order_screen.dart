import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:shopq/modules/settings/views/help_screen.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/app/theme/app_colors.dart';
import 'package:shopq/core/utils/order_status.dart';

class TrackOrder extends StatefulWidget {
  final String status;
  final String orderId;

  const TrackOrder({
    super.key,
    required this.status,
    this.orderId = '',
  });

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {

  int currentStep = 0;
  String deliveryTime = '0';
  bool _cancelled = false;
  Timer? _pollTimer;
  List _history = [];

  @override
  void initState() {
    super.initState();
    _applyStatus(widget.status);
    fetchDeliveryTime();
    // Pull the live status and keep it fresh so vendor/admin updates show up.
    if (widget.orderId.isNotEmpty) {
      _fetchLiveStatus();
      _fetchHistory();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 12),
        (_) => _fetchLiveStatus(),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLiveStatus() async {
    try {
      final res = await ApiHelper.get(
        '${ApiConstants.GET_ALL_ORDERS}/${widget.orderId}',
        auth: true,
      );
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body);
      // getSingle → { success, order: { order: {...}, items: [...] } }
      final status = (data['order']?['order']?['status'] ??
              data['order']?['status'] ??
              '')
          .toString();
      if (status.isNotEmpty && mounted) _applyStatus(status);
    } catch (_) {}
  }


  Future<void> _fetchHistory() async {
    try {
      final id = int.tryParse(widget.orderId) ?? 0;
      if (id == 0) return;
      final res =
          await ApiHelper.get(ApiConstants.orderHistory(id), auth: true);
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _history = data['history'] as List? ?? []);
      }
    } catch (_) {}
  }

  Widget _historyItem(dynamic h) {
    final from = _hCap((h['from_status'] ?? '').toString());
    final to = _hCap((h['to_status'] ?? '').toString());
    final actor = (h['actor_type'] ?? '').toString();
    final time = _historyTime(h['created_at']?.toString());
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            margin: EdgeInsets.only(top: 5.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$from → $to',
                  style: GoogleFonts.jost(
                      fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$time · $actor',
                  style: GoogleFonts.jost(
                      fontSize: 11.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hCap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');

  String _historyTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> fetchDeliveryTime() async {
    final url = Uri.parse(ApiConstants.DELIVERY_TIME);

    try {
      final response = await ApiHelper.get(url.toString());
      final data = jsonDecode(response.body);

      if (data['success']) {
        setState(() {
          deliveryTime = data['data']['time'];
        });
      } else {
        setState(() {
          deliveryTime = 'No time found';
        });
      }
    } catch (e) {
      setState(() {
        deliveryTime = 'Error fetching time';
      });
    }
  }

  void _applyStatus(String status) {
    // Canonical mapping shared by user/admin/vendor + backend.
    final cancelled = OrderStatus.isCancelled(status);
    final step = cancelled ? currentStep : OrderStatus.step(status);
    if (mounted) {
      setState(() {
        currentStep = step;
        _cancelled = cancelled;
      });
    } else {
      currentStep = step;
      _cancelled = cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  offset: Offset(0, 4.h),
                  blurRadius: 6.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
            child: Padding(
              padding:  EdgeInsets.only(top: 10.h),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 25.h,
                      width: 28.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 7.w),
                          child: Icon(Icons.arrow_back_ios,color: AppColors.iconColor, size: 15.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    "Track Order",
                    style: GoogleFonts.jost(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Spacer(),
                  InkWell(
                    onTap: (){
                      Get.to(() => HelpScreen());
                    },
                    child: Container(
                      height: 25.h,
                      width: 28.w,
                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Center(
                        child: Icon(Icons.help_outline,color: AppColors.searchBorderHome, size: 22.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w,),

                ],
              ),
            ),
          ),

          if (_cancelled)
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'This order has been cancelled.',
                        style: GoogleFonts.jost(
                          fontSize: 13.sp,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Estimated Delivery Card
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 30.h),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 1.3.w,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      "Estimated Delivery",
                      style:
                      GoogleFonts.jost(fontSize: 12.sp, color: Colors.black),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      formatDeliveryTime(deliveryTime),
                      style: GoogleFonts.jost(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.searchBorderHome,
                      ),
                    ),
                    Text(
                      "Minutes",
                      style: GoogleFonts.jost(
                        fontSize: 16.sp,
                        color: AppColors.searchBorderHome,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Order Steps
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 40.w),
              child: ListView(
                children: [
                  orderStep(
                    stepIndex: 0,
                    icon: "🛒",
                    title: "Order Placed",
                    subtitle: "We have received your order",
                  ),
                  orderStep(
                    stepIndex: 1,
                    icon: "📦",
                    title: "Order Packed",
                    subtitle: "Your product is packed and ready to ship",
                  ),
                  orderStep(
                    stepIndex: 2,
                    icon: "🛵",
                    title: "On the way",
                    subtitle:
                    "Our delivery partner will soon deliver the product",
                  ),
                  orderStep(
                    stepIndex: 3,
                    icon: "📦",
                    title: "Product Delivered",
                    subtitle:
                    "Your order has been delivered to your provided address.",
                  ),
                  if (_history.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: Colors.grey.shade200),
                          SizedBox(height: 8.h),
                          Text(
                            'Status History',
                            style: GoogleFonts.jost(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ..._history.map((h) => _historyItem(h)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget orderStep({
    required int stepIndex,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    bool isCompleted = stepIndex <= currentStep;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step line and circle
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.searchBorderHome : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: AppColors.backgroundColor, size: 16.sp)
                  : null,
            ),
            if (stepIndex != 3)
              Container(
                width: 3.w,
                height: 70.h,
                color:
                stepIndex < currentStep ? Colors.orange : Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 15.w),

        // Step content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: GoogleFonts.jost(fontSize: 18.sp)),
                  SizedBox(width: 6.w),
                  Text(
                    title,
                    style: GoogleFonts.jost(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style:
                GoogleFonts.jost(fontSize: 12.sp, color: Colors.black54),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
  String formatDeliveryTime(String input) {
    input = input.replaceAll(' ', '');
    final match = RegExp(r'^(\d+)([a-zA-Z]+)').firstMatch(input);

    if (match != null) {
      final number = match.group(1) ?? '';
      final unit = match.group(2)?.substring(0, 0).toUpperCase() ?? '';
      return '$number $unit';
    } else {
      return input.substring(0, input.length.clamp(0, 6)).toUpperCase();
    }
  }
}