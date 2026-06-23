import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import 'dart:convert';
class AuthController extends GetxController {
  final isLoading = false.obs;
  bool get isLoggedIn => StorageService.isLoggedIn;
  String get userId => StorageService.userId;
  String get userName => StorageService.userName;
  String get userEmail => StorageService.userEmail;
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await ApiClient.post(ApiEndpoints.LOGIN, body: {'email': email, 'password': password});
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        StorageService.userEmail = email;
        if (data['token'] != null) StorageService.token = data['token'].toString();
        if (data['user'] != null) {
          StorageService.userId = data['user']['id']?.toString() ?? '';
          StorageService.userName = data['user']['name']?.toString() ?? '';
        }
        NotificationService.syncAfterLogin();
        final pincodeSet = StorageService.pincodeCode.isNotEmpty || StorageService.pincodeId > 0;
        Get.offAllNamed(pincodeSet ? AppRoutes.home : AppRoutes.location);
      } else {
        Get.snackbar('Login Failed', data['message']?.toString() ?? 'Please try again');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> logout() async {
    try {
      await ApiClient.post(ApiEndpoints.LOGOUT, auth: true);
    } catch (_) {}
    StorageService.clearAuth();
    Get.offAllNamed(AppRoutes.login);
  }
}
