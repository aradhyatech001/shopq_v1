// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shopq/modules/home/widgets/motion.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/core/storage/storage_service.dart';
import 'package:lottie/lottie.dart';

import 'package:shopq/modules/address/views/address_screen.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/firebase/firebase_service.dart';
import 'package:shopq/app/theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final double saveAmount;
  final double finalWithCharge;
  final String userId;
  final String userEmail;
  final String userName;
  final String giftName;
  final double deliveyCharge;
  final double handlingCharge;
  final String coupon_code_name;

  CheckoutScreen({super.key, 
    required this.saveAmount,
    required this.finalWithCharge,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.giftName,
    required this.deliveyCharge,
    required this.handlingCharge,
    required this.coupon_code_name,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late DateTime selectedMonth;
  DateTime? selectedDate;
  String fullAddress = "";
  String location_id = "";
  int selectedIndex = 1;
  String selectedTimeSlot = '';
  String selectedPaymentMethod = 'cod'; // 'cod' or 'upi'
  String selectedUpiApp = ''; // For storing selected UPI app
  bool _isPlacingOrder = false; // Track if order is being placed

  List<DateTime> localDates = [];

  final List<String> timeSlots = ['6 AM - 8 AM', '9 AM - 2 PM', '2 PM - 8 PM'];

  // UPI apps data
  final List<Map<String, dynamic>> upiApps = [
    {
      'name': 'PhonePe UPI',
      'icon': 'assets/images/phonepe.png',
      'id': 'phonepe',
    },
    {'name': 'Google Pay UPI', 'icon': 'assets/images/gpay.png', 'id': 'gpay'},
    {'name': 'Paytm UPI', 'icon': 'assets/images/paytm.png', 'id': 'paytm'},
    {
      'name': 'Add new UPI ID',
      'icon': 'assets/images/upi.png',
      'id': 'new_upi',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    selectedDate = DateTime.now();
    selectedTimeSlot = timeSlots[selectedIndex];

    // Default to whichever payment method the admin has enabled.
    if (AppConfig.codEnabled) {
      selectedPaymentMethod = 'cod';
    } else if (AppConfig.onlineEnabled) {
      selectedPaymentMethod = 'upi';
    }

    // Initialize localDates with current month days
    _updateLocalDates();
    _loadSelectedAddress();
  }

  // Update local dates based on selected month
  void _updateLocalDates() {
    final daysInMonth = DateUtils.getDaysInMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    localDates = List.generate(
      daysInMonth,
          (index) => DateTime(selectedMonth.year, selectedMonth.month, index + 1),
    );

    // Filter out past dates (only keep today and future dates)
    final today = DateTime.now();
    localDates =
        localDates.where((date) {
          return date.isAfter(
            today.subtract(Duration(days: 1)),
          ); // Include today
        }).toList();
  }

  // Listen for address updates when returning to this screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSelectedAddress();
  }

  Future<void> _loadSelectedAddress() async {
    setState(() {
      location_id = AppStorage.selectedAddressId;
      fullAddress = AppStorage.selectedAddressFull;
    });
  }

  Future<void> placeOrder({
    required String userId,
    required String couponCode,
    required double discountAmount,
    required double deliveryCharge,
    required double handlingCharge,
    required String paymentMethod,
    required String deliveryDate,
    required String deliverTime,
    required String dateTimeNow,
    required String locationId,
    required double famount,
    required BuildContext context,
  }) async {
    // Validate address
    if (locationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true; // Show progress indicator
    });

    final url = Uri.parse(ApiConstants.PLACE_ORDER);

    final body = {
      "user_id": userId,
      "coupon_code":
          (couponCode.trim().isEmpty || couponCode.trim().toLowerCase() == 'null')
              ? null
              : couponCode.trim(),
      "discount_amount": discountAmount.toString(),
      "delivery_charge": deliveryCharge.toString(),
      "handling_charge": handlingCharge.toString(),
      "payment_method": paymentMethod,
      "dateTimeNow": dateTimeNow,
      "deliveryDate": deliveryDate,
      "deliverTime": deliverTime,
      "location_id": locationId,
      "famount": famount.toString(),
      "gift" : widget.giftName.toString(),
      "user_email" : widget.userEmail.toString(),
      "user_name" : widget.userName.toString(),
    };

    try {
      final response = await ApiHelper.postJson(url.toString(), body: body, auth: true);

      final data = jsonDecode(response.body);

      setState(() {
        _isPlacingOrder = false; // Hide progress indicator
      });

      if (data['success'] == true) {
        debugPrint("✅ Order placed successfully!");

        // Clear cart or perform other success actions here

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/success.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Your Order Has Been\nSuccessfully Placed",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jost(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  InkWell(
                    onTap: () => Get.offAllNamed(AppRoutes.orders),
                    child: Container(
                      width: 120.w,
                      height: 27.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View Order',
                              style: GoogleFonts.jost(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            SvgPicture.asset(
                              'assets/svg/arrow.svg',
                              color: AppColors.primaryTextColor,
                              width: 15.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        debugPrint("❌ Failed: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isPlacingOrder = false; // Hide progress indicator on error
      });

      debugPrint("⚠️ Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + offset,
        1,
      );
      _updateLocalDates();

      // By default select first available date of month
      if (localDates.isNotEmpty) {
        selectedDate = localDates.first;
      }
    });
  }

  bool isDayAvailable(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return normalizedDate.isAtSameMomentAs(normalizedToday) ||
        normalizedDate.isAfter(normalizedToday);
  }

  void updateSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 17.h),

              // Header
              Container(
                width: double.infinity,
                height: 55.h,
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
                              size: 15.sp,
                              color: AppColors.iconColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      "Checkout",
                      style: GoogleFonts.jost(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    SizedBox(width: 20.w),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 14.h),

                      // Location Box
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 21.w),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location Icon
                              Icon(
                                Icons.location_on,
                                color: AppColors.primaryColor,
                                size: 24.sp,
                              ),
                              SizedBox(width: 10.w),

                              // Address Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Delivery Address",
                                      style: GoogleFonts.jost(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      fullAddress.isNotEmpty
                                          ? fullAddress
                                          : "No address selected",
                                      style: GoogleFonts.jost(
                                        fontSize: 13.sp,
                                        color:
                                        fullAddress.isNotEmpty
                                            ? Colors.grey[700]
                                            : Colors
                                            .red, // Highlight when no address
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Edit Icon Button
                              GestureDetector(
                                onTap: () async {
                                  if (!mounted) return;
                                  await Get.to(() => DeliveryAddressScreen());
                                  // Reload address after returning
                                  _loadSelectedAddress();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 18.sp,
                                    color: AppColors.iconColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Date And time
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 21.w),
                        child: Text(
                          'Select date & time',
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 10.w),
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, size: 15.sp),
                            onPressed: () => changeMonth(-1),
                          ),
                          Text(
                            DateFormat.yMMM().format(selectedMonth),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 15.sp),
                            onPressed: () => changeMonth(1),
                          ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 16.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 7.h),
                            // Date list
                            SizedBox(
                              height: 55.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: localDates.length,
                                itemBuilder: (context, index) {
                                  final date = localDates[index];
                                  final isSelected =
                                      selectedDate?.day == date.day &&
                                          selectedDate?.month == date.month &&
                                          selectedDate?.year == date.year;
                                  final isAvailable = isDayAvailable(date);

                                  return GestureDetector(
                                    onTap:
                                    isAvailable
                                        ? () => updateSelectedDate(date)
                                        : null,
                                    child: Container(
                                      width: isSelected ? 45.w : 40.w,
                                      height: isSelected ? 70.h : 75.h,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                        isSelected
                                            ? AppColors.primaryColor
                                            : isAvailable
                                            ? Colors.grey[200]
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('E').format(date),
                                            style: GoogleFonts.jost(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color:
                                              isSelected
                                                  ? AppColors
                                                  .primaryTextColor
                                                  : isAvailable
                                                  ? Colors.black54
                                                  : Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            date.day.toString().padLeft(2, '0'),
                                            style: GoogleFonts.jost(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                              isSelected
                                                  ? AppColors
                                                  .primaryTextColor
                                                  : isAvailable
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.only(left: 10.w, right: 21.w),
                              child: Container(
                                width: double.infinity,
                                height: 1.h,
                                color: const Color(0xffDDE0DF),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),

                      // Time Slot
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Row(
                          children: List.generate(timeSlots.length, (index) {
                            return Expanded(
                              child: SizedBox(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      selectedTimeSlot = timeSlots[index];
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                    ),
                                    child: Container(
                                      height: 26.h,
                                      decoration: BoxDecoration(
                                        color:
                                        selectedIndex == index
                                            ? AppColors.primaryColor
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          timeSlots[index],
                                          style: GoogleFonts.jost(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color:
                                            selectedIndex == index
                                                ? AppColors.primaryTextColor
                                                : AppColors
                                                .primaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: 15.h),

                      // Payment Methods Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 21.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: GoogleFonts.jost(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // UPI Payment Option (admin-controlled)
                            if (AppConfig.onlineEnabled) ...[
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                  selectedPaymentMethod == 'upi'
                                      ? AppColors.primaryColor
                                      : AppColors.lineColor,
                                  width:
                                  selectedPaymentMethod == 'upi'
                                      ? 1.5.w
                                      : 1.w,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedPaymentMethod = 'upi';
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: 'upi',
                                            groupValue: selectedPaymentMethod,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedPaymentMethod = value!;
                                              });
                                            },
                                            activeColor: AppColors.primaryColor,
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            'Pay by any UPI Apps',
                                            style: GoogleFonts.jost(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (selectedPaymentMethod == 'upi') ...[
                                      SizedBox(height: 10.h),
                                      Column(
                                        children:
                                        upiApps.map((app) {
                                          return Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedUpiApp =
                                                    app['id'];
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 5.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Radio<String>(
                                                        value: app['id'],
                                                        groupValue: selectedUpiApp,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedUpiApp =
                                                            value!;
                                                          });
                                                        },
                                                        activeColor:
                                                        AppColors
                                                            .primaryColor,
                                                      ),
                                                      SizedBox(width: 5.w),
                                                      Container(
                                                        width: 44.w,
                                                        height: 21.h,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                            AppColors
                                                                .lineColor,
                                                            width: 1.w,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            5.r,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                            3.0.w,
                                                          ),
                                                          child:
                                                          Image.asset(
                                                            app['icon'],
                                                            width: 20.w,
                                                            height:
                                                            20.h,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15.w),
                                                      Text(
                                                        app['name'],
                                                        style:
                                                        GoogleFonts.jost(
                                                          fontSize:
                                                          12.sp,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (app != upiApps.last)
                                                Divider(
                                                  height: 1.h,
                                                  color: Colors.grey,
                                                ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 15.h),
                            ],

                            // COD Payment Option (admin-controlled)
                            if (AppConfig.codEnabled)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                  selectedPaymentMethod == 'cod'
                                      ? AppColors.primaryColor
                                      : AppColors.lineColor,
                                  width:
                                  selectedPaymentMethod == 'cod'
                                      ? 1.5.w
                                      : 1.w,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPaymentMethod = 'cod';
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: 'cod',
                                        groupValue: selectedPaymentMethod,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPaymentMethod = value!;
                                          });
                                        },
                                        activeColor: AppColors.primaryColor,
                                      ),
                                      SizedBox(width: 5.w),
                                      Container(
                                        width: 44.w,
                                        height: 21.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.lineColor,
                                            width: 1.w,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            5.r,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(3.0.w),
                                          child: Image.asset(
                                            'assets/images/case.png',
                                            width: 20.w,
                                            height: 20.h,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15.w),
                                      Text(
                                        'Cash on Delivery',
                                        style: GoogleFonts.jost(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // No payment methods enabled by admin
                            if (!AppConfig.codEnabled && !AppConfig.onlineEnabled)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Text(
                                  'No payment method is currently available. Please try again later.',
                                  style: GoogleFonts.jost(
                                    fontSize: 12.sp,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom total section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0.h,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Price',
                            style: GoogleFonts.jost(fontSize: 10.sp),
                          ),
                          Text(
                            '₹${widget.finalWithCharge.toStringAsFixed(0)}',
                            style: GoogleFonts.jost(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16.sp,
                                color: Colors.green,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'You Save ₹${widget.saveAmount <= 0 ? "0" : widget.saveAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.jost(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      PressableScale(
                        onTap: () {
                          if (location_id.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select a delivery address first',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Guard against a method the admin has disabled.
                          if (selectedPaymentMethod == 'upi' &&
                              !AppConfig.onlineEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Online payment is not available'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (selectedPaymentMethod == 'cod' &&
                              !AppConfig.codEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cash on Delivery is not available'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          placeOrder(
                            userId: widget.userId,
                            couponCode: widget.coupon_code_name,
                            discountAmount: widget.saveAmount,
                            deliveryCharge: widget.deliveyCharge,
                            handlingCharge: widget.handlingCharge,
                            paymentMethod:
                                selectedPaymentMethod == 'upi' ? 'UPI' : 'COD',
                            deliveryDate: selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                                : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            deliverTime: selectedTimeSlot,
                            dateTimeNow: DateFormat(
                              'dd-MM-yyyy hh:mm a',
                            ).format(DateTime.now()),
                            locationId: location_id,
                            famount: widget.finalWithCharge,
                            context: context,
                          );
                        },
                        child: Container(
                          width: 170.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color:
                            location_id.isEmpty
                                ? Colors
                                .grey // Gray out if no address
                                : AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Place Order',
                                  style: GoogleFonts.jost(
                                    color: AppColors.primaryTextColor,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                SvgPicture.asset(
                                  'assets/svg/arrow.svg',
                                  height: 12.h,
                                  color: AppColors.primaryTextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Order placement progress indicator
          if (_isPlacingOrder)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'Placing Order...',
                        style: GoogleFonts.jost(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}