import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final _repo = AuthRepository();
  final isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> login(String loginId, String password) async {
    if (loginId.trim().isEmpty || password.isEmpty) {
      error.value = 'Enter your phone/email and password';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _repo.login(loginId, password);
      if (data['success'] == true) {
        _repo.saveSession(data['token'] ?? '', Map<String, dynamic>.from(data['rider'] ?? {}));
        Get.offAllNamed(AppRoutes.home);
      } else {
        error.value = data['message'] ?? 'Login failed';
      }
    } catch (_) {
      error.value = 'Connection failed. Check your network.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    StorageService.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
