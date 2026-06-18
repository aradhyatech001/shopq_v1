import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/vendor_api_helper.dart';
import '../utils/vendor_widgets.dart';

/// Vendor orders — admin-style master-detail split (list left, detail right on
/// wide screens; a pushed detail page on narrow). Delivery flow:
/// pending → accept → pack → assign delivery boy → out for delivery → delivered.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List _orders = [];
  bool _loading = true;
  String _filter = 'all';
  dynamic _selectedId;
  Timer? _poll;

  static const _filters = [
    'all', 'pending', 'confirmed', 'packed',
    'assigned', 'out_for_delivery', 'delivered', 'cancelled',
  ];

  static const Map<String, Map<String, String>> _nextAction = {
    'pending':          {'label': 'Accept order',       'to': 'confirmed'},
    'confirmed':        {'label': 'Mark as packed',     'to': 'packed'},
    'packed':           {'label': 'Assign delivery boy','to': 'assign'},
    'assigned':         {'label': 'Out for delivery',   'to': 'out_for_delivery'},
    'out_for_delivery': {'label': 'Mark delivered',     'to': 'delivered'},
  };

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 20), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final res = await VendorApiHelper.get(ApiConstants.VENDOR_ORDERS);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _orders = data['orders'] ?? [];
          // Keep a selection on wide screens; default to the first order.
          _selectedId ??= _orders.isNotEmpty ? _orders.first['id'] : null;
        });
      }
    } catch (_) {
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  List get _filtered {
    if (_filter == 'all') return _orders;
    return _orders
        .where((o) => (o['status'] ?? '').toString().toLowerCase() == _filter)
        .toList();
  }

  int _countFor(String f) => f == 'all'
      ? _orders.length
      : _orders.where((o) => (o['status'] ?? '').toString().toLowerCase() == f).length;

  Map? get _selected {
    for (final o in _orders) {
      if (o['id'] == _selectedId) return o as Map;
    }
    return null;
  }

  double _num(v) => double.tryParse('${v ?? 0}') ?? 0;

  // ── Actions ───────────────────────────────────────────────
  Future<void> _act(Map o, String to, {bool fromPage = false}) async {
    if (to == 'assign') {
      _pickDeliveryBoy(o['id'], fromPage: fromPage);
      return;
    }
    final ok = await _updateStatus(o['id'], to);
    if (ok && fromPage && mounted) Navigator.pop(context);
  }

  Future<bool> _updateStatus(dynamic id, String status) async {
    try {
      final res = await VendorApiHelper.postJson(
        ApiConstants.VENDOR_ORDER_UPDATE_STATUS,
        body: {'vendor_order_id': id, 'status': status},
      );
      final data = jsonDecode(res.body);
      _toast(data['message'] ?? (data['success'] == true ? 'Updated' : 'Failed'));
      if (data['success'] == true) {
        await _load(silent: true);
        return true;
      }
    } catch (_) {
      _toast('Something went wrong');
    }
    return false;
  }

  Future<void> _assignDelivery(dynamic id, int boyId) async {
    try {
      final res = await VendorApiHelper.postJson(
        ApiConstants.VENDOR_ORDER_ASSIGN_DELIVERY,
        body: {'vendor_order_id': id, 'delivery_boy_id': boyId},
      );
      final data = jsonDecode(res.body);
      _toast(data['message'] ?? 'Done');
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

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return VendorPage(
      title: 'Orders',
      subtitle: '${_orders.length} order${_orders.length == 1 ? '' : 's'} for your shop',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _load(),
          icon: Icon(Icons.refresh_rounded, size: 20.sp, color: AppColors.textSecondary),
        ),
      ],
      child: Column(
        children: [
          _filterChips(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : wide
                    ? _splitView()
                    : _orderList(wide: false),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final sel = _filter == f;
          final label = f == 'all' ? 'All' : prettyStatus(f);
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: sel ? AppColors.primary : AppColors.borderColor),
              ),
              child: Text('$label (${_countFor(f)})',
                  style: GoogleFonts.jost(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }

  Widget _splitView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 4, child: _orderList(wide: true)),
        const VerticalDivider(width: 1, color: AppColors.borderColor),
        Expanded(
          flex: 5,
          child: _selected == null
              ? const VEmpty(icon: Icons.receipt_long_outlined, message: 'Select an order to view details')
              : _detail(_selected!, fromPage: false),
        ),
      ],
    );
  }

  Widget _orderList({required bool wide}) {
    if (_filtered.isEmpty) {
      return const VEmpty(icon: Icons.receipt_long_outlined, message: 'No orders here');
    }
    return RefreshIndicator(
      onRefresh: () => _load(),
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => _orderCard(_filtered[i], wide: wide),
      ),
    );
  }

  Widget _orderCard(Map o, {required bool wide}) {
    final items = (o['items'] as List?) ?? [];
    final status = (o['status'] ?? 'pending').toString();
    final selected = wide && o['id'] == _selectedId;
    return VCard(
      onTap: () {
        if (wide) {
          setState(() => _selectedId = o['id']);
        } else {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                elevation: 1,
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
                title: Text('Order #${o['parent_order_id'] ?? o['id']}',
                    style: GoogleFonts.jost(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              body: _detail(o, fromPage: true),
            ),
          ));
        }
      },
      child: Container(
        decoration: selected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary, width: 1.5),
              )
            : null,
        padding: selected ? EdgeInsets.all(2.w) : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Order #${o['parent_order_id'] ?? o['id']}',
                  style: GoogleFonts.jost(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              const Spacer(),
              VStatusChip(status: status),
            ]),
            SizedBox(height: 4.h),
            Text('${o['user']?['name'] ?? 'Customer'}  ·  ${o['created_at'] ?? ''}',
                style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
            SizedBox(height: 10.h),
            ...items.take(2).map((it) => Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Row(children: [
                    Expanded(child: Text('${it['product_name'] ?? ''}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jost(fontSize: 13.sp))),
                    Text('×${it['quantity']}',
                        style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.textSecondary)),
                  ]),
                )),
            if (items.length > 2)
              Text('+${items.length - 2} more',
                  style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hint)),
            Divider(height: 16.h, color: AppColors.dividerColor),
            Row(children: [
              Text('You collect', style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.textSecondary)),
              const Spacer(),
              Text('₹${money(_num(o['collect_amount'] ?? o['total']))}',
                  style: GoogleFonts.jost(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Detail (right panel on wide, pushed page body on narrow) ──
  Widget _detail(Map o, {required bool fromPage}) {
    final items = (o['items'] as List?) ?? [];
    final status = (o['status'] ?? 'pending').toString().toLowerCase();
    final addr = o['address'] as Map?;
    final next = _nextAction[status];

    return Container(
      color: AppColors.background,
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Row(children: [
            Expanded(
              child: Text('Order #${o['parent_order_id'] ?? o['id']}',
                  style: GoogleFonts.jost(fontSize: 18.sp, fontWeight: FontWeight.w800)),
            ),
            VStatusChip(status: status),
          ]),
          SizedBox(height: 4.h),
          Text('${o['user']?['name'] ?? 'Customer'}  ·  ${o['created_at'] ?? ''}',
              style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),

          if (addr != null) ...[
            SizedBox(height: 14.h),
            VCard(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.location_on_outlined, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${addr['name'] ?? o['user']?['name'] ?? 'Customer'}',
                        style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2.h),
                    Text('${addr['full_address'] ?? ''}  ${addr['pin_code'] ?? ''}',
                        style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
                    if ((addr['phone'] ?? '').toString().isNotEmpty)
                      Text('${addr['phone']}',
                          style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
                  ]),
                ),
              ]),
            ),
          ],

          SizedBox(height: 16.h),
          Text('Items to pack (${items.length})',
              style: GoogleFonts.jost(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          SizedBox(height: 8.h),
          ...items.map((it) => _detailItem(it)),

          SizedBox(height: 6.h),
          _settlementCard(o),

          SizedBox(height: 18.h),
          if (next != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: 14.h)),
                onPressed: () => _act(o, next['to']!, fromPage: fromPage),
                child: Text(next['label']!,
                    style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            SizedBox(height: 10.h),
          ],
          if (status != 'delivered' && status != 'cancelled')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                ),
                onPressed: () => _act(o, 'cancelled', fromPage: fromPage),
                child: Text('Cancel order', style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          if (status == 'delivered')
            Center(child: Text('Order delivered ✓',
                style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.success, fontWeight: FontWeight.w600))),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // Frozen settlement breakdown — read-only, never recomputed in the app.
  Widget _settlementCard(Map o) {
    final goods    = _num(o['goods_subtotal']);
    final coupon   = _num(o['coupon_share']);
    final delivery = _num(o['delivery_share']);
    final handling = _num(o['handling_share']);
    final collect  = _num(o['collect_amount'] ?? o['total']);
    final couponMap = o['coupon'] as Map?;
    final payMethod = (o['payment_method'] ?? 'COD').toString().toUpperCase();
    final payStatus = (o['payment_status'] ?? 'pending').toString();
    final paid = payStatus.toLowerCase() == 'paid';

    Widget line(String label, String value, {Color? color, bool bold = false}) => Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: Row(children: [
            Text(label, style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.textSecondary)),
            const Spacer(),
            Text(value,
                style: GoogleFonts.jost(
                    fontSize: bold ? 16.sp : 13.sp,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    color: color ?? AppColors.textPrimary)),
          ]),
        );

    return VCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settlement', style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w800)),
        SizedBox(height: 4.h),
        line('Product subtotal', '₹${money(goods)}'),
        if (coupon > 0) line('Coupon discount', '− ₹${money(coupon)}', color: AppColors.success),
        if (delivery > 0) line('Delivery share', '+ ₹${money(delivery)}'),
        if (handling > 0) line('Handling share', '+ ₹${money(handling)}'),
        Divider(height: 14.h, color: AppColors.dividerColor),
        line('You collect', '₹${money(collect)}', color: AppColors.primary, bold: true),
        SizedBox(height: 8.h),
        Row(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
                color: paid ? AppColors.success.withValues(alpha: 0.12) : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6.r)),
            child: Text(paid ? '$payMethod · PAID' : payMethod,
                style: GoogleFonts.jost(fontSize: 11.sp, fontWeight: FontWeight.w700,
                    color: paid ? AppColors.success : AppColors.primary)),
          ),
          if (couponMap != null) ...[
            SizedBox(width: 8.w),
            Expanded(
              child: Text('Coupon ${couponMap['code']}',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.textSecondary)),
            ),
          ],
        ]),
      ]),
    );
  }

  Widget _detailItem(Map it) {
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
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: AppColors.borderColor)),
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
              Text('₹${money(lineTotal)}', style: GoogleFonts.jost(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Delivery boy picker (dialog, not a bottom sheet) ──────
  // Your own riders are listed separately from the shared platform fleet.
  Future<void> _pickDeliveryBoy(dynamic orderId, {bool fromPage = false}) async {
    List boys = [];
    try {
      final res = await VendorApiHelper.get(ApiConstants.VENDOR_DELIVERY_BOYS);
      final data = jsonDecode(res.body);
      if (data['success'] == true) boys = data['data'] ?? [];
    } catch (_) {}

    final own = boys.where((b) => b['owned'] == true).toList();
    final platform = boys.where((b) => b['owned'] != true).toList();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Assign delivery boy', style: GoogleFonts.jost(fontWeight: FontWeight.w800, fontSize: 16.sp)),
        content: SizedBox(
          width: 380.w,
          child: boys.isEmpty
              ? Text('No delivery boys available. Add your own under Delivery Boys.',
                  style: GoogleFonts.jost(fontSize: 13.sp, color: AppColors.textSecondary))
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 420.h),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (own.isNotEmpty) ...[
                          _pickerHeader('Your riders', own.length, AppColors.primary),
                          ...own.map((b) => _riderTile(ctx, b, orderId, fromPage, owned: true)),
                        ],
                        if (platform.isNotEmpty) ...[
                          if (own.isNotEmpty) SizedBox(height: 12.h),
                          _pickerHeader('Platform fleet', platform.length, AppColors.textSecondary),
                          ...platform.map((b) => _riderTile(ctx, b, orderId, fromPage, owned: false)),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: GoogleFonts.jost())),
        ],
      ),
    );
  }

  Widget _pickerHeader(String label, int count, Color color) => Padding(
        padding: EdgeInsets.only(bottom: 4.h, top: 2.h),
        child: Row(children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.jost(fontSize: 11.sp, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.6)),
          SizedBox(width: 6.w),
          Text('($count)', style: GoogleFonts.jost(fontSize: 11.sp, color: AppColors.hint)),
        ]),
      );

  Widget _riderTile(BuildContext ctx, Map b, dynamic orderId, bool fromPage, {required bool owned}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: owned ? AppColors.primaryLight : AppColors.background,
        child: Icon(Icons.delivery_dining_rounded,
            color: owned ? AppColors.primary : AppColors.textSecondary, size: 20.sp),
      ),
      title: Text('${b['name'] ?? ''}',
          style: GoogleFonts.jost(fontSize: 14.sp, fontWeight: FontWeight.w600)),
      subtitle: Text('${b['mobile'] ?? ''}  ·  ${b['pin_code'] ?? ''}',
          style: GoogleFonts.jost(fontSize: 12.sp, color: AppColors.textSecondary)),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.hint, size: 20.sp),
      onTap: () async {
        Navigator.pop(ctx);
        await _assignDelivery(orderId, b['id'] is int ? b['id'] : int.tryParse('${b['id']}') ?? 0);
        if (fromPage && mounted) Navigator.pop(context);
      },
    );
  }
}
