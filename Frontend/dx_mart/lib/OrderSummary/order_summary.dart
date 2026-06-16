import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../utils/api_constants.dart';
import '../utils/colors.dart';

class OrderSummary extends StatelessWidget {
  final Map orderMap;
  const OrderSummary({super.key, required this.orderMap});

  @override
  Widget build(BuildContext context) {
    final orderData = orderMap["order"] ?? {};
    final orderItems = (orderMap["items"] ?? []) as List;

    final finalAmount =
        double.tryParse(orderData['final_amount']?.toString() ?? "0") ?? 0;
    final itemsTotal =
        double.tryParse(orderData['total_amount']?.toString() ?? "0") ??
        finalAmount;
    final discount =
        double.tryParse(orderData['discount_amount']?.toString() ?? "0") ?? 0;
    final handling =
        double.tryParse(orderData['handling_charge']?.toString() ?? "0") ?? 0;
    final delivery =
        double.tryParse(orderData['delivery_charge']?.toString() ?? "0") ?? 0;
    final delivery_date = orderData['delivery_date']?.toString() ?? "";
    final gift = orderData['gift']?.toString() ?? "";
    final delivery_time = orderData['delivery_time']?.toString() ?? "";

    final rawDate = delivery_date.toString();
    // Backend stores delivery_date as "15 Jun 2025" (from DateFormat("dd MMM yyyy"))
    // DateTime.tryParse only handles ISO 8601, so parse manually with intl
    String formattedDate;
    try {
      final parsedDate = DateFormat("dd MMM yyyy").parse(rawDate);
      formattedDate = DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (_) {
      formattedDate = rawDate; // fallback: show raw string if parsing fails
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10.h),
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
                    "Order Summary",
                    style: GoogleFonts.jost(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // The rest of the content should be wrapped in an Expanded and SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Arrived at $formattedDate",
                            style: GoogleFonts.jost(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // agar jagah kam ho to ...
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          "•",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            "$delivery_time",
                            style: GoogleFonts.jost(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "${orderItems.length} items in this order",
                      style: GoogleFonts.jost(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Padding(
                    padding: EdgeInsets.all(14.h),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.gray, width: 1.4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Items List
                          ...orderItems.map((item) {
                            final price =
                                double.tryParse(
                                  item['selling_price']?.toString() ?? "0",
                                ) ??
                                0;
                            final mrp =
                                double.tryParse(
                                  item['price']?.toString() ?? "0",
                                ) ??
                                price;

                            final variantPrice =
                                double.tryParse(
                                  item?['price']?.toString() ?? "0",
                                ) ??
                                0;
                            final variantSellingPrice =
                                double.tryParse(
                                  item?['selling_price']?.toString() ?? "0",
                                ) ??
                                0;

                            final discountPercentage =
                                (variantPrice > 0 && variantSellingPrice > 0)
                                ? (((variantPrice - variantSellingPrice) /
                                              variantPrice) *
                                          100)
                                      .round()
                                : 0;

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 0.w,
                                vertical: 0.h,
                              ),
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 50.h,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 0.1,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            5.r,
                                          ),
                                          child: Center(
                                            child: Image.network(
                                              ApiConstants.imageUrl(
                                                item['image_url'] ??
                                                    item['image'] ??
                                                    "",
                                              ),
                                              width: 40.w,
                                              height: 40.h,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, _, _) =>
                                                  Icon(
                                                    Icons.image,
                                                    size: 24.sp,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 3.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryColor,
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(
                                                10.r,
                                              ),
                                              topLeft: Radius.circular(4.r),
                                            ),
                                          ),
                                          child: Text(
                                            '$discountPercentage%\nOFF',
                                            style: GoogleFonts.jost(
                                              fontSize: 5.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.primaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['product_name'] ?? "",
                                          style: GoogleFonts.jost(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              item['variant_name']
                                                      ?.toString() ??
                                                  "",
                                              style: GoogleFonts.jost(
                                                fontSize: 12.sp,
                                                color: Colors.black54,
                                              ),
                                            ),

                                            Text(
                                              " x ",
                                              style: GoogleFonts.jost(
                                                fontSize: 13.sp,
                                                color: Colors.black54,
                                              ),
                                            ),

                                            Text(
                                              item['quantity']?.toString() ??
                                                  "",
                                              style: GoogleFonts.jost(
                                                fontSize: 12.sp,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 11.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₹${price.toStringAsFixed(0)}",
                                        style: GoogleFonts.jost(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "₹${mrp.toStringAsFixed(0)}",
                                        style: GoogleFonts.jost(
                                          fontSize: 12.sp,
                                          color: Colors.black54,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.gray, width: 1.4),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bill Details",
                              style: GoogleFonts.jost(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Divider(),
                            SizedBox(height: 10.h),
                            _billRow(
                              "Items total",
                              "₹${itemsTotal.toStringAsFixed(0)}",
                            ),
                            _billRow(
                              "Handing Charge",
                              "₹${handling.toStringAsFixed(0)}",
                            ),
                            _billRow(
                              "Delivery Charge",
                              delivery == 0
                                  ? "Free"
                                  : "₹${delivery.toStringAsFixed(0)}",
                            ),
                            _billRow(
                              "Discount",
                              "₹${discount.toStringAsFixed(0)}",
                              valueColor: Colors.green,
                            ),
                            Divider(),
                            _billRow(
                              "Total",
                              "₹${finalAmount.toStringAsFixed(0)}",
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ), // Add some space at the bottom for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(
    String title,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.jost(
              fontSize: 13.sp,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jost(
              fontSize: 13.sp,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
