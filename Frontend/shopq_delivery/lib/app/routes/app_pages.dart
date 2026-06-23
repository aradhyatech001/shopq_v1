import 'package:get/get.dart';

import 'app_routes.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/orders/bindings/order_binding.dart';
import '../../modules/orders/views/orders_screen.dart';

class AppPages {
  static const initial = AppRoutes.splash;
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), binding: SplashBinding()),
    GetPage(name: AppRoutes.login,  page: () => const LoginScreen(),  binding: AuthBinding()),
    GetPage(name: AppRoutes.home,   page: () => const OrdersScreen(), binding: OrderBinding()),
  ];
}
