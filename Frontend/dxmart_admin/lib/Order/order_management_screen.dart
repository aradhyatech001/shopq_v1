import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/admin_api.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import '../CustomWidgets/admin_widgets.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/order_status.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  // ── State ─────────────────────────────────────────────────
  List _orders = [];
  List _filtered = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _totalOrders = 0;
  bool _hasMore = true;
  String _statusFilter = 'all';

  // Selected order for detail panel
  Map<String, dynamic>? _selected;

  // Settlement data for the selected order (lazy-loaded)
  Map<String, dynamic>? _settlement;
  bool _loadingSettlement = false;

  DateTime? _startDate;
  DateTime? _endDate;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Canonical lifecycle (shared with user/vendor/backend).
  static const List<String> _statuses = [
    'all',
    'pending',
    'confirmed',
    'packed',
    'assigned',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  // Statuses an admin can set manually (overrides the derived parent status).
  static const List<String> _settableStatuses = [
    'pending',
    'confirmed',
    'packed',
    'assigned',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 100) {
        if (_hasMore && !_loadingMore) _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Summary ───────────────────────────────────────────────
  Map<String, Map<String, dynamic>> get _summary {
    final m = {
      for (final s in _statuses) s: {'count': 0, 'amount': 0.0},
    };
    for (final od in _orders) {
      final o = od['order'];
      final st = (o['status'] ?? '').toString().toLowerCase();
      final amt = double.tryParse(o['final_amount'].toString()) ?? 0;
      m['all']!['count'] = (m['all']!['count'] as int) + 1;
      m['all']!['amount'] = (m['all']!['amount'] as double) + amt;
      if (m.containsKey(st)) {
        m[st]!['count'] = (m[st]!['count'] as int) + 1;
        m[st]!['amount'] = (m[st]!['amount'] as double) + amt;
      }
    }
    return m;
  }

  // ── Filter ────────────────────────────────────────────────
  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _orders.where((od) {
        final o = od['order'];
        final st = (o['status'] ?? '').toString().toLowerCase();
        if (_statusFilter != 'all' && st != _statusFilter) return false;
        if (q.isNotEmpty) {
          final id = o['id'].toString();
          final name = (o['name'] ?? '').toString().toLowerCase();
          final ph = (o['phone'] ?? '').toString();
          if (!id.contains(q) && !name.contains(q) && !ph.contains(q)) {
            return false;
          }
        }
        if (_startDate != null || _endDate != null) {
          final dt = _parseDate(o['order_datetime']);
          if (dt == null) return true;
          if (_startDate != null && dt.isBefore(_startDate!)) return false;
          if (_endDate != null &&
              dt.isAfter(_endDate!.add(const Duration(days: 1))))
            return false;
        }
        return true;
      }).toList();

      // Keep selected in sync
      if (_selected != null) {
        final sid = _selected!['order']['id'].toString();
        final still = _filtered.firstWhere(
          (od) => od['order']['id'].toString() == sid,
          orElse: () => null,
        );
        if (still == null) _selected = null;
      }
    });
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateFormat('dd-MM-yyyy hh:mm a').parse(raw.toString());
    } catch (_) {}
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  // ── Fetch ──────────────────────────────────────────────────
  Future<void> _fetchOrders({bool refresh = false}) async {
    if (refresh)
      setState(() {
        _page = 1;
        _hasMore = true;
      });
    if (_page == 1) setState(() => _loading = true);

    try {
      final res = await AdminApi.get(
        Uri.parse('${ApiConstants.GET_ALL_ORDER}?page=$_page&limit=15'),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          if (refresh || _page == 1) {
            _orders = data['orders'];
          } else {
            _orders.addAll(data['orders']);
          }
          _page = data['pagination']['current_page'];
          _totalOrders = data['pagination']['total_orders'];
          _hasMore = data['pagination']['has_next'] == true;
          _loading = false;
          _loadingMore = false;
        });
        _applyFilter();
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    setState(() {
      _loadingMore = true;
      _page++;
    });
    await _fetchOrders();
  }

  Future<void> _fetchSettlement(int orderId) async {
    setState(() {
      _settlement = null;
      _loadingSettlement = true;
    });
    try {
      final res = await AdminApi.get(
        Uri.parse(ApiConstants.orderSettlement(orderId)),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _settlement = data);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingSettlement = false);
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.UPDATE_ORDER_STATUS),
        body: {'order_id': orderId.toString(), 'status': newStatus},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Updated to $newStatus', AppColors.successColor);
        _fetchOrders(refresh: true);
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.errorColor);
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.jost(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _snack('$label copied', AppColors.successColor);
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  Color _statusColor(String s) => OrderStatus.color(s);

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'confirmed':
        return Icons.task_alt_rounded;
      case 'packed':
        return Icons.inventory_2_rounded;
      case 'assigned':
        return Icons.delivery_dining_rounded;
      case 'out_for_delivery':
      case 'way':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  // ── Print ──────────────────────────────────────────────────
  Future<void> _printBill(dynamic orderData) async {
    final order = orderData['order'];
    final items = orderData['items'] as List;

    // Helper — strip Unicode chars PDF default font can't render
    String safe(dynamic v, [String fallback = 'N/A']) {
      return (v?.toString() ?? fallback)
          .replaceAll('\u20b9', 'Rs.') // ₹
          .replaceAll('\u2014', '-') // —
          .replaceAll('\u2022', '*') // •
          .replaceAll('\u00d7', 'x'); // ×
    }

    String safeAmt(dynamic v) => 'Rs. ${v ?? 0}';

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text('DxMart', style: const pw.TextStyle(fontSize: 14)),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),

            // Order info
            pw.Text(
              'Order #${order["id"]}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Date: ${safe(order["order_datetime"])}'),
            pw.Text(
              'Delivery: ${_fmtDate(order["delivery_date"]?.toString())} ${safe(order["delivery_time"])}',
            ),
            pw.Text('Payment: ${safe(order["payment_method"])}'),
            pw.SizedBox(height: 10),

            // Customer
            pw.Text(
              'CUSTOMER',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Name: ${safe(order["name"])}'),
            pw.Text('Phone: ${safe(order["phone"])}'),
            pw.Text(
              'Address: ${safe(order["full_address"])}, ${safe(order["pin_code"])}',
            ),
            if ((order["landmark"] ?? '').toString().isNotEmpty)
              pw.Text('Landmark: ${safe(order["landmark"])}'),
            pw.SizedBox(height: 10),
            pw.Divider(),

            // Items
            pw.Text(
              'ITEMS',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            ...items.map(
              (i) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${safe(i["product_name"])} (${safe(i["name"], "Default")}) x${i["quantity"]}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Text(
                      safeAmt(i["selling_price"] ?? i["price"]),
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Divider(),

            // Totals
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Delivery Charge:'),
                pw.Text(safeAmt(order["delivery_charge"])),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Handling Charge:'),
                pw.Text(safeAmt(order["handling_charge"])),
              ],
            ),
            if ((order['discount_amount'] ?? 0).toString() != '0')
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Discount:'),
                  pw.Text('- Rs. ${order["discount_amount"]}'),
                ],
              ),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  safeAmt(order["final_amount"]),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  // ── Status dialog ──────────────────────────────────────────
  void _showStatusDialog(int orderId, String current) {
    String? selected = current;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(
          'Update Status',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: $current',
              style: GoogleFonts.jost(
                color: AppColors.secondaryTextColor,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 14.h),
            StatefulBuilder(
              builder: (_, setSt) => DropdownButtonFormField<String>(
                // Guard: a derived parent status (e.g. processing) isn't settable.
                value: _settableStatuses.contains(selected) ? selected : null,
                decoration: const InputDecoration(),
                items: _settableStatuses
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          OrderStatus.label(s),
                          style: GoogleFonts.jost(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setSt(() => selected = v),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.jost()),
          ),
          ElevatedButton(
            onPressed: () {
              if (selected != null) {
                Navigator.pop(context);
                _updateStatus(orderId, selected!);
              }
            },
            child: Text('Update', style: GoogleFonts.jost(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sum = _summary;

    return AdminPageShell(
      title: 'Orders',
      subtitle: '$_totalOrders total',
      actions: [
        IconButton(
          onPressed: () => _fetchOrders(refresh: true),
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ],
      child: Row(
        children: [
          // ════════════════════════════════════════════════
          // LEFT — filter + order list
          // ════════════════════════════════════════════════
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Status chips strip
                _buildStatusStrip(sum),

                // Search + date filter
                _buildFilterBar(),

                // Count
                Container(
                  color: AppColors.backgroundColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filtered.length} orders',
                        style: GoogleFonts.jost(
                          fontSize: 12.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      Text(
                        'Total: $_totalOrders',
                        style: GoogleFonts.jost(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(child: _buildOrderList()),
              ],
            ),
          ),

          // Divider
          const VerticalDivider(width: 1),

          // ════════════════════════════════════════════════
          // RIGHT — order detail panel
          // ════════════════════════════════════════════════
          Expanded(
            flex: 4,
            child: _selected == null
                ? _emptyDetail()
                : _buildDetailPanel(_selected!),
          ),
        ],
      ),
    );
  }

  // ── Status strip ──────────────────────────────────────────
  Widget _buildStatusStrip(Map<String, Map<String, dynamic>> sum) {
    return Container(
      color: AppColors.surfaceColor,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: _statuses.skip(1).map((s) {
          final c = _statusColor(s);
          final sel = _statusFilter == s;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _statusFilter = s);
                _applyFilter();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding: EdgeInsets.symmetric(vertical: 7.h),
                decoration: BoxDecoration(
                  color: sel
                      ? c.withValues(alpha: 0.12)
                      : AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: sel ? c : AppColors.borderColor,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(s), color: c, size: 15.sp),
                    SizedBox(height: 2.h),
                    Text(
                      '${sum[s]!['count']}',
                      style: GoogleFonts.jost(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: c,
                      ),
                    ),
                    Text(
                      OrderStatus.label(s).toUpperCase(),
                      style: GoogleFonts.jost(
                        fontSize: 8.sp,
                        color: c,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Filter bar ────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surfaceColor,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: AdminSearchBar(
              controller: _searchCtrl,
              hint: 'Search ID, name, phone...',
              onClear: () {
                setState(() => _searchCtrl.clear());
                _applyFilter();
              },
            ),
          ),
          SizedBox(width: 8.w),
          _datePill(
            label: _startDate != null
                ? DateFormat('dd/MM').format(_startDate!)
                : 'From',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (d != null) {
                setState(() => _startDate = d);
                _applyFilter();
              }
            },
          ),
          SizedBox(width: 4.w),
          _datePill(
            label: _endDate != null
                ? DateFormat('dd/MM').format(_endDate!)
                : 'To',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (d != null) {
                setState(() => _endDate = d);
                _applyFilter();
              }
            },
          ),
          if (_startDate != null || _endDate != null) ...[
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
                _applyFilter();
              },
              child: Container(
                height: 36.h,
                width: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.clear_rounded,
                  color: AppColors.errorColor,
                  size: 16.sp,
                ),
              ),
            ),
          ],
          SizedBox(width: 8.w),
          // All button
          GestureDetector(
            onTap: () {
              setState(() => _statusFilter = 'all');
              _applyFilter();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _statusFilter == 'all'
                    ? AppColors.primaryLight
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _statusFilter == 'all'
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                ),
              ),
              child: Text(
                'All (${_summary['all']!['count']})',
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  color: _statusFilter == 'all'
                      ? AppColors.primaryColor
                      : AppColors.secondaryTextColor,
                  fontWeight: _statusFilter == 'all'
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePill({required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Order list ────────────────────────────────────────────
  Widget _buildOrderList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_rounded,
        message: 'No orders found',
        hint: 'Try adjusting filters',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _fetchOrders(refresh: true),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: EdgeInsets.all(12.w),
        itemCount: _filtered.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (_, i) {
          if (i == _filtered.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final od = _filtered[i];
          final order = od['order'];
          final status = (order['status'] ?? '').toString().toLowerCase();
          final color = _statusColor(status);
          final isSelected =
              _selected != null &&
              _selected!['order']['id'].toString() == order['id'].toString();

          return GestureDetector(
            onTap: () {
              setState(() => _selected = od);
              _fetchSettlement(int.tryParse(order['id'].toString()) ?? 0);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.06)
                    : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected ? null : AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  // Order # badge
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        '#${order["id"]}',
                        style: GoogleFonts.jost(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Name + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['name'] ?? '—',
                          style: GoogleFonts.jost(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          order['order_datetime'] ?? '—',
                          style: GoogleFonts.jost(
                            fontSize: 10.sp,
                            color: AppColors.hintTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Amount + status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order["final_amount"]}',
                        style: GoogleFonts.jost(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      StatusBadge(
                        label: OrderStatus.label(status),
                        color: color,
                      ),
                    ],
                  ),

                  // Arrow indicator
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.sp,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.hintTextColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty detail placeholder ──────────────────────────────
  Widget _emptyDetail() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app_rounded,
          size: 52.sp,
          color: AppColors.hintTextColor,
        ),
        SizedBox(height: 12.h),
        Text(
          'Select an order',
          style: GoogleFonts.jost(
            fontSize: 16.sp,
            color: AppColors.secondaryTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Click any order on the left to view details',
          style: GoogleFonts.jost(
            fontSize: 12.sp,
            color: AppColors.hintTextColor,
          ),
        ),
      ],
    ),
  );

  // ── Detail panel ──────────────────────────────────────────
  Widget _buildDetailPanel(Map<String, dynamic> orderData) {
    final order = orderData['order'];
    final items = (orderData['items'] ?? []) as List;
    final status = (order['status'] ?? '').toString().toLowerCase();
    final color = _statusColor(status);
    final orderId = int.tryParse(order['id'].toString()) ?? 0;

    return Container(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          // ── Panel header ─────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: const BoxDecoration(
              color: AppColors.surfaceColor,
              border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Order #${order["id"]}',
                    style: GoogleFonts.jost(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                StatusBadge(
                  label: status == 'way' ? 'On Way' : _cap(status),
                  color: color,
                ),
                const Spacer(),
                // Update status button
                OutlinedButton.icon(
                  onPressed: () => _showStatusDialog(orderId, status),
                  icon: Icon(Icons.update_rounded, size: 14.sp),
                  label: Text(
                    'Status',
                    style: GoogleFonts.jost(fontSize: 12.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Print button
                ElevatedButton.icon(
                  onPressed: () => _printBill(orderData),
                  icon: Icon(
                    Icons.print_rounded,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Print',
                    style: GoogleFonts.jost(
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Panel body ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order info ────────────────────────────
                  _panelSection('ORDER INFO', [
                    _infoRow('Date', order['order_datetime'] ?? '—'),
                    _infoRow(
                      'Delivery',
                      '${_fmtDate(order["delivery_date"])} ${order["delivery_time"] ?? ""}',
                    ),
                    _infoRow('Payment', order['payment_method'] ?? '—'),
                    _infoRow(
                      'Del. Charge',
                      '₹${order["delivery_charge"] ?? 0}',
                    ),
                    _infoRow('Handling', '₹${order["handling_charge"] ?? 0}'),
                    if ((order['discount_amount'] ?? 0).toString() != '0')
                      _infoRow(
                        'Discount',
                        '-₹${order["discount_amount"]}',
                        valueColor: AppColors.successColor,
                      ),
                    _infoRow('Gift', order['gift'] ?? '—'),
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Row(
                        children: [
                          SizedBox(width: 100.w),
                          Expanded(
                            child: Text(
                              'Total  ₹${order["final_amount"]}',
                              style: GoogleFonts.jost(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  SizedBox(height: 16.h),

                  // ── Customer info ─────────────────────────
                  _panelSection('CUSTOMER', [
                    _infoRow('Name', order['name'] ?? '—'),
                    _infoRowCopy(
                      'Phone',
                      order['phone'] ?? '—',
                      () => _copy(order['phone'] ?? '', 'Phone'),
                    ),
                    _infoRowCopy(
                      'Address',
                      '${order["full_address"] ?? "—"}, ${order["pin_code"] ?? ""}',
                      () => _copy(
                        '${order["full_address"] ?? ""}, ${order["pin_code"] ?? ""}',
                        'Address',
                      ),
                    ),
                    if ((order['landmark'] ?? '').toString().isNotEmpty)
                      _infoRow('Landmark', order['landmark']),
                  ]),

                  SizedBox(height: 16.h),

                  // ── Order items ───────────────────────────
                  _panelSectionTitle('ITEMS (${items.length})'),
                  SizedBox(height: 10.h),
                  ...items.map((item) => _buildItemCard(item)),

                  SizedBox(height: 16.h),

                  // ── Settlement breakdown ──────────────────
                  _panelSectionTitle('SETTLEMENT'),
                  SizedBox(height: 10.h),
                  _buildSettlementSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Settlement section ────────────────────────────────────
  Widget _buildSettlementSection() {
    if (_loadingSettlement) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_settlement == null) {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Text(
          'Settlement data unavailable.',
          style: GoogleFonts.jost(
            fontSize: 12.sp,
            color: AppColors.hintTextColor,
          ),
        ),
      );
    }

    final summary = _settlement!['summary'] as Map<String, dynamic>? ?? {};
    final vendors = (_settlement!['vendors'] as List?) ?? [];
    final platform = _settlement!['platform'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Summary card ─────────────────────────────
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              _infoRow('Cart Total', '₹${summary['total_amount'] ?? 0}'),
              if ((summary['coupon_discount'] as num? ?? 0) > 0)
                _infoRow(
                  'Coupon (${summary['coupon_code'] ?? ''})',
                  '-₹${summary['coupon_discount']}',
                  valueColor: AppColors.successColor,
                ),
              _infoRow('Delivery', '₹${summary['delivery_charge'] ?? 0}'),
              _infoRow('Handling', '₹${summary['handling_charge'] ?? 0}'),
              Divider(height: 14.h, color: AppColors.borderColor),
              _infoRow(
                'Final Amount',
                '₹${summary['final_amount'] ?? 0}',
                valueColor: AppColors.primaryColor,
              ),
              _infoRow('Payment', summary['payment_method']?.toString() ?? '—'),
              _infoRow('Pay Status', summary['payment_status']?.toString() ?? '—'),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // ── Platform totals ───────────────────────────
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platform Commission',
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                '₹${(platform['total_commission'] as num? ?? 0).toStringAsFixed(2)}',
                style: GoogleFonts.jost(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // ── Per-vendor breakdown ──────────────────────
        if (vendors.isNotEmpty) ...[
          Text(
            'VENDOR BREAKDOWN',
            style: GoogleFonts.jost(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryTextColor,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          ...vendors.map((v) => _buildVendorSettlementCard(v as Map)),
        ],
      ],
    );
  }

  Widget _buildVendorSettlementCard(Map v) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: AppColors.borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                v['vendor_name']?.toString() ?? 'Vendor #${v['vendor_id']}',
                style: GoogleFonts.jost(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: v['payout_id'] != null
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                v['payout_id'] != null ? 'Paid out' : 'Unpaid',
                style: GoogleFonts.jost(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: v['payout_id'] != null
                      ? AppColors.successColor
                      : AppColors.warningColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        _infoRow('Items Subtotal', '₹${v['items_subtotal'] ?? 0}'),
        _infoRow('Coupon Share', '-₹${v['coupon_share'] ?? 0}'),
        _infoRow('Commission', '-₹${v['commission_amount'] ?? 0}'),
        Divider(height: 10.h, color: AppColors.borderColor),
        _infoRow(
          'Vendor Earns',
          '₹${(v['vendor_earning'] as num? ?? 0).toStringAsFixed(2)}',
          valueColor: AppColors.successColor,
        ),
        if (v['cod_collected'] != null && (v['cod_collected'] as num) > 0)
          _infoRow('COD Collected', '₹${v['cod_collected']}'),
      ],
    ),
  );

  Widget _panelSection(String title, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _panelSectionTitle(title),
      SizedBox(height: 10.h),
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(children: rows),
      ),
    ],
  );

  Widget _panelSectionTitle(String t) => Text(
    t,
    style: GoogleFonts.jost(
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.secondaryTextColor,
      letterSpacing: 1,
    ),
  );

  Widget _infoRow(String label, String value, {Color? valueColor}) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: GoogleFonts.jost(
              fontSize: 12.sp,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.jost(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.primaryTextColor,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _infoRowCopy(String label, String value, VoidCallback onCopy) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            SizedBox(
              width: 100.w,
              child: Text(
                label,
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.jost(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: onCopy,
              child: Icon(
                Icons.copy_rounded,
                size: 14.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildItemCard(dynamic item) => Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: AppColors.borderColor),
    ),
    child: Row(
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.network(
            item['image_url'] ?? '',
            width: 48.w,
            height: 48.w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48.w,
              height: 48.w,
              color: AppColors.primaryLight,
              child: Icon(
                Icons.shopping_bag_rounded,
                size: 22.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Name + variant
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['product_name'] ?? '—',
                style: GoogleFonts.jost(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.h),
              Text(
                '${item["name"] ?? "Default"} · Qty: ${item["quantity"]}',
                style: GoogleFonts.jost(
                  fontSize: 11.sp,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),

        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${item["selling_price"] ?? item["price"] ?? "—"}',
              style: GoogleFonts.jost(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColor,
              ),
            ),
            if (item['price'] != null &&
                item['price'].toString() != item['selling_price'].toString())
              Text(
                '₹${item["price"]}',
                style: GoogleFonts.jost(
                  fontSize: 11.sp,
                  color: AppColors.hintTextColor,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
