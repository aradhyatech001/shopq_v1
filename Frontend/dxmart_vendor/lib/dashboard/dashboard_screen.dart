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

  @override
  void initState() {
    super.initState();
    _loadVendor();
    _fetch();
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

  @override
  Widget build(BuildContext context) {
    final byStatus =
        Map<String, dynamic>.from(_data['orders_by_status'] ?? const {});
    final sub = _data['subscription'] as Map?;
    final cols = Responsive.isDesktop(context)
        ? 4
        : (Responsive.isTablet(context) ? 3 : 2);

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
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    // childAspectRatio: 1.35,
                    childAspectRatio: 1.5,
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
