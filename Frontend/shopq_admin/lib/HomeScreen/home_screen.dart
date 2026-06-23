import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Auth/login_screen.dart';
import '../BannerManagment/banner_management_screen.dart';
import '../Payouts/payout_management_screen.dart';
import '../Refunds/refund_management_screen.dart';
import '../CouponCodeManagment/coupanCodeScreen.dart';
import '../Dashboard/dashboard_screen.dart';
import '../DeliveryBoys/delivery_boys_screen.dart';
import '../HomeTabManagement/home_tab_screen.dart';
// import '../LocationScreen/locationManagementScreen.dart';
import '../MainCategory/main_category.dart';
import '../Order/order_management_screen.dart';
import '../Pincodes/pincode_screen.dart';
import '../Product/product_management_screen.dart';
import '../ProductType/product_type_screen.dart';
import '../Settings/setting_screen.dart';
import '../Appearance/appearance_screen.dart';
import '../StockManagement/stockManagementScreen.dart';
import '../SubCategory/sub_category_screen.dart';
import '../SubscriptionPlans/subscription_plans_screen.dart';
import '../User/user_management_screen.dart';
import '../VendorManagement/vendor_management_screen.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';
import '../utils/session_manager.dart';

// ── Menu item model ──────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final Widget screen;
  final String? groupHeader; // non-null → render a group divider above

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.screen,
    this.groupHeader,
  });
}

// ── All menu items ────────────────────────────────────────────────────────────
final List<_MenuItem> _menuItems = [
  _MenuItem(
    icon: Icons.dashboard_rounded,
    label: 'Dashboard',
    screen: const DashboardScreen(),
    groupHeader: 'OVERVIEW',
  ),
  _MenuItem(
    icon: Icons.category_rounded,
    label: 'Category',
    screen: const MainCategory(),
    groupHeader: 'CATALOG',
  ),
  _MenuItem(
    icon: Icons.account_tree_outlined,
    label: 'Sub Category',
    screen: const SubCategoryScreen(),
  ),
  _MenuItem(
    icon: Icons.shopping_bag_rounded,
    label: 'Products',
    screen: const ProductManagementScreen(),
  ),
  _MenuItem(
    icon: Icons.label_rounded,
    label: 'Product Types',
    screen: const ProductTypeScreen(),
  ),
  _MenuItem(
    icon: Icons.image_rounded,
    label: 'Banners',
    screen: const BannerManagementScreen(),
    groupHeader: 'STOREFRONT',
  ),
  _MenuItem(
    icon: Icons.tab_rounded,
    label: 'Home Tabs',
    screen: const HomeTabScreen(),
  ),
  _MenuItem(
    icon: Icons.local_offer_rounded,
    label: 'Coupons',
    screen: const CouponCodeScreen(),
  ),
  _MenuItem(
    icon: Icons.receipt_long_rounded,
    label: 'Orders',
    screen: const OrderManagementScreen(),
    groupHeader: 'OPERATIONS',
  ),
  _MenuItem(
    icon: Icons.inventory_2_rounded,
    label: 'Stock',
    screen: const StockManagementScreen(),
  ),
  _MenuItem(
    icon: Icons.assignment_return_rounded,
    label: 'Refunds',
    screen: const RefundManagementScreen(),
  ),
  _MenuItem(
    icon: Icons.account_balance_wallet_rounded,
    label: 'Payouts',
    screen: const PayoutManagementScreen(),
  ),
  _MenuItem(
    icon: Icons.people_rounded,
    label: 'Users',
    screen: const UserManagementScreen(),
  ),
  _MenuItem(
    icon: Icons.store_mall_directory_rounded,
    label: 'Vendors',
    screen: const VendorManagementScreen(),
    groupHeader: 'MULTIVENDOR',
  ),
  _MenuItem(
    icon: Icons.card_membership_rounded,
    label: 'Subscription Plans',
    screen: const SubscriptionPlansScreen(),
  ),
  _MenuItem(
    icon: Icons.delivery_dining_rounded,
    label: 'Delivery Boys',
    screen: const DeliveryBoysScreen(),
  ),
  /*_MenuItem(
    icon: Icons.location_on_rounded,
    label: 'Locations',
    screen: const LocationManagementScreen(),
    groupHeader: 'CONFIGURATION',
  ), */
  _MenuItem(
    icon: Icons.pin_drop_rounded,
    label: 'Pincodes',
    screen: const PincodeScreen(),
  ),
  _MenuItem(
    icon: Icons.settings_rounded,
    label: 'Settings',
    screen: const SettingScreen(),
  ),
  _MenuItem(
    icon: Icons.palette_rounded,
    label: 'Appearance',
    screen: const AppearanceScreen(),
  ),
];

// ── HomeScreen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  // Keep screens alive across tab switches
  late final List<Widget> _screens = _menuItems.map((m) => m.screen).toList();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.jost(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: Text('Logout', style: GoogleFonts.jost(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    // Revoke token on the server, then clear local session
    try {
      await AdminApi.post(Uri.parse(ApiConstants.LOGOUT));
    } catch (_) {}
    await SessionManager.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _AdminSidebar(
            items: _menuItems,
            selectedIndex: _selectedIndex,
            expanded: _sidebarExpanded,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
            onToggle: () =>
                setState(() => _sidebarExpanded = !_sidebarExpanded),
            onLogout: _logout,
          ),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),
        ],
      ),
    );
  }
}

// ── Sidebar widget ────────────────────────────────────────────────────────────
class _AdminSidebar extends StatelessWidget {
  final List<_MenuItem> items;
  final int selectedIndex;
  final bool expanded;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onToggle;
  final VoidCallback onLogout;

  const _AdminSidebar({
    required this.items,
    required this.selectedIndex,
    required this.expanded,
    required this.onItemSelected,
    required this.onToggle,
    required this.onLogout,
  });

  static const double _expandedW = 220;
  static const double _collapsedW = 64;

  @override
  Widget build(BuildContext context) {
    final w = expanded ? _expandedW.w : _collapsedW.w;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: w,
      color: AppColors.sidebarColor,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(color: Color(0xFF2D3E50), height: 1),
          Expanded(child: _buildMenu()),
          const Divider(color: Color(0xFF2D3E50), height: 1),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 64.h,
      child: expanded
          // ── Expanded: logo + name + toggle ──────────────────────
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'ShopQ',
                      style: GoogleFonts.jost(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.menu_open_rounded,
                      color: AppColors.sidebarTextColor,
                      size: 20.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onToggle,
                  ),
                ],
              ),
            )
          // ── Collapsed: only the toggle button, centred ──────────
          : Center(
              child: IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: AppColors.sidebarTextColor,
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onToggle,
              ),
            ),
    );
  }

  Widget _buildMenu() {
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      // Group header
      if (item.groupHeader != null && expanded) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              top: i == 0 ? 12.h : 20.h,
              bottom: 6.h,
            ),
            child: Text(
              item.groupHeader!,
              style: GoogleFonts.jost(
                color: const Color(0xFF4A5568),
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      } else if (item.groupHeader != null && !expanded) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 8.h : 16.h, bottom: 4.h),
            child: Divider(
              color: const Color(0xFF2D3E50),
              height: 1,
              indent: 10.w,
              endIndent: 10.w,
            ),
          ),
        );
      }

      widgets.add(
        _SidebarItem(
          item: item,
          index: i,
          isSelected: selectedIndex == i,
          expanded: expanded,
          onTap: () => onItemSelected(i),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(bottom: 12.h),
      children: widgets,
    );
  }

  Widget _buildFooter() {
    return InkWell(
      onTap: onLogout,
      child: SizedBox(
        height: 56.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: expanded ? 16.w : 0),
          child: Row(
            mainAxisAlignment: expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.errorColor,
                size: 20.sp,
              ),
              if (expanded) ...[
                SizedBox(width: 12.w),
                Text(
                  'Logout',
                  style: GoogleFonts.jost(
                    color: AppColors.errorColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single sidebar tile ───────────────────────────────────────────────────────
class _SidebarItem extends StatelessWidget {
  final _MenuItem item;
  final int index;
  final bool isSelected;
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.index,
    required this.isSelected,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? 8.w : 4.w,
        vertical: 2.h,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 10.w : 0,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.sidebarSelected
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  item.icon,
                  size: 20.sp,
                  color: isSelected ? Colors.white : AppColors.sidebarTextColor,
                ),
                if (expanded) ...[
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.jost(
                        fontSize: 13.5.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.sidebarTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
