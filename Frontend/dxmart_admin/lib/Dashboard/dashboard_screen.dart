import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── State ──────────────────────────────────────────────────
  bool _loading = true;
  List _orders = [];
  int _totalOrders = 0;
  double _todaySales = 0;
  int _pendingOrders = 0;
  double _totalRevenue = 0;
  int _totalUsers = 0;

  List<double> _weeklySales = List.filled(7, 0);
  List<Map<String, dynamic>> _recentOrders = [];

  // ── Init ───────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([_fetchDashboard(), _fetchTotalUsers()]);
    if (mounted) setState(() => _loading = false);
  }

  // ── API: dashboard orders ──────────────────────────────────
  Future<void> _fetchDashboard() async {
    try {
      final res = await AdminApi.get(
        Uri.parse(ApiConstants.GET_ALL_ORDER_DASHBOARD),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && mounted) {
          _orders = data['orders'] ?? [];
          _computeStats();
        }
      }
    } catch (e) {
      debugPrint('Dashboard fetch error: $e');
    }
  }

  // ── API: total user count ──────────────────────────────────
  Future<void> _fetchTotalUsers() async {
    try {
      final res = await AdminApi.get(
        Uri.parse('${ApiConstants.GET_ALL_USER}?limit=1&offset=0'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && mounted) {
          _totalUsers = data['total'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Users fetch error: $e');
    }
  }

  // ── Compute stats from orders list ────────────────────────
  void _computeStats() {
    _totalOrders = _orders.length;
    _todaySales = 0;
    _pendingOrders = 0;
    _totalRevenue = 0;
    _weeklySales = List.filled(7, 0);
    _recentOrders = [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6));

    for (final od in _orders) {
      final order = od['order'];
      final amount = double.tryParse(order['final_amount'].toString()) ?? 0;
      final status = (order['status'] ?? '').toString().toLowerCase();

      if (status == 'cancelled') continue;

      _totalRevenue += amount;
      if (status == 'pending') _pendingOrders++;

      final date = _parseDate(order['order_datetime']);
      if (date == null) continue;
      final day = DateTime(date.year, date.month, date.day);

      if (day == today) _todaySales += amount;

      if (!day.isBefore(weekAgo) && !day.isAfter(today)) {
        final idx = day.difference(weekAgo).inDays;
        if (idx >= 0 && idx < 7) _weeklySales[idx] += amount;
      }
    }

    // Recent 5 orders (all statuses)
    _recentOrders = _orders.take(5).map((od) {
      final o = od['order'];
      return {
        'id': o['id'],
        'customer': o['name'] ?? '—',
        'address': o['full_address'] ?? '—',
        'contact': o['phone'] ?? '—',
        'amount': double.tryParse(o['final_amount'].toString()) ?? 0.0,
        'status': (o['status'] ?? '').toString(),
      };
    }).toList();
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    // Try ISO first
    try {
      return DateTime.parse(s);
    } catch (_) {}
    // Try dd-MM-yyyy HH:mm a / dd-MM-yyyy ...
    try {
      final parts = s.split(' ');
      final dp = parts[0].split('-');
      if (dp.length == 3) {
        return DateTime(int.parse(dp[2]), int.parse(dp[1]), int.parse(dp[0]));
      }
    } catch (_) {}
    return null;
  }

  // ── Helpers ────────────────────────────────────────────────
  String _fmt(double v) => NumberFormat('₹#,##0.##', 'en_IN').format(v);

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return AppColors.warningColor;
      case 'packed':
        return AppColors.infoColor;
      case 'way':
        return const Color(0xFF00BFA5);
      case 'delivered':
        return AppColors.successColor;
      case 'cancelled':
        return AppColors.errorColor;
      default:
        return AppColors.secondaryTextColor;
    }
  }

  double get _chartMaxY {
    final m = _weeklySales.fold(0.0, (a, b) => a > b ? a : b);
    return m == 0 ? 100 : m * 1.25;
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadAll,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildStatCards(),
                  SizedBox(height: 24.h),
                  _buildMiddleRow(),
                  SizedBox(height: 24.h),
                  _buildRecentOrders(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting + ', Admin 👋',
              style: GoogleFonts.jost(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(now),
              style: GoogleFonts.jost(
                fontSize: 13.sp,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
        ),
        // Refresh button
        OutlinedButton.icon(
          onPressed: _loadAll,
          icon: Icon(Icons.refresh_rounded, size: 16.sp),
          label: Text('Refresh', style: GoogleFonts.jost(fontSize: 13.sp)),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }

  // ── 4 stat cards ─────────────────────────────────────────
  Widget _buildStatCards() {
    final cards = [
      _StatCardData(
        title: 'Total Orders',
        value: _totalOrders.toString(),
        icon: Icons.receipt_long_rounded,
        color: AppColors.cardBlue,
        subtitle: 'All time',
      ),
      _StatCardData(
        title: "Today's Sales",
        value: _fmt(_todaySales),
        icon: Icons.currency_rupee_rounded,
        color: AppColors.cardPurple,
        subtitle: DateFormat('d MMM').format(DateTime.now()),
      ),
      _StatCardData(
        title: 'Total Revenue',
        value: _fmt(_totalRevenue),
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.cardGreen,
        subtitle: 'Excl. cancelled',
      ),
      _StatCardData(
        title: 'Pending Orders',
        value: _pendingOrders.toString(),
        icon: Icons.pending_actions_rounded,
        color: AppColors.cardOrange,
        subtitle: 'Needs attention',
      ),
      _StatCardData(
        title: 'Total Users',
        value: _totalUsers.toString(),
        icon: Icons.people_rounded,
        color: AppColors.cardRed,
        subtitle: 'Registered',
      ),
    ];

    return LayoutBuilder(
      builder: (_, c) {
        final cols = c.maxWidth > 900 ? 5 : 2;
        // 5-col wide layout: cards are ~180px wide so 2.8 ratio ≈ 64px tall ✓
        // 2-col narrow layout: cards are ~105px wide so use 1.6 ratio ≈ 66px tall ✓
        final aspectRatio = cols == 5 ? 2.8 : 1.6;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (_, i) => _StatCard(data: cards[i]),
        );
      },
    );
  }

  // ── Chart + Quick Actions row ─────────────────────────────
  Widget _buildMiddleRow() {
    return LayoutBuilder(
      builder: (_, c) {
        final wide = c.maxWidth > 800;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildChart()),
              SizedBox(width: 20.w),
              Expanded(flex: 2, child: _buildQuickActions()),
            ],
          );
        }
        return Column(
          children: [
            _buildChart(),
            SizedBox(height: 16.h),
            _buildQuickActions(),
          ],
        );
      },
    );
  }

  // ── Weekly sales bar chart ────────────────────────────────
  Widget _buildChart() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _DashCard(
      title: 'Weekly Sales',
      trailing: Text(
        '${DateFormat('d MMM').format(weekAgo)} – ${DateFormat('d MMM').format(now)}',
        style: GoogleFonts.jost(
          fontSize: 11.sp,
          color: AppColors.secondaryTextColor,
        ),
      ),
      child: SizedBox(
        height: 220.h,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _chartMaxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.sidebarColor,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  _fmt(rod.toY),
                  GoogleFonts.jost(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final d = weekAgo.add(Duration(days: v.toInt()));
                    return Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        days[d.weekday - 1],
                        style: GoogleFonts.jost(
                          fontSize: 11.sp,
                          color: AppColors.secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.borderColor, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (i) {
              final hasData = _weeklySales[i] > 0;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: _weeklySales[i],
                    color: hasData
                        ? AppColors.primaryColor
                        : AppColors.borderColor,
                    width: 28.w,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6.r),
                      topRight: Radius.circular(6.r),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Quick action buttons ──────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _QAItem(Icons.category_rounded, 'Category', AppColors.cardTeal),
      _QAItem(Icons.shopping_bag_rounded, 'Products', AppColors.cardPurple),
      _QAItem(Icons.inventory_2_rounded, 'Stock', AppColors.cardOrange),
      _QAItem(Icons.receipt_long_rounded, 'Orders', AppColors.cardBlue),
      _QAItem(Icons.local_offer_rounded, 'Coupons', AppColors.cardGreen),
      _QAItem(Icons.people_rounded, 'Users', AppColors.cardRed),
    ];

    return _DashCard(
      title: 'Quick Actions',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, i) => _QuickActionTile(item: actions[i]),
      ),
    );
  }

  // ── Recent orders table ───────────────────────────────────
  Widget _buildRecentOrders() {
    return _DashCard(
      title: 'Recent Orders',
      trailing: TextButton(
        onPressed: () {},
        child: Text(
          'View all →',
          style: GoogleFonts.jost(
            fontSize: 12.sp,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      child: _recentOrders.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 40.sp,
                      color: AppColors.hintTextColor,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No orders yet',
                      style: GoogleFonts.jost(
                        color: AppColors.secondaryTextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 700.w),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(80.w),
                    1: const FlexColumnWidth(2),
                    2: const FlexColumnWidth(3),
                    3: FixedColumnWidth(110.w),
                    4: FixedColumnWidth(120.w),
                    5: FixedColumnWidth(110.w),
                  },
                  children: [
                    // Header row
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF7F9FC)),
                      children: [
                        _thCell('Order #'),
                        _thCell('Customer'),
                        _thCell('Address'),
                        _thCell('Contact'),
                        _thCell('Amount'),
                        _thCell('Status'),
                      ],
                    ),
                    // Data rows
                    ..._recentOrders.map((o) {
                      final color = _statusColor(o['status']);
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.dividerColor),
                          ),
                        ),
                        children: [
                          _tdCell(
                            Text(
                              '#${o['id']}',
                              style: GoogleFonts.jost(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          _tdCell(
                            Text(
                              o['customer'],
                              style: GoogleFonts.jost(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _tdCell(
                            Text(
                              o['address'],
                              style: GoogleFonts.jost(
                                fontSize: 12.sp,
                                color: AppColors.secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _tdCell(
                            Text(
                              o['contact'],
                              style: GoogleFonts.jost(fontSize: 12.sp),
                            ),
                          ),
                          _tdCell(
                            Text(
                              _fmt(o['amount']),
                              style: GoogleFonts.jost(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _tdCell(
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _capitalize(o['status']),
                                style: GoogleFonts.jost(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _thCell(String t) => TableCell(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Text(
        t,
        style: GoogleFonts.jost(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryTextColor,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  Widget _tdCell(Widget child) => TableCell(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: child,
    ),
  );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

class _QAItem {
  final IconData icon;
  final String label;
  final Color color;
  const _QAItem(this.icon, this.label, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Stat summary card
class _StatCard extends StatelessWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(data.icon, color: data.color, size: 18.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.jost(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryTextColor,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  data.value,
                  style: GoogleFonts.jost(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  data.subtitle,
                  style: GoogleFonts.jost(
                    fontSize: 8.sp,
                    color: AppColors.hintTextColor,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Colored indicator bar
          Container(
            width: 3.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic dashboard card wrapper
class _DashCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _DashCard({required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: trailing != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.jost(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTextColor,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

/// Quick action tile
class _QuickActionTile extends StatelessWidget {
  final _QAItem item;
  const _QuickActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
