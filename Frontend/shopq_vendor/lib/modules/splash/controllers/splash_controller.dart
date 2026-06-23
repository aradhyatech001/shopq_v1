import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 700));
    StorageService.isLoggedIn()
        ? Get.offAllNamed(AppRoutes.home)
        : Get.offAllNamed(AppRoutes.login);
  }
}
