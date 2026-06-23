import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';

class PayoutHistoryScreen extends StatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  State<PayoutHistoryScreen> createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> {
  List _payouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await VendorApiHelper.get(ApiConstants.VENDOR_PAYOUTS);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && mounted) {
          setState(() => _payouts = data['payouts'] ?? []);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Payout History',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _payouts.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _payouts.length,
                    separatorBuilder: (_, i) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) => _PayoutCard(payout: _payouts[i]),
                  ),
                ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 56.sp,
          color: AppColors.hintTextColor,
        ),
        SizedBox(height: 12.h),
        Text(
          'No payouts yet',
          style: GoogleFonts.jost(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Your earnings will appear here once processed by the admin.',
            style: GoogleFonts.jost(
              fontSize: 12.sp,
              color: AppColors.hintTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

// ── Single payout card ────────────────────────────────────────────────────────
class _PayoutCard extends StatelessWidget {
  final Map payout;
  const _PayoutCard({required this.payout});

  @override
  Widget build(BuildContext context) {
    final isPaid = payout['status'] == 'paid';
    final amount = (payout['amount'] as num?)?.toDouble() ?? 0;
    final statusColor = isPaid ? AppColors.success : AppColors.warning;
    final statusBg = isPaid
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.warning.withValues(alpha: 0.1);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isPaid ? AppColors.success.withValues(alpha: 0.3) : AppColors.borderColor,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isPaid ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                  color: statusColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payout #${payout['id']}',
                      style: GoogleFonts.jost(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (payout['created_at'] != null)
                      Text(
                        payout['created_at'].toString().substring(0, 10),
                        style: GoogleFonts.jost(
                          fontSize: 11.sp,
                          color: AppColors.hintTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'PENDING',
                  style: GoogleFonts.jost(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: AppColors.borderColor),
          SizedBox(height: 12.h),

          // ── Amount ────────────────────────────────────
          _row('Amount', '₹${amount.toStringAsFixed(2)}',
              valueStyle: GoogleFonts.jost(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              )),

          // ── Period ────────────────────────────────────
          if (payout['period_start'] != null)
            _row('Period',
                '${payout['period_start']} → ${payout['period_end'] ?? '—'}'),

          // ── Reference ─────────────────────────────────
          if (payout['reference'] != null &&
              (payout['reference'] as String).isNotEmpty)
            _row('Reference', payout['reference'].toString(),
                valueStyle: GoogleFonts.jost(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                )),

          // ── Paid at ───────────────────────────────────
          if (isPaid && payout['paid_at'] != null)
            _row(
              'Paid at',
              payout['paid_at'].toString().length > 10
                  ? payout['paid_at'].toString().substring(0, 10)
                  : payout['paid_at'].toString(),
              valueStyle: GoogleFonts.jost(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) => Padding(
    padding: EdgeInsets.only(top: 6.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: valueStyle ??
              GoogleFonts.jost(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    ),
  );
}
