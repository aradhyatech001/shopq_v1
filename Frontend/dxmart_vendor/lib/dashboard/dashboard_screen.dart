import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/responsive.dart';
import '../utils/session_manager.dart';
import '../utils/vendor_api_helper.dart';
import '../utils/vendor_widgets.dart';

/// Vendor dashboard — admin-panel style overview built from /vendor/dashboard.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  Map<String, dynamic> _data = {};
  String _vendorName = 'Vendor';
  double _pendingPayout = 0;
  List _lowStockItems = [];

  @override
  void initState() {
    super.initState();
    _loadVendor();
    _fetch();
    _fetchExtra();
  }

  Future<void> _loadVendor() async {
    final v = await SessionManager.getVendor();
    if (v != null && mounted) {
      setState(() => _vendorName =
          (v['shop_name'] ?? v['name'] ?? 'Vendor').toString());
    }
  }

  Future<void> _fetch() async {
    if (mounted) setState(() => _loading = true);
    try {
      final res = await VendorApiHelper.get(ApiConstants.VENDOR_DASHBOARD);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _data = Map<String, dynamic>.from(data['data'] ?? {}));
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchExtra() async {
    try {
      final results = await Future.wait([
        VendorApiHelper.get(ApiConstants.VENDOR_PAYOUTS),
        VendorApiHelper.get(ApiConstants.VENDOR_LOW_STOCK),
      ]);

      final payoutData = jsonDecode(results[0].body);
      if (payoutData['success'] == true) {
        final payouts = payoutData['payouts'] as List? ?? [];
        double pending = 0;
        for (final p in payouts) {
          if ((p['status'] ?? '') == 'pending' || p['paid_at'] == null) {
            pending += double.tryParse(p['amount']?.toString() ?? '0') ?? 0;
          }
        }
        if (mounted) setState(() => _pendingPayout = pending);
      }

      final stockData = jsonDecode(results[1].body);
      if (stockData['success'] == true && mounted) {
        setState(() => _lowStockItems = stockData['items'] as List? ?? []);
      }
    } catch (_) {}
  }

  Widget _stockRow(dynamic item) {
    final name =
        '${item['product_name'] ?? ''}${(item['variant_name'] ?? '').toString().isNotEmpty ? ' – ${item['variant_name']}' : ''}';
    final stock = (item['stock'] as num?)?.toInt() ?? 0;
    final isOut = stock == 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.jost(fontSize: 13.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: (isOut ? AppColors.error : AppColors.warning)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              isOut ? 'Out of stock' : 'Stock: $stock',
              style: GoogleFonts.jost(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isOut ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final byStatus =
        Map<String, dynamic>.from(_data['orders_by_status'] ?? const {});
    final sub = _data['subscription'] as Map?;
    final cols = Responsive.isDesktop(context)
        ? 4
        : (Responsive.isTablet(context) ? 3 : 2);
        
    final statCardRatio = Responsive.isDesktop(context)
        ? 2.4
        : (Responsive.isTablet(context) ? 2.4 : 1.5);

    return VendorPage(
      title: 'Dashboard',
      subtitle: 'Welcome back, $_vendorName',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _fetch,
          icon: Icon(Icons.refresh_rounded,
              size: 20.sp, color: AppColors.textSecondary),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // ── Top stat cards ───────────────────────────
                  GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 4.h,
                    childAspectRatio: statCardRatio,
                    children: [
                      StatCard(
                        label: 'Total Products',
                        value: '${_data['products_total'] ?? 0}',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        label: 'Active Products',
                        value: '${_data['products_active'] ?? 0}',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                      StatCard(
                        label: 'Total Orders',
                        value: '${_data['orders_total'] ?? 0}',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFF7C4DFF),
                      ),
                      StatCard(
                        label: 'Revenue (delivered)',
                        value: '₹${money(_data['revenue'] ?? 0)}',
                        icon: Icons.currency_rupee_rounded,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // ── Orders by status ─────────────────────────
                  Text('Orders by status',
                      style: GoogleFonts.jost(
                          fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 10.h),
                  VCard(
                    child: Column(
                      children: [
                        _statusRow(byStatus['pending'] ?? 0, 'pending'),
                        _divider(),
                        _statusRow(byStatus['confirmed'] ?? 0, 'confirmed'),
                        _divider(),
                        _statusRow(byStatus['out_for_delivery'] ?? 0, 'out_for_delivery'),
                        _divider(),
                        _statusRow(byStatus['delivered'] ?? 0, 'delivered'),
                        _divider(),
                        _statusRow(byStatus['cancelled'] ?? 0, 'cancelled'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── Subscription ─────────────────────────────
                  Text('Subscription',
                      style: GoogleFonts.jost(
                          fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 10.h),
                  VCard(
                    child: sub == null
                        ? Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.warning, size: 20.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'No active subscription. Subscribe to add products.',
                                  style: GoogleFonts.jost(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(Icons.card_membership_rounded,
                                    color: AppColors.primary, size: 20.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${sub['plan_name'] ?? 'Plan'}',
                                        style: GoogleFonts.jost(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Expires ${sub['end_date'] ?? '—'}'
                                      '${sub['days_remaining'] != null ? '  ·  ${sub['days_remaining']} days left' : ''}',
                                      style: GoogleFonts.jost(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  // ── Pending Payout ───────────────────────────
                  if (_pendingPayout > 0) ...[
                    SizedBox(height: 20.h),
                    Text(
                      'Pending Payout',
                      style: GoogleFonts.jost(
                          fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10.h),
                    VCard(
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.success,
                                size: 20.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Earnings to be paid',
                                  style: GoogleFonts.jost(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary),
                                ),
                                Text(
                                  '₹${money(_pendingPayout)}',
                                  style: GoogleFonts.jost(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Low Stock Alerts ─────────────────────────
                  if (_lowStockItems.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Text(
                      'Low Stock Alerts',
                      style: GoogleFonts.jost(
                          fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 10.h),
                    VCard(
                      child: Column(
                        children: [
                          for (int i = 0;
                              i < _lowStockItems.length.clamp(0, 5);
                              i++) ...[
                            if (i > 0)
                              Divider(
                                  height: 1.h,
                                  color: AppColors.dividerColor),
                            _stockRow(_lowStockItems[i]),
                          ],
                          if (_lowStockItems.length > 5)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                '+${_lowStockItems.length - 5} more items',
                                style: GoogleFonts.jost(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 16.h),
                ],
              ),
            ),
    );
  }

  Widget _statusRow(dynamic count, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          VStatusChip(status: status),
          const Spacer(),
          Text('$count',
              style: GoogleFonts.jost(
                  fontSize: 15.sp, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1.h, color: AppColors.dividerColor);
}
