import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/network/api_client.dart';
import '../../dashboard/views/dashboard_screen.dart';
import '../../orders/views/orders_screen.dart';
import '../../products/views/products_screen.dart';
import '../../pincode/views/pincode_screen.dart';
import '../../subscription/views/subscription_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../delivery/views/delivery_boys_screen.dart';
import '../../payouts/views/payout_history_screen.dart';

class _MenuItem {
  final IconData? icon;
  final String label;
  final bool isGroupHeader;
  final int? screenIndex;

  const _MenuItem({
    this.icon,
    required this.label,
    this.isGroupHeader = false,
    this.screenIndex,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ProductsScreen(),
    OrdersScreen(),
    PincodeScreen(),
    SubscriptionScreen(),
    ProfileScreen(),
    DeliveryBoysScreen(),    // index 6 — appended so the mobile bottom-nav stays intact
    PayoutHistoryScreen(),   // index 7
  ];

  static const List<_MenuItem> _menuItems = [
    _MenuItem(label: 'OVERVIEW', isGroupHeader: true),
    _MenuItem(icon: Icons.dashboard_outlined,              label: 'Dashboard',      screenIndex: 0),
    _MenuItem(label: 'CATALOG', isGroupHeader: true),
    _MenuItem(icon: Icons.inventory_2_outlined,            label: 'Products',       screenIndex: 1),
    _MenuItem(label: 'OPERATIONS', isGroupHeader: true),
    _MenuItem(icon: Icons.receipt_long_outlined,           label: 'Orders',         screenIndex: 2),
    _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Payouts',        screenIndex: 7),
    _MenuItem(label: 'DELIVERY', isGroupHeader: true),
    _MenuItem(icon: Icons.location_on_outlined,            label: 'Pincodes',       screenIndex: 3),
    _MenuItem(icon: Icons.delivery_dining_rounded,         label: 'Delivery Boys',  screenIndex: 6),
    _MenuItem(icon: Icons.card_membership_rounded,         label: 'Subscription',   screenIndex: 4),
    _MenuItem(label: 'ACCOUNT', isGroupHeader: true),
    _MenuItem(icon: Icons.person_outline_rounded,          label: 'Profile',        screenIndex: 5),
  ];

  void _select(int index) => setState(() => _selectedIndex = index);

  void _logout() async {
    try {
      if (await VendorApiHelper.isLoggedIn()) {
        await VendorApiHelper.post(ApiConstants.VENDOR_LOGOUT);
      }
    } catch (_) {}
    await VendorApiHelper.clearSession();
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.login);
  }

  Widget _mobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.sidebarColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.store_rounded, color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(width: 10.w),
                  Text('ShopQ Vendor',
                      style: GoogleFonts.jost(
                          color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Divider(color: AppColors.sidebarBorder, height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                children: [
                  for (final item in _menuItems)
                    if (item.isGroupHeader)
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                        child: Text(item.label,
                            style: GoogleFonts.jost(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: AppColors.sidebarTextColor.withValues(alpha: 0.5))),
                      )
                    else
                      _drawerTile(item),
                ],
              ),
            ),
            Divider(color: AppColors.sidebarBorder, height: 1),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(children: [
                  Icon(Icons.logout_rounded, size: 20.sp, color: AppColors.error),
                  SizedBox(width: 12.w),
                  Text('Logout',
                      style: GoogleFonts.jost(
                          fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.error)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(_MenuItem item) {
    final selected = _selectedIndex == item.screenIndex;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: () {
          _select(item.screenIndex!);
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.sidebarSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(children: [
            Icon(item.icon, size: 20.sp, color: selected ? Colors.white : AppColors.sidebarTextColor),
            SizedBox(width: 12.w),
            Text(item.label,
                style: GoogleFonts.jost(
                    fontSize: 14.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppColors.sidebarTextColor)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _VendorSidebar(
              selectedIndex: _selectedIndex,
              isExpanded: _sidebarExpanded,
              menuItems: _menuItems,
              onSelect: _select,
              onToggle: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
              onLogout: _logout,
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout — drawer gives access to every screen (incl. Delivery Boys,
    // Subscription) that don't fit in the 5-slot bottom bar.
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _mobileDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex == 5 ? 4 : (_selectedIndex > 4 ? 4 : _selectedIndex),
          onTap: (i) => _select(i == 4 ? 5 : i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.jost(fontSize: 10.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.jost(fontSize: 10.sp),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on_rounded),
              label: 'Pincodes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _VendorSidebar
// ─────────────────────────────────────────────

class _VendorSidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isExpanded;
  final List<_MenuItem> menuItems;
  final void Function(int) onSelect;
  final VoidCallback onToggle;
  final VoidCallback onLogout;

  const _VendorSidebar({
    required this.selectedIndex,
    required this.isExpanded,
    required this.menuItems,
    required this.onSelect,
    required this.onToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final double w = isExpanded ? 220.0 : 64.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: w,
      color: AppColors.sidebarColor,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.store_rounded, color: Colors.white, size: 20.sp),
                ),
                if (isExpanded) ...[
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'ShopQ\nVendor',
                      style: GoogleFonts.jost(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                    color: AppColors.sidebarTextColor,
                    size: 20.sp,
                  ),
                  onPressed: onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.sidebarBorder, height: 1, thickness: 1),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: menuItems.length,
              itemBuilder: (context, i) {
                final item = menuItems[i];
                if (item.isGroupHeader) {
                  if (!isExpanded) return SizedBox(height: 8.h);
                  return Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
                    child: Text(
                      item.label,
                      style: GoogleFonts.jost(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sidebarTextColor.withOpacity(0.5),
                        letterSpacing: 1.1,
                      ),
                    ),
                  );
                }
                final isSelected = selectedIndex == item.screenIndex;
                return Tooltip(
                  message: isExpanded ? '' : item.label,
                  preferBelow: false,
                  child: InkWell(
                    onTap: () => onSelect(item.screenIndex!),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: isExpanded ? 10.w : 0,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.sidebarSelected : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: isExpanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 18.sp,
                            color: isSelected ? Colors.white : AppColors.sidebarTextColor,
                          ),
                          if (isExpanded) ...[
                            SizedBox(width: 10.w),
                            Flexible(
                              child: Text(
                                item.label,
                                style: GoogleFonts.jost(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Colors.white : AppColors.sidebarTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(color: AppColors.sidebarBorder, height: 1, thickness: 1),
          InkWell(
            onTap: onLogout,
            child: Container(
              margin: EdgeInsets.all(8.w),
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 10.w : 0,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 18.sp, color: AppColors.error),
                  if (isExpanded) ...[
                    SizedBox(width: 10.w),
                    Text(
                      'Logout',
                      style: GoogleFonts.jost(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
