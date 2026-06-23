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
    await Future.delayed(const Duration(seconds: 1));
    final pincodeSet = StorageService.pincodeCode.isNotEmpty || StorageService.pincodeId > 0;
    if (StorageService.isLoggedIn) {
      Get.offAllNamed(pincodeSet ? AppRoutes.home : AppRoutes.location);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
