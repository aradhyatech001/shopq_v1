import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/api_constants.dart';
import '../utils/api_helper.dart';
import '../utils/colors.dart';
import '../utils/order_status.dart';
import '../utils/session_manager.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List _orders = [];
  bool _loading = true;
  bool _showCompleted = false;
  String _riderName = 'Rider';
  Timer? _poll;

  // The rider's forward actions.
  static const Map<String, Map<String, String>> _nextAction = {
    'assigned':         {'label': 'Confirm pickup',   'to': 'picked_up'},
    'picked_up':        {'label': 'Out for delivery', 'to': 'out_for_delivery'},
    'out_for_delivery': {'label': 'Mark delivered',   'to': 'delivered'},
  };

  @override
  void initState() {
    super.initState();
    _loadRider();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 20), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _loadRider() async {
    final r = await SessionManager.getRider();
    if (r != null && mounted) setState(() => _riderName = (r['name'] ?? 'Rider').toString());
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final res = await ApiHelper.get(ApiConstants.ORDERS);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) setState(() => _orders = data['orders'] ?? []);
    } catch (_) {
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  List get _filtered => _orders
      .where((o) => OrderStatus.isComplete(o['status']) == _showCompleted)
      .toList();

  Future<void> _setStatus(dynamic id, String status) async {
    try {
      final res = await ApiHelper.postJson(
        ApiConstants.UPDATE_STATUS,
        body: {'vendor_order_id': id, 'status': status},
      );
      final data = jsonDecode(res.body);
      _toast(data['message'] ?? (data['success'] == true ? 'Updated' : 'Failed'));
      if (data['success'] == true) await _load(silent: true);
    } catch (_) {
      _toast('Something went wrong');
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.jost()), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _logout() async {
    try {
      await ApiHelper.post(ApiConstants.LOGOUT);
    } catch (_) {}
    await SessionManager.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _navigate(String? address) async {
    if (address == null || address.isEmpty) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  double _num(v) => double.tryParse('${v ?? 0}') ?? 0;

  /// Full product row so the rider knows exactly what to hand over.
  Widget _item(Map it) {
    final img = ApiConstants.imageUrl(it['image']?.toString() ?? '');
    final qty = _num(it['quantity']).toInt();
    final unit = _num(it['price']);
    final mrp = _num(it['mrp']);
    final disc = _num(it['discount']).toInt();
    final lineTotal = _num(it['line_total']) > 0 ? _num(it['line_total']) : unit * qty;
    final hasDisc = mrp > unit && mrp > 0;
    final variant = (it['variant_name'] ?? '').toString();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 48.w,
              height: 48.w,
              child: img.isEmpty
                  ? Container(color: AppColors.background, child: Icon(Icons.image, size: 18.sp, color: AppColors.hint))
                  : Image.network(img, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.background, child: Icon(Icons.broken_image, size: 18.sp, color: AppColors.hint))),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it['product_name'] ?? '',
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                if (variant.isNotEmpty)
                  Text(variant, style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.textSecondary)),
                SizedBox(height: 3.h),
                Row(children: [
                  Text('₹${unit.toStringAsFixed(0)}',
                      style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  if (hasDisc) ...[
                    SizedBox(width: 6.w),
                    Text('₹${mrp.toStringAsFixed(0)}',
                        style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hint, decoration: TextDecoration.lineThrough)),
                    SizedBox(width: 6.w),
                    Text('$disc% off',
                        style: GoogleFonts.jost(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ],
                ]),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6.r)),
                child: Text('Qty $qty',
                    style: GoogleFonts.jost(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              SizedBox(height: 4.h),
              Text('₹${lineTotal.toStringAsFixed(0)}', style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('My deliveries',
                style: GoogleFonts.jost(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(_riderName,
                style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(onPressed: () => _load(), icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20.sp)),
          IconButton(onPressed: _logout, icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 20.sp)),
          SizedBox(width: 6.w),
        ],
      ),
      body: Column(
        children: [
          // Active / Delivered toggle
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Row(
              children: [
                _tab('Active', !_showCompleted, () => setState(() => _showCompleted = false)),
                SizedBox(width: 10.w),
                _tab('Completed', _showCompleted, () => setState(() => _showCompleted = true)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.inbox_outlined, size: 54.sp, color: AppColors.hint),
                          SizedBox(height: 10.h),
                          Text(_showCompleted ? 'No completed deliveries' : 'No active deliveries',
                              style: GoogleFonts.jost(fontSize: 15.sp, color: AppColors.textSecondary)),
                        ]),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _load(),
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) => _card(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool sel, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: sel ? AppColors.primary : AppColors.borderColor),
          ),
          child: Text(label,
              style: GoogleFonts.jost(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _card(Map o) {
    final status = (o['status'] ?? '').toString();
    final addr = o['address'] as Map?;
    final c = OrderStatus.color(status);
    return GestureDetector(
      onTap: () => _openDetail(o),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Order #${o['parent_order_id'] ?? o['id']}',
                  style: GoogleFonts.jost(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: c.withValues(alpha: 0.3)),
                ),
                child: Text(OrderStatus.label(status),
                    style: GoogleFonts.jost(fontSize: 11.sp, fontWeight: FontWeight.w700, color: c)),
              ),
            ]),
            SizedBox(height: 6.h),
            Text('${o['shop_name'] ?? ''}  →  ${o['customer'] ?? 'Customer'}',
                style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.textSecondary)),
            if (addr != null) ...[
              SizedBox(height: 6.h),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.location_on_outlined, size: 15.sp, color: AppColors.hint),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text('${addr['full_address'] ?? ''}  ${addr['pin_code'] ?? ''}',
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  void _openDetail(Map o) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        final items = (o['items'] as List?) ?? [];
        final status = (o['status'] ?? '').toString().toLowerCase();
        final addr = o['address'] as Map?;
        final next = _nextAction[status];
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40.w, height: 4.h,
                    decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(4.r))),
                ),
                SizedBox(height: 14.h),
                Text('Order #${o['parent_order_id'] ?? o['id']}',
                    style: GoogleFonts.jost(fontSize: 17.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 2.h),
                Text('From ${o['shop_name'] ?? ''}',
                    style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
                Divider(height: 20.h, color: AppColors.dividerColor),
                if (addr != null) ...[
                  Text('${addr['name'] ?? o['customer'] ?? 'Customer'}',
                      style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 2.h),
                  Text('${addr['full_address'] ?? ''}  ${addr['pin_code'] ?? ''}',
                      style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.textSecondary)),
                  SizedBox(height: 10.h),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _call(addr['phone']?.toString()),
                        icon: Icon(Icons.call_rounded, size: 18.sp, color: AppColors.primary),
                        label: Text('Call', style: GoogleFonts.jost(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigate('${addr['full_address'] ?? ''} ${addr['pin_code'] ?? ''}'),
                        icon: Icon(Icons.navigation_rounded, size: 18.sp, color: AppColors.primary),
                        label: Text('Navigate', style: GoogleFonts.jost(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                  ]),
                ],
                Divider(height: 20.h, color: AppColors.dividerColor),
                Text('Items (${items.length})',
                    style: GoogleFonts.jost(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                SizedBox(height: 8.h),
                ...items.map((it) => _item(it)),
                Divider(height: 16.h, color: AppColors.dividerColor),
                Row(children: [
                  Text('Order value', style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.textSecondary)),
                  const Spacer(),
                  Text('₹${_num(o['total']).toStringAsFixed(0)}',
                      style: GoogleFonts.jost(fontSize: 15.sp, fontWeight: FontWeight.w800)),
                ]),
                SizedBox(height: 18.h),
                if (next != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _setStatus(o['id'], next['to']!);
                      },
                      child: Text(next['label']!,
                          style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  )
                else
                  Center(
                    child: Text(
                      OrderStatus.isCancelled(status) ? 'Order cancelled' : 'Delivered ✓',
                      style: GoogleFonts.jost(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: OrderStatus.isCancelled(status) ? AppColors.error : AppColors.success),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
