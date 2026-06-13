import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/vendor_api_helper.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List _orders  = [];
  bool _loading = true;
  String _filter = 'all'; // all | pending | processing | delivered | cancelled

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res  = await VendorApiHelper.get(ApiConstants.VENDOR_ORDERS);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _orders = data['orders'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List get _filtered {
    if (_filter == 'all') return _orders;
    return _orders.where((o) => o['status'] == _filter).toList();
  }

  /// Formats a money value that may arrive as a num OR a string ("129.00").
  String _money(dynamic v) {
    final n = v is num ? v : num.tryParse('${v ?? ''}') ?? 0;
    return n.toStringAsFixed(2);
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':  return AppColors.success;
      case 'pending':    return AppColors.warning;
      case 'cancelled':  return AppColors.error;
      case 'processing': return AppColors.primary;
      default:           return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'delivered':  return Icons.check_circle_rounded;
      case 'pending':    return Icons.schedule_rounded;
      case 'cancelled':  return Icons.cancel_rounded;
      case 'processing': return Icons.autorenew_rounded;
      default:           return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // ── Page header ───────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Orders',
                                    style: GoogleFonts.jost(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                Text(
                                  '${_orders.length} total',
                                  style: GoogleFonts.jost(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary),
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
                    ),
                  ),

                  // ── Filter chips ──────────────────────────────
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
                      child: Row(
                        children: ['all', 'pending', 'processing', 'delivered', 'cancelled']
                            .map((f) => _filterChip(f))
                            .toList(),
                      ),
                    ),
                  ),

                  // ── Order list ────────────────────────────────
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 56.sp, color: AppColors.hint),
                            SizedBox(height: 12.h),
                            Text('No orders found',
                                style: GoogleFonts.jost(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) => _orderCard(filtered[i]),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _filterChip(String f) {
    final isSelected = _filter == f;
    final label = f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1);
    final count = f == 'all'
        ? _orders.length
        : _orders.where((o) => o['status'] == f).length;

    return GestureDetector(
      onTap: () => setState(() => _filter = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: GoogleFonts.jost(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _orderCard(Map order) {
    final items  = (order['items'] as List?) ?? [];
    final status = order['status'] ?? '';
    final color  = _statusColor(status);

    return GestureDetector(
      onTap: () => _showDetail(order),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Text(
                    'Order #${order['id']}',
                    style: GoogleFonts.jost(
                        fontWeight: FontWeight.w700, fontSize: 14.sp),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status), size: 12.sp, color: color),
                        SizedBox(width: 4.w),
                        Text(
                          status.toUpperCase(),
                          style: GoogleFonts.jost(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // Customer
              Row(children: [
                Icon(Icons.person_outline_rounded,
                    size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Text(
                  order['user']?['name'] ?? 'Customer',
                  style: GoogleFonts.jost(
                      fontSize: 13.sp, color: AppColors.textSecondary),
                ),
              ]),
              SizedBox(height: 4.h),
              // Date
              if (order['created_at'] != null)
                Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 12.sp, color: AppColors.hint),
                  SizedBox(width: 6.w),
                  Text(
                    order['created_at'].toString().length >= 10
                        ? order['created_at'].toString().substring(0, 10)
                        : order['created_at'].toString(),
                    style: GoogleFonts.jost(
                        fontSize: 12.sp, color: AppColors.hint),
                  ),
                ]),
              SizedBox(height: 10.h),
              // Items preview
              if (items.isNotEmpty) ...[
                Text(
                  items.map((it) => it['product_name'] ?? 'Item').take(2).join(', ') +
                      (items.length > 2 ? ' +${items.length - 2} more' : ''),
                  style: GoogleFonts.jost(
                      fontSize: 12.sp, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
              ],
              // Total row
              Row(children: [
                Text(
                  '${items.length} item${items.length == 1 ? '' : 's'}',
                  style: GoogleFonts.jost(
                      fontSize: 12.sp, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '₹${_money(order['total'])}',
                  style: GoogleFonts.jost(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // Statuses a vendor may move an order through.
  static const List<String> _statusFlow = [
    'pending', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled',
  ];

  String _statusLabel(String s) =>
      s.split('_').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');

  Future<void> _updateStatus(int orderId, String status) async {
    try {
      final res = await VendorApiHelper.postJson(
        ApiConstants.VENDOR_ORDER_UPDATE_STATUS,
        body: {'order_id': orderId, 'status': status},
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (data['success'] == true) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${_statusLabel(status)}', style: GoogleFonts.jost())),
        );
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed', style: GoogleFonts.jost())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.jost())),
        );
      }
    }
  }

  void _showDetail(Map order) {
    final items  = (order['items'] as List?) ?? [];
    final status = order['status'] ?? '';
    final color  = _statusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (__, sc) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              // Title row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(children: [
                  Text('Order #${order['id']}',
                      style: GoogleFonts.jost(
                          fontSize: 18.sp, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.jost(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                  ),
                ]),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(children: [
                  Text(order['user']?['name'] ?? 'Customer',
                      style: GoogleFonts.jost(
                          fontSize: 13.sp, color: AppColors.textSecondary)),
                  if (order['created_at'] != null) ...[
                    Text('  ·  ',
                        style: GoogleFonts.jost(color: AppColors.hint)),
                    Text(
                      order['created_at'].toString().length >= 10
                          ? order['created_at'].toString().substring(0, 10)
                          : order['created_at'].toString(),
                      style: GoogleFonts.jost(
                          fontSize: 13.sp, color: AppColors.hint),
                    ),
                  ],
                ]),
              ),
              SizedBox(height: 16.h),
              Divider(color: AppColors.borderColor, height: 1),
              // Items list
              Expanded(
                child: ListView.separated(
                  controller: sc,
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  itemCount: items.length + 1, // +1 for total row
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) {
                    if (i == items.length) {
                      // Total
                      return Column(children: [
                        Divider(color: AppColors.borderColor),
                        SizedBox(height: 8.h),
                        Row(children: [
                          Text('Total',
                              style: GoogleFonts.jost(
                                  fontWeight: FontWeight.w700, fontSize: 15.sp)),
                          const Spacer(),
                          Text(
                            '₹${_money(order['total'])}',
                            style: GoogleFonts.jost(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: AppColors.primary),
                          ),
                        ]),
                      ]);
                    }
                    final item = items[i];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item['product_name'] ?? 'Item',
                            style: GoogleFonts.jost(
                                fontSize: 13.sp, color: AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '×${item['quantity'] ?? 1}',
                          style: GoogleFonts.jost(
                              fontSize: 13.sp, color: AppColors.textSecondary),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '₹${_money(item['price'])}',
                          style: GoogleFonts.jost(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // ── Status changer ───────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.borderColor)),
                ),
                padding: EdgeInsets.fromLTRB(
                    20.w, 12.h, 20.w, MediaQuery.of(context).padding.bottom + 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Update Status',
                        style: GoogleFonts.jost(
                            fontSize: 13.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _statusFlow.map((s) {
                        final selected = s == status;
                        final c = _statusColor(s);
                        return GestureDetector(
                          onTap: selected ? null : () => _updateStatus(order['id'], s),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: selected ? c.withOpacity(0.12) : AppColors.background,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                  color: selected ? c : AppColors.borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_statusIcon(s), size: 13.sp, color: c),
                                SizedBox(width: 5.w),
                                Text(
                                  _statusLabel(s),
                                  style: GoogleFonts.jost(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? c : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
