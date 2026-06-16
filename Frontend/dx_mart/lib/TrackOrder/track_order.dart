import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


import '../Help/help_screen.dart';
import '../utils/api_constants.dart';
import '../utils/api_helper.dart';
import '../utils/colors.dart';
import '../utils/order_status.dart';

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

  @override
  void initState() {
    super.initState();
    _applyStatus(widget.status);
    fetchDeliveryTime();
    // Pull the live status and keep it fresh so vendor/admin updates show up.
    if (widget.orderId.isNotEmpty) {
      _fetchLiveStatus();
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


  Future<void> fetchDeliveryTime() async {
    final url = Uri.parse(ApiConstants.DELIVERY_TIME);

    try {
      final response = await http.get(url);
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
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>HelpScreen()));
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
