import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_screen.dart';
import '../subscription/subscription_screen.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/vendor_api_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map? _vendor;
  Map? _subscription;
  List _recentOrders = [];
  int _productCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    if (!await VendorApiHelper.isLoggedIn()) {
      _goLogin();
      return;
    }

    try {
      // Profile
      final pRes  = await VendorApiHelper.get(ApiConstants.VENDOR_PROFILE);
      final pData = jsonDecode(pRes.body);
      if (pData['success'] == true) {
        final v = pData['vendor'];
        setState(() {
          _vendor = v;
          _subscription = v['active_subscription'];
        });
      }

      // Products count
      final prRes  = await VendorApiHelper.get(ApiConstants.VENDOR_PRODUCTS);
      final prData = jsonDecode(prRes.body);
      if (prData['success'] == true) {
        setState(() => _productCount = (prData['products'] as List).length);
      }

      // Orders (first 5)
      final oRes  = await VendorApiHelper.get(ApiConstants.VENDOR_ORDERS);
      final oData = jsonDecode(oRes.body);
      if (oData['success'] == true) {
        final orders = (oData['orders'] as List);
        setState(() => _recentOrders = orders.take(5).toList());
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),
                    SizedBox(height: 20.h),
                    _buildSubscriptionBanner(),
                    SizedBox(height: 16.h),
                    _buildStatsRow(),
                    SizedBox(height: 20.h),
                    _buildRecentOrders(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: GoogleFonts.jost(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _vendor?['name'] ?? 'Vendor',
                style: GoogleFonts.jost(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: _vendor?['status'] == 'approved'
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: _vendor?['status'] == 'approved'
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _vendor?['status'] == 'approved'
                    ? Icons.verified_rounded
                    : Icons.pending_rounded,
                size: 13.sp,
                color: _vendor?['status'] == 'approved'
                    ? AppColors.success
                    : AppColors.warning,
              ),
              SizedBox(width: 4.w),
              Text(
                (_vendor?['status'] ?? 'pending').toString().toUpperCase(),
                style: GoogleFonts.jost(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: _vendor?['status'] == 'approved'
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: Icon(Icons.refresh_rounded,
              color: AppColors.textSecondary, size: 20.sp),
          onPressed: _loadData,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildSubscriptionBanner() {
    if (_subscription != null) {
      final daysLeft = _subscription!['days_remaining'] ?? 0;
      final isLow = daysLeft <= 7;
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLow
                  ? [Colors.orange[700]!, Colors.orange[400]!]
                  : [AppColors.primary, AppColors.accent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Icon(Icons.card_membership_rounded, color: Colors.white, size: 28.sp),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subscription!['plan_name'] ?? 'Active Plan',
                      style: GoogleFonts.jost(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      '$daysLeft days remaining · Expires ${_subscription!['end_date']}',
                      style: GoogleFonts.jost(color: Colors.white70, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14.sp),
            ],
          ),
        ),
      );
    }
    // No subscription
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.warning.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Subscription',
                    style: GoogleFonts.jost(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    'Subscribe to start selling',
                    style: GoogleFonts.jost(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary, size: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() => Row(
    children: [
      _statCard(Icons.inventory_2_rounded, '$_productCount', 'Products', AppColors.primary),
      SizedBox(width: 12.w),
      _statCard(Icons.receipt_long_rounded, '${_recentOrders.length}', 'Recent Orders', AppColors.accent),
      SizedBox(width: 12.w),
      _statCard(
        _vendor?['status'] == 'approved' ? Icons.verified_rounded : Icons.pending_rounded,
        _vendor?['status']?.toString().toUpperCase() ?? 'N/A',
        'Status',
        _vendor?['status'] == 'approved' ? AppColors.success : AppColors.warning,
      ),
    ],
  );

  Widget _statCard(IconData icon, String value, String label, Color color) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22.sp),
              SizedBox(height: 8.h),
              Text(
                value,
                style: GoogleFonts.jost(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: GoogleFonts.jost(fontSize: 10.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );

  Widget _buildRecentOrders() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Recent Orders',
        style: GoogleFonts.jost(fontWeight: FontWeight.w600, fontSize: 15.sp),
      ),
      SizedBox(height: 10.h),
      if (_recentOrders.isEmpty)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'No orders yet',
              style: GoogleFonts.jost(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ),
        )
      else
        ..._recentOrders.map((o) => _orderTile(o)),
    ],
  );

  Widget _orderTile(Map order) {
    Color statusColor;
    switch (order['status'] ?? '') {
      case 'delivered':
        statusColor = AppColors.success;
        break;
      case 'pending':
        statusColor = AppColors.warning;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.primary;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order['id']}',
                style: GoogleFonts.jost(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                order['user']?['name'] ?? 'Customer',
                style: GoogleFonts.jost(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              if (order['created_at'] != null)
                Text(
                  order['created_at'].toString().length >= 10
                      ? order['created_at'].toString().substring(0, 10)
                      : order['created_at'].toString(),
                  style: GoogleFonts.jost(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(order['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                style: GoogleFonts.jost(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  (order['status'] ?? 'pending').toString().toUpperCase(),
                  style: GoogleFonts.jost(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
