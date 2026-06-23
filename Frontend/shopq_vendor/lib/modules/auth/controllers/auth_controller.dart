import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final Rx<Map<String, dynamic>?> vendor = Rx(null);

  @override
  void onInit() {
    super.onInit();
    vendor.value = StorageService.getVendor();
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      final data = await AuthRepository().login(email, password);
      if (data['success'] == true) {
        StorageService.saveSession(
          data['token'].toString(),
          Map<String, dynamic>.from(data['vendor'] as Map),
        );
        NotificationService.syncAfterLogin();
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        Get.snackbar(
          'Login Failed',
          data['message']?.toString() ?? 'Login failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Network Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await AuthRepository().logout();
    } catch (_) {}
    StorageService.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  Map<String, dynamic>? get currentVendor => StorageService.getVendor();
}
