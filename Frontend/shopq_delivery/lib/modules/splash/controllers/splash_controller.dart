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
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = StorageService.isLoggedIn();

    print("Is Logged In: $isLoggedIn");

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}