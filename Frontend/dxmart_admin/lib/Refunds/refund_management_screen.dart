import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class RefundManagementScreen extends StatefulWidget {
  const RefundManagementScreen({super.key});

  @override
  State<RefundManagementScreen> createState() => _RefundManagementScreenState();
}

class _RefundManagementScreenState extends State<RefundManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = ['pending', 'approved', 'rejected', 'all'];
  final _tabLabels = ['Pending', 'Approved', 'Rejected', 'All'];

  List _refunds = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _fetch();
    });
    _fetch();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final status = _tabs[_tabCtrl.index];
    try {
      final res = await AdminApi.get(
        Uri.parse('${ApiConstants.ADMIN_REFUNDS}?status=$status'),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _refunds = data['refunds'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _process(int refundId, String action) async {
    final url = action == 'approve'
        ? ApiConstants.ADMIN_REFUNDS_APPROVE
        : ApiConstants.ADMIN_REFUNDS_REJECT;
    try {
      final res = await AdminApi.postJson(
        Uri.parse(url),
        body: {'refund_id': refundId},
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        _showSnack(data['message'] ?? (data['success'] == true ? 'Done' : 'Failed'));
        _fetch();
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

  // ── Confirm before approve/reject ─────────────────────────
  Future<void> _confirmProcess(Map r, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          action == 'approve' ? 'Approve Refund' : 'Reject Refund',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${action == 'approve' ? 'Approve' : 'Reject'} refund of ₹${r['amount']?.toStringAsFixed(2)} for order #${r['order_id']}?',
          style: GoogleFonts.jost(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approve'
                  ? AppColors.successColor
                  : AppColors.errorColor,
            ),
            child: Text(
              action == 'approve' ? 'Approve' : 'Reject',
              style: GoogleFonts.jost(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (ok == true) _process(r['id'] as int, action);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Refund Management',
      subtitle: 'Review and process customer refund requests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tab bar ──────────────────────────────────────
          Container(
            color: AppColors.surfaceColor,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              labelStyle: GoogleFonts.jost(fontWeight: FontWeight.w700, fontSize: 13.sp),
              unselectedLabelStyle: GoogleFonts.jost(fontWeight: FontWeight.w500, fontSize: 13.sp),
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.secondaryTextColor,
              indicatorColor: AppColors.primaryColor,
              tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
            ),
          ),
          // ── Content ──────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _refunds.isEmpty
                    ? Center(
                        child: Text(
                          'No refunds found',
                          style: GoogleFonts.jost(color: AppColors.secondaryTextColor),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _refunds.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) => _RefundCard(
                            refund: _refunds[i],
                            onApprove: () => _confirmProcess(_refunds[i], 'approve'),
                            onReject: () => _confirmProcess(_refunds[i], 'reject'),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Single refund card ────────────────────────────────────────────────────────
class _RefundCard extends StatelessWidget {
  final Map refund;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RefundCard({
    required this.refund,
    required this.onApprove,
    required this.onReject,
  });

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

  Color _statusBg(String s) {
    switch (s) {
      case 'approved':
        return AppColors.successLight;
      case 'rejected':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = refund['status']?.toString() ?? 'pending';
    final amount = (refund['amount'] as num?)?.toDouble() ?? 0;
    final orderId = refund['order_id'];
    final reason = refund['reason']?.toString() ?? '';
    final createdAt = refund['created_at']?.toString() ?? '';
    final processedAt = refund['processed_at']?.toString();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund #${refund['id']}',
                      style: GoogleFonts.jost(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Order #$orderId',
                      style: GoogleFonts.jost(
                        fontSize: 12.sp,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Status chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.jost(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // ── Reason ───────────────────────────────────
          if (reason.isNotEmpty) ...[
            Text(
              'Reason: $reason',
              style: GoogleFonts.jost(
                fontSize: 12.sp,
                color: AppColors.secondaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
          ],
          // ── Dates ────────────────────────────────────
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12.sp, color: AppColors.hintTextColor),
              SizedBox(width: 4.w),
              Text(
                createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt,
                style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hintTextColor),
              ),
              if (processedAt != null) ...[
                SizedBox(width: 12.w),
                Icon(Icons.check_circle_outline_rounded, size: 12.sp, color: AppColors.hintTextColor),
                SizedBox(width: 4.w),
                Text(
                  'Processed: ${processedAt.length > 10 ? processedAt.substring(0, 10) : processedAt}',
                  style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hintTextColor),
                ),
              ],
            ],
          ),
          // ── Action buttons (pending only) ─────────────
          if (status == 'pending') ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorColor,
                      side: BorderSide(color: AppColors.errorColor),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    child: Text('Reject', style: GoogleFonts.jost(fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successColor,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    child: Text(
                      'Approve',
                      style: GoogleFonts.jost(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
