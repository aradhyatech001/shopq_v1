import 'package:get/get.dart';

import 'app_routes.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/register_screen.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_screen.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_screen.dart';
import '../../modules/orders/bindings/order_binding.dart';
import '../../modules/orders/views/orders_screen.dart';
import '../../modules/products/bindings/product_binding.dart';
import '../../modules/products/views/products_screen.dart';
import '../../modules/delivery/bindings/delivery_binding.dart';
import '../../modules/delivery/views/delivery_boys_screen.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/profile_screen.dart';
import '../../modules/payouts/bindings/payout_binding.dart';
import '../../modules/payouts/views/payout_history_screen.dart';
import '../../modules/pincode/bindings/pincode_binding.dart';
import '../../modules/pincode/views/pincode_screen.dart';
import '../../modules/subscription/bindings/subscription_binding.dart';
import '../../modules/subscription/views/subscription_screen.dart';

/// Central route table for the vendor app.
///
/// The [home] shell already embeds all tab screens in an IndexedStack, so
/// the individual screen routes (dashboard, orders, …) are kept here for
/// possible direct deep-link navigation but are not required for normal use.
abstract class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      bindings: [
        HomeBinding(),
        DashboardBinding(),
        OrderBinding(),
        ProductBinding(),
        DeliveryBinding(),
        ProfileBinding(),
        PayoutBinding(),
        PincodeBinding(),
        SubscriptionBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersScreen(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductsScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.delivery,
      page: () => const DeliveryBoysScreen(),
      binding: DeliveryBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.payouts,
      page: () => const PayoutHistoryScreen(),
      binding: PayoutBinding(),
    ),
    GetPage(
      name: AppRoutes.pincode,
      page: () => const PincodeScreen(),
      binding: PincodeBinding(),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      binding: SubscriptionBinding(),
    ),
  ];
}
