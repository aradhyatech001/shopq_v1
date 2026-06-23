import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // ── State ─────────────────────────────────────────────────
  List _users = [];
  int _total = 0;
  int _limit = 10;
  int _offset = 0;
  bool _loading = false;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(
        '${ApiConstants.GET_ALL_USER}?limit=$_limit&offset=$_offset'
        '&search=${Uri.encodeComponent(_search)}',
      );
      final res = await AdminApi.get(uri);
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _users = data['users'];
          _total = data['total'];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(int id, String current) async {
    final newStatus = current == 'active' ? 'blocked' : 'active';
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.USER_STATUS_UPDATE),
        body: {'user_id': id.toString(), 'new_status': newStatus},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _fetchUsers();
      }
    } catch (_) {}
  }

  void _doSearch(String v) {
    setState(() {
      _search = v;
      _offset = 0;
    });
    _fetchUsers();
  }

  // Pagination helpers
  int get _totalPages => (_total / _limit).ceil();
  bool get _hasPrev => _offset > 0;
  bool get _hasNext => _offset + _limit < _total;

  void _prev() {
    setState(() => _offset -= _limit);
    _fetchUsers();
  }

  void _next() {
    setState(() => _offset += _limit);
    _fetchUsers();
  }

  void _first() {
    setState(() => _offset = 0);
    _fetchUsers();
  }

  void _last() {
    setState(() => _offset = (_totalPages - 1) * _limit);
    _fetchUsers();
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Users',
      subtitle: '$_total registered users',
      actions: [
        IconButton(
          onPressed: _fetchUsers,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Search bar
            AdminSearchBar(
              controller: _searchCtrl,
              hint: 'Search by name or email...',
              onClear: () => _doSearch(''),
            ),
            SizedBox(height: 16.h),
            // Submit search on enter
            // (AdminSearchBar triggers onClear, user can press enter in field)

            // List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      message: 'No users found',
                    )
                  : ListView.separated(
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (_, i) => _UserTile(
                        user: _users[i],
                        onToggle: () {
                          final u = _users[i];
                          final id = int.tryParse(u['id'].toString()) ?? 0;
                          final status = u['status'].toString();
                          _showConfirmDialog(id, u['name'], status);
                        },
                      ),
                    ),
            ),

            // Pagination
            if (_total > _limit) ...[
              SizedBox(height: 12.h),
              _buildPagination(),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(int id, String name, String status) {
    final isActive = status == 'active';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(
          '${isActive ? 'Block' : 'Unblock'} User',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${isActive ? 'Block' : 'Unblock'} $name?',
          style: GoogleFonts.jost(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.jost()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleStatus(id, status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive
                  ? AppColors.errorColor
                  : AppColors.successColor,
            ),
            child: Text(
              isActive ? 'Block' : 'Unblock',
              style: GoogleFonts.jost(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Rows per page
        Row(
          children: [
            Text(
              'Rows:',
              style: GoogleFonts.jost(
                fontSize: 13.sp,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(width: 8.w),
            DropdownButton<int>(
              value: _limit,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.jost(
                fontSize: 13.sp,
                color: AppColors.primaryTextColor,
              ),
              items: [5, 10, 20, 50]
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        '$v',
                        style: GoogleFonts.jost(fontSize: 13.sp),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _limit = v;
                  _offset = 0;
                });
                _fetchUsers();
              },
            ),
          ],
        ),

        // Page controls
        Row(
          children: [
            Text(
              '${_offset + 1}–${(_offset + _users.length)} of $_total',
              style: GoogleFonts.jost(
                fontSize: 12.sp,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(width: 8.w),
            _pageBtn(Icons.first_page, _hasPrev ? _first : null),
            _pageBtn(Icons.chevron_left, _hasPrev ? _prev : null),
            _pageBtn(Icons.chevron_right, _hasNext ? _next : null),
            _pageBtn(Icons.last_page, _hasNext ? _last : null),
          ],
        ),
      ],
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback? onTap) => IconButton(
    icon: Icon(
      icon,
      size: 20.sp,
      color: onTap != null ? AppColors.primaryColor : AppColors.hintTextColor,
    ),
    onPressed: onTap,
    padding: EdgeInsets.zero,
    constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
  );
}

// ── User tile ─────────────────────────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onToggle;

  const _UserTile({required this.user, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final status = (user['status'] ?? '').toString();
    final isActive = status == 'active';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22.r,
            backgroundColor: isActive
                ? AppColors.primaryLight
                : AppColors.errorLight,
            child: Text(
              (user['name']?.toString() ?? '?')[0].toUpperCase(),
              style: GoogleFonts.jost(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.primaryColor : AppColors.errorColor,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['name'] ?? '—',
                      style: GoogleFonts.jost(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '#${user['id']}',
                      style: GoogleFonts.jost(
                        fontSize: 11.sp,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  user['email'] ?? '—',
                  style: GoogleFonts.jost(
                    fontSize: 12.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    StatusBadge(
                      label: isActive ? 'Active' : 'Blocked',
                      color: isActive
                          ? AppColors.successColor
                          : AppColors.errorColor,
                    ),
                    SizedBox(width: 10.w),
                    if (user['date_time'] != null)
                      Text(
                        'Joined: ${user['date_time']}',
                        style: GoogleFonts.jost(
                          fontSize: 11.sp,
                          color: AppColors.hintTextColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Toggle button
          ElevatedButton.icon(
            onPressed: onToggle,
            icon: Icon(
              isActive ? Icons.block_rounded : Icons.check_circle_rounded,
              size: 16.sp,
            ),
            label: Text(
              isActive ? 'Block' : 'Unblock',
              style: GoogleFonts.jost(fontSize: 12.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive
                  ? AppColors.errorColor
                  : AppColors.successColor,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}
