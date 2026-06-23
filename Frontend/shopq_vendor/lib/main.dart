import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'firebase/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await FirebaseService.initialize();
  await FcmHelper.init();
  runApp(const VendorApp());
}

class VendorApp extends StatelessWidget {
  const VendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final Size design = w >= 1100
            ? const Size(1366, 768)
            : w >= 600
                ? const Size(834, 1112)
                : const Size(390, 844);
        return ScreenUtilInit(
          designSize: design,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => GetMaterialApp(
            title: 'ShopQ Vendor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            initialBinding: InitialBinding(),
            initialRoute: AppRoutes.splash,
            getPages: AppPages.routes,
          ),
        );
      },
    );
  }
}
