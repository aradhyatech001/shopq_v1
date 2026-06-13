import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  List _plans = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetchPlans() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.ADMIN_PLANS));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _plans = data['data'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(int id) async {
    try {
      final res = await AdminApi.postJson(
        Uri.parse(ApiConstants.ADMIN_PLANS_TOGGLE),
        body: {'id': id},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        _fetchPlans();
      }
    } catch (_) {}
  }

  Future<void> _delete(int id) async {
    try {
      final res = await AdminApi.postJson(
        Uri.parse(ApiConstants.ADMIN_PLANS_DELETE),
        body: {'id': id},
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        _showSnack(data['message'] ?? 'Done');
        _fetchPlans();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
  }

  Future<void> _save({Map? existing}) async {
    final nameCtrl    = TextEditingController(text: existing?['name'] ?? '');
    final priceCtrl   = TextEditingController(text: existing?['price']?.toString() ?? '');
    final maxCtrl     = TextEditingController(text: existing?['max_products']?.toString() ?? '0');
    final featCtrl    = TextEditingController(
        text: (existing?['features'] as List?)?.join(', ') ?? '');
    String durationType = existing?['duration_type'] ?? 'monthly';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(
            existing != null ? 'Edit Plan' : 'Add Plan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 400.w,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _field(nameCtrl, 'Plan Name', required: true),
                  SizedBox(height: 12.h),
                  _field(priceCtrl, 'Price (₹)', keyboardType: TextInputType.number, required: true),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    value: durationType,
                    decoration: InputDecoration(
                      labelText: 'Duration Type',
                      border: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly (30 days)')),
                      DropdownMenuItem(value: 'yearly',  child: Text('Yearly (365 days)')),
                    ],
                    onChanged: (v) => setLocal(() => durationType = v!),
                  ),
                  SizedBox(height: 12.h),
                  _field(maxCtrl, 'Max Products (0 = unlimited)', keyboardType: TextInputType.number),
                  SizedBox(height: 12.h),
                  _field(featCtrl, 'Features (comma separated)'),
                ]),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);

                final body = {
                  if (existing != null) 'id': existing['id'],
                  'name':          nameCtrl.text.trim(),
                  'price':         double.tryParse(priceCtrl.text.trim()) ?? 0,
                  'duration_type': durationType,
                  'max_products':  int.tryParse(maxCtrl.text.trim()) ?? 0,
                  'features':      featCtrl.text.trim(),
                };
                final url = existing != null ? ApiConstants.ADMIN_PLANS_EDIT : ApiConstants.ADMIN_PLANS_ADD;
                try {
                  final res = await AdminApi.postJson(
                    Uri.parse(url),
                    body: body,
                  );
                  final data = jsonDecode(res.body);
                  if (mounted) {
                    _showSnack(data['message'] ?? 'Done');
                    _fetchPlans();
                  }
                } catch (e) {
                  if (mounted) _showSnack('Error: $e');
                }
              },
              child: Text(
                existing != null ? 'Update' : 'Add',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType keyboardType = TextInputType.text, bool required = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _save(),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Plan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader() => Container(
        color: AppColors.surfaceColor,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(children: [
          Text('Subscription Plans', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18.sp)),
          const Spacer(),
          IconButton(onPressed: _fetchPlans, icon: const Icon(Icons.refresh_rounded), tooltip: 'Refresh'),
        ]),
      );

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_plans.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.card_membership_outlined, size: 56.sp, color: AppColors.hintTextColor),
          SizedBox(height: 12.h),
          Text('No plans yet. Tap + to create one.',
              style: GoogleFonts.poppins(color: AppColors.secondaryTextColor)),
        ]),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _plans.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _planCard(_plans[i]),
    );
  }

  Widget _planCard(Map plan) {
    final isActive = plan['is_active'] == true;
    final features = (plan['features'] as List?) ?? [];
    final isMonthly = plan['duration_type'] == 'monthly';

    return Material(
      color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isMonthly ? AppColors.primaryLight : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                isMonthly ? 'MONTHLY' : 'YEARLY',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: isMonthly ? AppColors.primaryColor : Colors.orange[800],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(plan['name'] ?? '',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp)),
            ),
            Switch(
              value: isActive,
              onChanged: (_) => _toggle(plan['id']),
              activeColor: AppColors.primaryColor,
            ),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit')   _save(existing: plan);
                if (val == 'delete') {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Delete Plan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      content: const Text('Are you sure? Active vendor subscriptions may be affected.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () { Navigator.pop(context); _delete(plan['id']); },
                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit',   child: Text('✏️ Edit')),
                PopupMenuItem(value: 'delete', child: Text('🗑 Delete')),
              ],
            ),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Text(
              '₹${plan['price']}',
              style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
            ),
            Text(
              ' / ${isMonthly ? 'month' : 'year'}',
              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.secondaryTextColor),
            ),
            const Spacer(),
            if ((plan['max_products'] ?? 0) > 0) ...[
              Icon(Icons.inventory_2_outlined, size: 14.sp, color: AppColors.secondaryTextColor),
              SizedBox(width: 4.w),
              Text('${plan['max_products']} products',
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.secondaryTextColor)),
            ] else ...[
              Icon(Icons.all_inclusive_rounded, size: 14.sp, color: Colors.green),
              SizedBox(width: 4.w),
              Text('Unlimited products', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.green)),
            ],
          ]),
          if (features.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: features.map((f) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.hintTextColor.withOpacity(0.4)),
                ),
                child: Text('✓ $f', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primaryTextColor)),
              )).toList(),
            ),
          ],
          if (!isActive)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text('Inactive — not visible to vendors',
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.red[400])),
            ),
        ]),
      ),
    );
  }
}
