import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen>
    with SingleTickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────
  late TabController _tabCtrl;
  final List<String> _tabs = ['all', 'pending', 'approved', 'rejected', 'suspended'];
  final List<String> _tabLabels = ['All', 'Pending', 'Approved', 'Rejected', 'Suspended'];

  List _vendors = [];
  bool _loading = false;

  // Stats
  int _totalCount   = 0;
  int _pendingCount = 0;
  int _approvedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _fetchVendors();
    });
    _fetchStats();
    _fetchVendors();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetchStats() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.ADMIN_VENDORS_STATS));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _totalCount    = data['data']['total']    ?? 0;
          _pendingCount  = data['data']['pending']  ?? 0;
          _approvedCount = data['data']['approved'] ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchVendors() async {
    setState(() => _loading = true);
    final status = _tabs[_tabCtrl.index];
    try {
      final uri = Uri.parse('${ApiConstants.ADMIN_VENDORS}?status=$status');
      final res = await AdminApi.get(uri);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _vendors = data['data'] ?? data['vendors'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(int id) async {
    await _postAction(ApiConstants.ADMIN_VENDOR_APPROVE, {'id': id});
  }

  Future<void> _reject(int id, String reason) async {
    await _postAction(ApiConstants.ADMIN_VENDOR_REJECT, {'id': id, 'reason': reason});
  }

  Future<void> _suspend(int id) async {
    await _postAction(ApiConstants.ADMIN_VENDOR_SUSPEND, {'id': id});
  }

  Future<void> _delete(int id) async {
    await _postAction(ApiConstants.ADMIN_VENDOR_DELETE, {'id': id});
  }

  Future<void> _postAction(String url, Map body) async {
    try {
      // NOTE: postJson() already json-encodes the body. Pass the Map directly —
      // jsonEncode here would double-encode it and the backend would read null.
      final res = await AdminApi.postJson(
        Uri.parse(url),
        body: body,
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        _showSnack(data['message'] ?? (data['success'] == true ? 'Done' : 'Failed'));
        _fetchStats();
        _fetchVendors();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Dialogs ───────────────────────────────────────────────
  void _showRejectDialog(int id) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reject Vendor', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Rejection reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _reject(id, ctrl.text.trim());
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showVendorDetails(Map vendor) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: 480.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: vendor['logo'] != null && vendor['logo'].toString().isNotEmpty
                      ? NetworkImage(vendor['logo'])
                      : null,
                  child: vendor['logo'] == null || vendor['logo'].toString().isEmpty
                      ? Icon(Icons.store, color: AppColors.primaryColor, size: 28.sp)
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(vendor['shop_name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16.sp)),
                    Text(vendor['name'] ?? '', style: GoogleFonts.poppins(color: AppColors.secondaryTextColor, fontSize: 13.sp)),
                  ]),
                ),
                _statusChip(vendor['status'] ?? ''),
              ]),
              Divider(height: 24.h),
              _detailRow(Icons.email_outlined, vendor['email'] ?? ''),
              if ((vendor['phone'] ?? '').isNotEmpty) _detailRow(Icons.phone_outlined, vendor['phone']),
              if ((vendor['shop_description'] ?? '').isNotEmpty)
                _detailRow(Icons.description_outlined, vendor['shop_description']),
              SizedBox(height: 8.h),
              if (vendor['active_subscription'] != null) ...[
                Text('Subscription', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                SizedBox(height: 4.h),
                _detailRow(Icons.card_membership_outlined,
                    '${vendor['active_subscription']['plan_name']} · expires ${vendor['active_subscription']['end_date']}'),
              ],
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(children: [
          Icon(icon, size: 16.sp, color: AppColors.secondaryTextColor),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 13.sp))),
        ]),
      );

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildStats(),
          _buildTabBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
        color: AppColors.surfaceColor,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(children: [
          Text('Vendor Management', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18.sp)),
          const Spacer(),
          IconButton(
            onPressed: () { _fetchStats(); _fetchVendors(); },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ]),
      );

  Widget _buildStats() => Container(
        color: AppColors.surfaceColor,
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
        child: Row(children: [
          _statCard('Total', _totalCount, AppColors.primaryColor),
          SizedBox(width: 12.w),
          _statCard('Pending', _pendingCount, Colors.orange),
          SizedBox(width: 12.w),
          _statCard('Approved', _approvedCount, Colors.green),
        ]),
      );

  Widget _statCard(String label, int count, Color color) => Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$count', style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.secondaryTextColor)),
          ]),
        ),
      );

  Widget _buildTabBar() => Container(
        color: AppColors.surfaceColor,
        child: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.sp),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13.sp),
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.secondaryTextColor,
          indicatorColor: AppColors.primaryColor,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      );

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_vendors.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.store_mall_directory_outlined, size: 56.sp, color: AppColors.hintTextColor),
          SizedBox(height: 12.h),
          Text('No vendors found', style: GoogleFonts.poppins(color: AppColors.secondaryTextColor)),
        ]),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _vendors.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, i) => _vendorCard(_vendors[i]),
    );
  }

  Widget _vendorCard(Map vendor) {
    final status = vendor['status'] ?? '';
    return Material(
      color: AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showVendorDetails(vendor),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: vendor['logo'] != null && vendor['logo'].toString().isNotEmpty
                  ? NetworkImage(vendor['logo'])
                  : null,
              child: vendor['logo'] == null || vendor['logo'].toString().isEmpty
                  ? Icon(Icons.store, color: AppColors.primaryColor, size: 20.sp)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(vendor['shop_name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                Text(vendor['email'] ?? '', style: GoogleFonts.poppins(color: AppColors.secondaryTextColor, fontSize: 12.sp)),
                if (vendor['active_subscription'] != null)
                  Text('📦 ${vendor['active_subscription']['plan_name']}',
                      style: GoogleFonts.poppins(color: Colors.green, fontSize: 11.sp)),
              ]),
            ),
            _statusChip(status),
            SizedBox(width: 8.w),
            _buildActions(vendor, status),
          ]),
        ),
      ),
    );
  }

  Widget _buildActions(Map vendor, String status) {
    final id = vendor['id'] as int;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (val) {
        switch (val) {
          case 'approve': _approve(id); break;
          case 'reject':  _showRejectDialog(id); break;
          case 'suspend': _suspend(id); break;
          case 'delete':
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Delete Vendor', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () { Navigator.pop(context); _delete(id); },
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
        }
      },
      itemBuilder: (_) => [
        if (status != 'approved') const PopupMenuItem(value: 'approve', child: Text('✅ Approve')),
        if (status != 'rejected') const PopupMenuItem(value: 'reject',  child: Text('❌ Reject')),
        if (status == 'approved') const PopupMenuItem(value: 'suspend', child: Text('⏸ Suspend')),
        const PopupMenuItem(value: 'delete', child: Text('🗑 Delete')),
      ],
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'approved':  color = Colors.green;  break;
      case 'pending':   color = Colors.orange; break;
      case 'rejected':  color = Colors.red;    break;
      case 'suspended': color = Colors.grey;   break;
      default:          color = Colors.blueGrey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
