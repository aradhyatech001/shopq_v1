import 'package:get/get.dart';

import 'app_routes.dart';

// Bindings
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/cart/bindings/cart_binding.dart';
import '../../modules/category/bindings/category_binding.dart';
import '../../modules/product/bindings/product_binding.dart';
import '../../modules/checkout/bindings/checkout_binding.dart';
import '../../modules/orders/bindings/order_binding.dart';
import '../../modules/wishlist/bindings/wishlist_binding.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/address/bindings/address_binding.dart';
import '../../modules/settings/bindings/settings_binding.dart';

// Views — Splash
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/splash/views/location_screen.dart';

// Views — Auth
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/signup_screen.dart';
import '../../modules/auth/views/forgot_password_screen.dart';
import '../../modules/auth/views/edit_profile_screen.dart';

// Views — Home
import '../../modules/home/views/bottom_nav_screen.dart';

// Views — Cart
import '../../modules/cart/views/cart_screen.dart';

// Views — Category
import '../../modules/category/views/category_screen.dart';
import '../../modules/category/views/category_view_screen.dart';
import '../../modules/category/views/brand_category_screen.dart';
import '../../modules/category/views/brand_view_screen.dart';
import '../../modules/category/views/shop_detail_screen.dart';

// Views — Product
import '../../modules/product/views/product_detail_screen.dart';
import '../../modules/product/views/search_screen.dart';
import '../../modules/product/views/similar_products_screen.dart';

// Views — Checkout
import '../../modules/checkout/views/checkout_screen.dart';

// Views — Orders
import '../../modules/orders/views/orders_screen.dart';
import '../../modules/orders/views/order_detail_screen.dart';
import '../../modules/orders/views/track_order_screen.dart';

// Views — Wishlist
import '../../modules/wishlist/views/wishlist_screen.dart';

// Views — Profile
import '../../modules/profile/views/profile_screen.dart';
import '../../modules/profile/views/about_screen.dart';
import '../../modules/profile/views/privacy_policy_screen.dart';
import '../../modules/profile/views/return_policy_screen.dart';
import '../../modules/profile/views/terms_screen.dart';

// Views — Address
import '../../modules/address/views/address_screen.dart';

// Views — Settings
import '../../modules/settings/views/coupon_screen.dart';
import '../../modules/settings/views/help_screen.dart';
import '../../modules/settings/views/refunds_screen.dart';

abstract class AppPages {
  static const initial = AppRoutes.splash;

  static final pages = [
    // ── Splash ─────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.location,
      page: () => const LocationScreen(),
    ),

    // ── Auth ───────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgetPassword(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfile(
        email:    Get.arguments?['email']    ?? '',
        fullName: Get.arguments?['fullName'] ?? '',
      ),
      binding: AuthBinding(),
    ),

    // ── Home ───────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => const BottomNavScreen(),
      binding: HomeBinding(),
    ),

    // ── Cart ───────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(),
      binding: CartBinding(),
    ),

    // ── Category ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.category,
      page: () => const CategoryScreen(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.categoryView,
      page: () => const CategoryViewScreen(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.brandCategory,
      page: () => const BrandCategory(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.brandView,
      page: () => BrandViewScreen(
        brandName: Get.arguments?['brandName'] ?? '',
      ),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.shopDetail,
      page: () => ShopDetailScreen(
        shopId:   Get.arguments?['shopId']   ?? 0,
        shopName: Get.arguments?['shopName'],
        logo:     Get.arguments?['logo'],
      ),
      binding: CategoryBinding(),
    ),

    // ── Product ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.product,
      page: () => ProductDetailsScreen(product: Get.arguments ?? {}),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => SearchProduct(
        category_name: Get.arguments?['category_name'],
      ),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.similarProducts,
      page: () => SimilarProduct(
        category_id:   Get.arguments?['category_id']   ?? '',
        category_name: Get.arguments?['category_name'] ?? '',
      ),
      binding: ProductBinding(),
    ),

    // ── Checkout ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.checkout,
      page: () => CheckoutScreen(
        saveAmount:       Get.arguments?['saveAmount']       ?? 0.0,
        finalWithCharge:  Get.arguments?['finalWithCharge']  ?? 0.0,
        userId:           Get.arguments?['userId']           ?? '',
        userEmail:        Get.arguments?['userEmail']        ?? '',
        userName:         Get.arguments?['userName']         ?? '',
        giftName:         Get.arguments?['giftName']         ?? '',
        deliveyCharge:    Get.arguments?['deliveyCharge']    ?? 0.0,
        handlingCharge:   Get.arguments?['handlingCharge']   ?? 0.0,
        coupon_code_name: Get.arguments?['coupon_code_name'] ?? '',
      ),
      binding: CheckoutBinding(),
    ),

    // ── Orders ─────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderScreen(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => OrderSummary(orderMap: Get.arguments ?? {}),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.trackOrder,
      page: () => TrackOrder(
        status:  Get.arguments?['status']  ?? '',
        orderId: Get.arguments?['orderId'] ?? '',
      ),
      binding: OrderBinding(),
    ),

    // ── Wishlist ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistScreen(),
      binding: WishlistBinding(),
    ),

    // ── Profile ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutScreen(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicy(),
    ),
    GetPage(
      name: AppRoutes.returnPolicy,
      page: () => const ReturnPolicy(),
    ),
    GetPage(
      name: AppRoutes.terms,
      page: () => const TermsCondition(),
    ),

    // ── Address ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.address,
      page: () => const DeliveryAddressScreen(),
      binding: AddressBinding(),
    ),

    // ── Settings ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.coupon,
      page: () => const CouponScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.help,
      page: () => const HelpScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.refunds,
      page: () => const MyRefundsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}
