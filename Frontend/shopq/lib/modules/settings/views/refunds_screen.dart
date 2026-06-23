import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/app/theme/app_colors.dart';

class MyRefundsScreen extends StatefulWidget {
  const MyRefundsScreen({super.key});

  @override
  State<MyRefundsScreen> createState() => _MyRefundsScreenState();
}

class _MyRefundsScreenState extends State<MyRefundsScreen> {
  List _refunds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiHelper.get(ApiConstants.MY_REFUNDS, auth: true);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && mounted) {
          setState(() => _refunds = data['refunds'] ?? []);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':
        return AppColors.successColor;
      case 'rejected':
        return AppColors.errorColor;
      default:
        return AppColors.warningColor;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray,
      appBar: AppBar(
        title: Text(
          'My Refunds',
          style: GoogleFonts.jost(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.lineColor),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _refunds.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    itemCount: _refunds.length,
                    separatorBuilder: (_, i) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) {
                      final r = _refunds[i];
                      final status = r['status']?.toString() ?? 'pending';
                      final amount = (r['amount'] as num?)?.toDouble() ?? 0;
                      final sColor = _statusColor(status);
                      final createdAt = r['created_at']?.toString() ?? '';

                      return Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header ──────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Refund #${r['id']}',
                                        style: GoogleFonts.jost(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.sp,
                                          color: AppColors.primaryTextColor,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Order #${r['order_id']}',
                                        style: GoogleFonts.jost(
                                          fontSize: 12.sp,
                                          color: AppColors.hintTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status pill
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: sColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                        color: sColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    _statusLabel(status).toUpperCase(),
                                    style: GoogleFonts.jost(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: sColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Divider(height: 1, color: AppColors.lineColor),
                            SizedBox(height: 10.h),

                            // ── Amount ───────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount',
                                  style: GoogleFonts.jost(
                                    fontSize: 13.sp,
                                    color: AppColors.hintTextColor,
                                  ),
                                ),
                                Text(
                                  '₹${amount.toStringAsFixed(2)}',
                                  style: GoogleFonts.jost(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),

                            // ── Reason ───────────────────────────────
                            if ((r['reason']?.toString() ?? '').isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 70.w,
                                    child: Text(
                                      'Reason',
                                      style: GoogleFonts.jost(
                                        fontSize: 12.sp,
                                        color: AppColors.hintTextColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      r['reason'].toString(),
                                      style: GoogleFonts.jost(
                                        fontSize: 12.sp,
                                        color: AppColors.primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // ── Date ─────────────────────────────────
                            if (createdAt.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 11.sp, color: AppColors.hintTextColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Requested ${createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt}',
                                    style: GoogleFonts.jost(
                                      fontSize: 11.sp,
                                      color: AppColors.hintTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // ── Approved banner ────────────────────
                            if (status == 'approved') ...[
                              SizedBox(height: 10.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded,
                                        size: 14.sp,
                                        color: AppColors.successColor),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Refund approved — your money is on its way!',
                                      style: GoogleFonts.jost(
                                        fontSize: 11.sp,
                                        color: AppColors.successColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 56.sp,
          color: AppColors.hintTextColor,
        ),
        SizedBox(height: 12.h),
        Text(
          'No refund requests',
          style: GoogleFonts.jost(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Your refund requests will appear here.',
          style: GoogleFonts.jost(
            fontSize: 12.sp,
            color: AppColors.hintTextColor,
          ),
        ),
      ],
    ),
  );
}
