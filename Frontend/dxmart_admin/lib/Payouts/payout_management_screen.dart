import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class PayoutManagementScreen extends StatefulWidget {
  const PayoutManagementScreen({super.key});

  @override
  State<PayoutManagementScreen> createState() => _PayoutManagementScreenState();
}

class _PayoutManagementScreenState extends State<PayoutManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Pending earnings tab
  List _earnings = [];
  bool _loadingEarnings = false;

  // Payouts tab
  List _payouts = [];
  bool _loadingPayouts = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        if (_tabCtrl.index == 0) {
          _fetchEarnings();
        } else {
          _fetchPayouts();
        }
      }
    });
    _fetchEarnings();
    _fetchPayouts();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetchEarnings() async {
    setState(() => _loadingEarnings = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.ADMIN_PAYOUTS_PENDING));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _earnings = data['earnings'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingEarnings = false);
    }
  }

  Future<void> _fetchPayouts() async {
    setState(() => _loadingPayouts = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.ADMIN_PAYOUTS));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _payouts = data['payouts'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingPayouts = false);
    }
  }

  Future<void> _createPayout(Map earning) async {
    final refCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Create Payout',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor: ${earning['vendor_name']}',
              style: GoogleFonts.jost(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            Text(
              'Amount: ₹${(earning['total_earning'] as num).toStringAsFixed(2)} (${earning['order_count']} orders)',
              style: GoogleFonts.jost(color: AppColors.secondaryTextColor),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: refCtrl,
              decoration: InputDecoration(
                labelText: 'Reference (UTR / cheque no.)',
                labelStyle: GoogleFonts.jost(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: Text('Create', style: GoogleFonts.jost(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final res = await AdminApi.postJson(
        Uri.parse(ApiConstants.ADMIN_PAYOUTS_CREATE),
        body: {
          'vendor_id': earning['vendor_id'],
          'reference': refCtrl.text.trim(),
        },
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        _showSnack(data['message'] ?? (data['success'] == true ? 'Payout created' : 'Failed'));
        _fetchEarnings();
        _fetchPayouts();
      }
    } catch (_) {
      if (mounted) _showSnack('Request failed');
    }
  }

  Future<void> _markPaid(Map payout) async {
    final refCtrl = TextEditingController(text: payout['reference']?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mark as Paid', style: GoogleFonts.jost(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payout #${payout['id']} — ₹${(payout['amount'] as num).toStringAsFixed(2)} to ${payout['vendor_name']}',
              style: GoogleFonts.jost(color: AppColors.secondaryTextColor),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: refCtrl,
              decoration: InputDecoration(
                labelText: 'Payment reference (optional)',
                labelStyle: GoogleFonts.jost(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successColor),
            child: Text('Mark Paid', style: GoogleFonts.jost(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final res = await AdminApi.postJson(
        Uri.parse(ApiConstants.ADMIN_PAYOUTS_MARK_PAID),
        body: {
          'payout_id': payout['id'],
          'reference': refCtrl.text.trim(),
        },
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        _showSnack(data['message'] ?? (data['success'] == true ? 'Marked paid' : 'Failed'));
        _fetchPayouts();
      }
    } catch (_) {
      if (mounted) _showSnack('Request failed');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.jost())),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Payout Management',
      subtitle: 'Track vendor earnings and process payouts',
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceColor,
            child: TabBar(
              controller: _tabCtrl,
              labelStyle: GoogleFonts.jost(fontWeight: FontWeight.w700, fontSize: 13.sp),
              unselectedLabelStyle: GoogleFonts.jost(fontWeight: FontWeight.w500, fontSize: 13.sp),
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.secondaryTextColor,
              indicatorColor: AppColors.primaryColor,
              tabs: const [
                Tab(text: 'Pending Earnings'),
                Tab(text: 'Payouts'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildEarningsTab(),
                _buildPayoutsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pending Earnings tab ───────────────────────────────────
  Widget _buildEarningsTab() {
    if (_loadingEarnings) return const Center(child: CircularProgressIndicator());
    if (_earnings.isEmpty) {
      return Center(
        child: Text(
          'No pending earnings',
          style: GoogleFonts.jost(color: AppColors.secondaryTextColor),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchEarnings,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _earnings.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) {
          final e = _earnings[i];
          final earning = (e['total_earning'] as num?)?.toDouble() ?? 0;
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: AppColors.cardShadow,
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                // Vendor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['vendor_name']?.toString() ?? 'Vendor',
                        style: GoogleFonts.jost(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${e['order_count']} delivered order${(e['order_count'] as int? ?? 0) == 1 ? '' : 's'}',
                        style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${earning.toStringAsFixed(2)}',
                      style: GoogleFonts.jost(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: AppColors.successColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    ElevatedButton(
                      onPressed: () => _createPayout(e),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Create Payout',
                        style: GoogleFonts.jost(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Payouts tab ────────────────────────────────────────────
  Widget _buildPayoutsTab() {
    if (_loadingPayouts) return const Center(child: CircularProgressIndicator());
    if (_payouts.isEmpty) {
      return Center(
        child: Text(
          'No payouts yet',
          style: GoogleFonts.jost(color: AppColors.secondaryTextColor),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchPayouts,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _payouts.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) {
          final p = _payouts[i];
          final amount = (p['amount'] as num?)?.toDouble() ?? 0;
          final isPaid = p['status'] == 'paid';
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: AppColors.cardShadow,
              border: Border.all(
                color: isPaid ? AppColors.successColor.withValues(alpha: 0.3) : AppColors.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payout #${p['id']}',
                            style: GoogleFonts.jost(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            p['vendor_name']?.toString() ?? '',
                            style: GoogleFonts.jost(
                              fontSize: 12.sp,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.jost(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isPaid ? AppColors.successLight : AppColors.warningLight,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        isPaid ? 'PAID' : 'PENDING',
                        style: GoogleFonts.jost(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isPaid ? AppColors.successColor : AppColors.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Period & reference
                if (p['period_start'] != null)
                  Text(
                    'Period: ${p['period_start']} → ${p['period_end'] ?? '—'}',
                    style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hintTextColor),
                  ),
                if (p['reference'] != null && (p['reference'] as String).isNotEmpty)
                  Text(
                    'Ref: ${p['reference']}',
                    style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hintTextColor),
                  ),
                if (p['paid_at'] != null)
                  Text(
                    'Paid at: ${p['paid_at']}',
                    style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.successColor),
                  ),
                // Mark paid button (pending only)
                if (!isPaid) ...[
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => _markPaid(p),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.successColor,
                        side: BorderSide(color: AppColors.successColor),
                      ),
                      child: Text(
                        'Mark as Paid',
                        style: GoogleFonts.jost(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
