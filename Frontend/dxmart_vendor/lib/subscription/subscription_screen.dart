import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/vendor_api_helper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  List _plans    = [];
  Map? _activeSub;
  List _history  = [];
  bool _loading  = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pRes  = await VendorApiHelper.get(ApiConstants.SUBSCRIPTION_PLANS);
      final pData = jsonDecode(pRes.body);
      if (pData['success'] == true) setState(() => _plans = pData['data'] ?? []);

      final sRes  = await VendorApiHelper.get(ApiConstants.VENDOR_SUBSCRIPTION);
      final sData = jsonDecode(sRes.body);
      if (sData['success'] == true) {
        setState(() {
          _activeSub = sData['active'];
          _history   = sData['history'] ?? [];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _subscribe(int planId) async {
    try {
      final res  = await VendorApiHelper.postJson(ApiConstants.VENDOR_SUBSCRIBE, body: {'plan_id': planId, 'payment_mode': 'manual'});
      final data = jsonDecode(res.body);
      if (!mounted) return;
      _snack(
        data['message'] ?? (data['success'] == true ? 'Subscribed!' : 'Failed'),
        success: data['success'] == true,
      );
      if (data['success'] == true) _load();
    } catch (e) {
      if (mounted) _snack('Error: $e', success: false);
    }
  }

  void _snack(String msg, {bool success = true}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: GoogleFonts.jost()),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Page header ──────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subscription',
                              style: GoogleFonts.jost(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          Text(
                            _activeSub != null
                                ? '${_activeSub!['plan_name']} · ${_activeSub!['days_remaining']} days left'
                                : 'No active plan',
                            style: GoogleFonts.jost(
                                fontSize: 13.sp,
                                color: _activeSub != null
                                    ? AppColors.success
                                    : AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Tab bar
                TabBar(
                  controller: _tabCtrl,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  labelStyle: GoogleFonts.jost(
                      fontWeight: FontWeight.w600, fontSize: 13.sp),
                  unselectedLabelStyle:
                      GoogleFonts.jost(fontSize: 13.sp),
                  tabs: const [
                    Tab(text: 'Available Plans'),
                    Tab(text: 'My Subscription'),
                  ],
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [_buildPlans(), _buildMySub()],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Plans tab ──────────────────────────────────────────────

  Widget _buildPlans() {
    if (_plans.isEmpty) {
      return Center(
        child: Text('No plans available',
            style: GoogleFonts.jost(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: _plans.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _planCard(_plans[i]),
    );
  }

  Widget _planCard(Map plan) {
    final isMonthly = plan['duration_type'] == 'monthly';
    final features  = (plan['features'] as List?) ?? [];
    final isActive  = _activeSub != null &&
        _activeSub!['plan_name'] == plan['name'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.borderColor,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + active badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isMonthly
                        ? AppColors.primaryLight
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    isMonthly ? 'MONTHLY' : 'YEARLY',
                    style: GoogleFonts.jost(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: isMonthly
                            ? AppColors.primary
                            : Colors.orange[800]),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text('ACTIVE',
                            style: GoogleFonts.jost(
                                fontSize: 10.sp,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            Text(plan['name'] ?? '',
                style: GoogleFonts.jost(
                    fontWeight: FontWeight.w700, fontSize: 18.sp)),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${plan['price']}',
                  style: GoogleFonts.jost(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.h, left: 4.w),
                  child: Text(
                    '/ ${isMonthly ? 'month' : 'year'}',
                    style: GoogleFonts.jost(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Features
            if ((plan['max_products'] ?? 0) == 0)
              _feat(Icons.all_inclusive_rounded,
                  'Unlimited products', AppColors.success)
            else
              _feat(Icons.inventory_2_outlined,
                  'Up to ${plan['max_products']} products',
                  AppColors.textSecondary),

            ...features.map((f) =>
                _feat(Icons.check_circle_outline_rounded, '$f',
                    AppColors.success)),

            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: FilledButton(
                onPressed: isActive ? null : () => _confirmSubscribe(plan),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isActive ? AppColors.hint : AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(
                  isActive ? 'Current Plan' : 'Subscribe Now',
                  style: GoogleFonts.jost(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feat(IconData icon, String text, Color color) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Row(
      children: [
        Icon(icon, color: color, size: 15.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(text,
              style: GoogleFonts.jost(
                  fontSize: 13.sp, color: AppColors.textPrimary)),
        ),
      ],
    ),
  );

  void _confirmSubscribe(Map plan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r)),
        title: Text('Subscribe to ${plan['name']}',
            style: GoogleFonts.jost(fontWeight: FontWeight.w700)),
        content: Text(
          'You will be subscribed for ₹${plan['price']} / ${plan['duration_type']}.\n\n'
          'Payment will be collected manually by admin.',
          style: GoogleFonts.jost(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.jost()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              _subscribe(plan['id']);
            },
            child: Text('Confirm', style: GoogleFonts.jost()),
          ),
        ],
      ),
    );
  }

  // ── My Subscription tab ───────────────────────────────────

  Widget _buildMySub() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active plan card
          if (_activeSub != null) ...[
            _sectionLabel('Active Plan'),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF00BFA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_membership_rounded,
                          color: Colors.white, size: 28.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _activeSub!['plan_name'] ?? 'Active Plan',
                          style: GoogleFonts.jost(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _subInfoChip(
                        Icons.hourglass_bottom_rounded,
                        '${_activeSub!['days_remaining']} days left',
                      ),
                      SizedBox(width: 10.w),
                      _subInfoChip(
                        Icons.event_rounded,
                        'Expires ${_activeSub!['end_date']}',
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: Colors.white24, height: 1),
                  SizedBox(height: 12.h),
                  Text(
                    'Started ${_activeSub!['start_date']}',
                    style: GoogleFonts.jost(
                        color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ] else ...[
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14.r),
                border:
                    Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 28.sp),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No Active Subscription',
                            style: GoogleFonts.jost(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp)),
                        Text('Subscribe to a plan to start selling.',
                            style: GoogleFonts.jost(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // History
          if (_history.isNotEmpty) ...[
            _sectionLabel('Subscription History'),
            SizedBox(height: 10.h),
            ..._history.map((s) => _historyItem(s)),
          ],
        ],
      ),
    );
  }

  Widget _subInfoChip(IconData icon, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12.sp),
        SizedBox(width: 4.w),
        Text(label,
            style: GoogleFonts.jost(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _historyItem(Map s) {
    final isActive = s['status'] == 'active';
    final color    = isActive ? AppColors.success : AppColors.hint;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w, height: 8.w,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['plan_name'] ?? '',
                    style: GoogleFonts.jost(
                        fontWeight: FontWeight.w600, fontSize: 13.sp)),
                Text(
                  '${s['start_date']} → ${s['end_date']}',
                  style: GoogleFonts.jost(
                      fontSize: 11.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              (s['status'] ?? '').toString().toUpperCase(),
              style: GoogleFonts.jost(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(
    t.toUpperCase(),
    style: GoogleFonts.jost(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.8),
  );
}
