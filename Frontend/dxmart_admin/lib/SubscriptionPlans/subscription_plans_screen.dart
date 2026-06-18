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

  // Right-panel Add/Edit form (split layout).
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _maxCtrl = TextEditingController(text: '0');
  final _featCtrl = TextEditingController();
  String _durationType = 'monthly';
  final _formKey = GlobalKey<FormState>();
  Map? _editing; // null = Add mode
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _maxCtrl.dispose();
    _featCtrl.dispose();
    super.dispose();
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

  // Loads a plan into the right panel for editing (no dialog).
  void _startEdit(Map plan) {
    setState(() {
      _editing = plan;
      _nameCtrl.text = plan['name']?.toString() ?? '';
      _priceCtrl.text = plan['price']?.toString() ?? '';
      _maxCtrl.text = plan['max_products']?.toString() ?? '0';
      _featCtrl.text = (plan['features'] as List?)?.join(', ') ?? '';
      _durationType = plan['duration_type']?.toString() ?? 'monthly';
    });
  }

  void _resetForm() {
    setState(() {
      _editing = null;
      _nameCtrl.clear();
      _priceCtrl.clear();
      _maxCtrl.text = '0';
      _featCtrl.clear();
      _durationType = 'monthly';
    });
  }

  // Add (no editing) or update (editing) — one right panel does both.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final editing = _editing != null;
    setState(() => _saving = true);
    try {
      final body = {
        if (editing) 'id': _editing!['id'],
        'name':          _nameCtrl.text.trim(),
        'price':         double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'duration_type': _durationType,
        'max_products':  int.tryParse(_maxCtrl.text.trim()) ?? 0,
        'features':      _featCtrl.text.trim(),
      };
      final url = editing ? ApiConstants.ADMIN_PLANS_EDIT : ApiConstants.ADMIN_PLANS_ADD;
      final res = await AdminApi.postJson(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (!mounted) return;
      _showSnack(data['message'] ?? 'Done');
      if (data['success'] == true || data['success'] == 'true') {
        _resetForm();
        _fetchPlans();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildForm() {
    final editing = _editing != null;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      padding: EdgeInsets.all(18.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(editing ? 'Edit Plan' : 'Add Plan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            _field(_nameCtrl, 'Plan Name', required: true),
            SizedBox(height: 12.h),
            _field(_priceCtrl, 'Price (₹)', keyboardType: TextInputType.number, required: true),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              initialValue: _durationType,
              decoration: InputDecoration(
                labelText: 'Duration Type',
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly (30 days)')),
                DropdownMenuItem(value: 'yearly',  child: Text('Yearly (365 days)')),
              ],
              onChanged: (v) => setState(() => _durationType = v!),
            ),
            SizedBox(height: 12.h),
            _field(_maxCtrl, 'Max Products (0 = unlimited)', keyboardType: TextInputType.number),
            SizedBox(height: 12.h),
            _field(_featCtrl, 'Features (comma separated)'),
            SizedBox(height: 18.h),
            Row(children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        onPressed: _save,
                        child: Text(editing ? 'Save' : 'Add',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: _resetForm,
                child: Text(editing ? 'Cancel' : 'Reset', style: GoogleFonts.poppins()),
              ),
            ]),
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
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildContent()),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 360.w,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(18.w),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ]),
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
    final selected = _editing != null && _editing!['id'] == plan['id'];

    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surfaceColor,
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
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.primaryColor, size: 18.sp),
              tooltip: 'Edit',
              onPressed: () => _startEdit(plan),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red, size: 18.sp),
              tooltip: 'Delete',
              onPressed: () {
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
              },
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
