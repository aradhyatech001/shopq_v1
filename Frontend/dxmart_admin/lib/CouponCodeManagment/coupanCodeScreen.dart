import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class CouponCodeScreen extends StatefulWidget {
  const CouponCodeScreen({super.key});

  @override
  State<CouponCodeScreen> createState() => _CouponCodeScreenState();
}

class _CouponCodeScreenState extends State<CouponCodeScreen> {
  // ── Form controllers ──────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _minAmtCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String? _status;
  bool _saving = false;
  Map? _editingCoupon; // null = the panel is in "Add" mode

  // ── List state ────────────────────────────────────────────
  List<Map<String, dynamic>> _coupons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _codeCtrl,
      _discountCtrl,
      _minAmtCtrl,
      _dateCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetchCoupons() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.VIEW_COUPON));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _coupons = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Loads a coupon into the right panel for editing (no separate sheet).
  void _startEdit(Map<String, dynamic> coupon) {
    final raw = (coupon['status'] ?? 'Public').toString().toLowerCase();
    setState(() {
      _editingCoupon = coupon;
      _titleCtrl.text = coupon['title']?.toString() ?? '';
      _descCtrl.text = coupon['description']?.toString() ?? '';
      _codeCtrl.text = coupon['code_name']?.toString() ?? '';
      _discountCtrl.text = coupon['discount']?.toString() ?? '';
      _minAmtCtrl.text = coupon['min_amount']?.toString() ?? '';
      _dateCtrl.text = coupon['expri_date']?.toString() ?? '';
      _status = raw == 'private' ? 'Private' : 'Public';
    });
  }

  Future<void> _addCoupon() async {
    if (_titleCtrl.text.isEmpty) {
      _snack('Title required', AppColors.warningColor);
      return;
    }
    if (_codeCtrl.text.isEmpty) {
      _snack('Code required', AppColors.warningColor);
      return;
    }
    if (_discountCtrl.text.isEmpty) {
      _snack('Discount required', AppColors.warningColor);
      return;
    }
    if (_minAmtCtrl.text.isEmpty) {
      _snack('Min amount required', AppColors.warningColor);
      return;
    }
    if (_dateCtrl.text.isEmpty) {
      _snack('Expiry date required', AppColors.warningColor);
      return;
    }
    if (_status == null) {
      _snack('Select status', AppColors.warningColor);
      return;
    }

    final editing = _editingCoupon != null;
    setState(() => _saving = true);
    try {
      final body = <String, String>{
        'title': _titleCtrl.text.toUpperCase(),
        'description': _descCtrl.text,
        'code_name': _codeCtrl.text.toUpperCase(),
        'discount': _discountCtrl.text,
        'min_amount': _minAmtCtrl.text,
        'expri_date': _dateCtrl.text,
        'status': _status!,
      };
      if (editing) body['id'] = _editingCoupon!['id'].toString();
      final res = await AdminApi.post(
        Uri.parse(editing ? ApiConstants.EDIT_COUPON : ApiConstants.ADD_COUPON),
        body: body,
      );
      final data = jsonDecode(res.body);
      if (data['success'] == 'true' || data['success'] == true) {
        _snack(editing ? 'Coupon updated!' : 'Coupon added!', AppColors.successColor);
        _resetForm();
        _fetchCoupons();
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteCoupon(String id) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete Coupon',
      message: 'This coupon will be permanently removed.',
    );
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.DELETE_COUPON),
        body: {'id': id},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Deleted', AppColors.successColor);
        _fetchCoupons();
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    }
  }

  void _resetForm() {
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _codeCtrl,
      _discountCtrl,
      _minAmtCtrl,
      _dateCtrl,
    ]) {
      c.clear();
    }
    setState(() {
      _status = null;
      _editingCoupon = null;
    });
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.jost(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Coupons',
      subtitle: '${_coupons.length} coupons',
      actions: [
        IconButton(
          onPressed: _fetchCoupons,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: list ─────────────────────────────────
          Expanded(
            flex: 3,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _coupons.isEmpty
                ? const EmptyState(
                    icon: Icons.local_offer_outlined,
                    message: 'No coupons yet',
                    hint: 'Add one using the form',
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _coupons.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) => _CouponTile(
                      coupon: _coupons[i],
                      onEdit: () => _startEdit(_coupons[i]),
                      onDelete: () =>
                          _deleteCoupon(_coupons[i]['id'].toString()),
                      onCopy: () =>
                          _copy(_coupons[i]['code_name']?.toString() ?? ''),
                    ),
                  ),
          ),

          const VerticalDivider(width: 1),

          // ── Right: form ────────────────────────────────
          SizedBox(
            width: 360.w,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _snack('Copied: $text', AppColors.successColor);
  }

  Widget _buildForm() {
    final editing = _editingCoupon != null;
    return SectionCard(
      title: editing ? 'Edit Coupon' : 'Add Coupon',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(_titleCtrl, 'Title', maxLen: 16),
          SizedBox(height: 12.h),
          _field(_descCtrl, 'Description', maxLen: 28),
          SizedBox(height: 12.h),
          _field(_codeCtrl, 'Code (no spaces)', maxLen: 10),
          SizedBox(height: 12.h),
          _field(
            _discountCtrl,
            'Discount %',
            type: TextInputType.number,
            maxLen: 5,
          ),
          SizedBox(height: 12.h),
          _field(_minAmtCtrl, 'Min Order Value', type: TextInputType.number),
          SizedBox(height: 12.h),

          // Date picker
          const FormLabel('Expiry Date', required: true),
          TextField(
            controller: _dateCtrl,
            readOnly: true,
            style: GoogleFonts.jost(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: 'Pick a date',
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.hintTextColor,
              ),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                _dateCtrl.text =
                    '${picked.day.toString().padLeft(2, '0')}-'
                    '${picked.month.toString().padLeft(2, '0')}-'
                    '${picked.year}';
              }
            },
          ),
          SizedBox(height: 12.h),

          // Status dropdown
          const FormLabel('Status', required: true),
          Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: DropdownButton<String>(
              value: _status,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Text(
                'Select status',
                style: GoogleFonts.jost(
                  fontSize: 13.sp,
                  color: AppColors.hintTextColor,
                ),
              ),
              style: GoogleFonts.jost(
                fontSize: 13.sp,
                color: AppColors.primaryTextColor,
              ),
              icon: Icon(
                Icons.expand_more_rounded,
                size: 18.sp,
                color: AppColors.hintTextColor,
              ),
              items: ['Public', 'Private']
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: GoogleFonts.jost(fontSize: 13.sp)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _status = v),
            ),
          ),
          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _addCoupon,
                        child: Text(
                          editing ? 'Save' : 'Add Coupon',
                          style: GoogleFonts.jost(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: _resetForm,
                child: Text(editing ? 'Cancel' : 'Reset', style: GoogleFonts.jost()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType type = TextInputType.text,
    int? maxLen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLength: maxLen,
          style: GoogleFonts.jost(fontSize: 13.sp),
          decoration: InputDecoration(counterText: '', hintText: label),
        ),
      ],
    );
  }
}

// ── Coupon card ───────────────────────────────────────────────────────────────
class _CouponTile extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _CouponTile({
    required this.coupon,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final discount = coupon['discount']?.toString() ?? '—';
    final code = (coupon['code_name'] ?? '').toString().toUpperCase();
    final expiry = coupon['expri_date']?.toString() ?? '—';
    final minAmt = coupon['min_amount']?.toString();
    final desc = coupon['description']?.toString() ?? '';
    final status = (coupon['status'] ?? '').toString();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${coupon['title']?.toString().toUpperCase() ?? 'COUPON'}',
                  style: GoogleFonts.jost(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(
                label: status.isEmpty ? '—' : status,
                color: status.toLowerCase() == 'public'
                    ? AppColors.successColor
                    : AppColors.warningColor,
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Edit coupon',
              ),
              SizedBox(width: 10.w),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.errorColor,
                  size: 18.sp,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete coupon',
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Code row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                Text(
                  code,
                  style: GoogleFonts.jost(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 16.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                  onPressed: onCopy,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // Details
          Row(
            children: [
              _detail(
                Icons.local_offer_rounded,
                '$discount% off',
                AppColors.cardPurple,
              ),
              SizedBox(width: 16.w),
              _detail(
                Icons.calendar_today_rounded,
                expiry,
                AppColors.secondaryTextColor,
              ),
              if (minAmt != null) ...[
                SizedBox(width: 16.w),
                _detail(
                  Icons.shopping_cart_rounded,
                  'Min ₹$minAmt',
                  AppColors.cardGreen,
                ),
              ],
            ],
          ),

          if (desc.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              desc,
              style: GoogleFonts.jost(
                fontSize: 12.sp,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(
        text,
        style: GoogleFonts.jost(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
