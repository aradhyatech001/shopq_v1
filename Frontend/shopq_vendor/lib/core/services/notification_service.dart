import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../network/api_endpoints.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage _) async {}

class NotificationService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    final token = await messaging.getToken();
    if (token != null) await _sync(token);
    messaging.onTokenRefresh.listen(_sync);

    FirebaseMessaging.onMessage.listen(_showBanner);
    FirebaseMessaging.onMessageOpenedApp.listen(_onTap);

    final initial = await messaging.getInitialMessage();
    if (initial != null) _onTap(initial);
  }

  static Future<void> syncAfterLogin() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _sync(token);
  }

  static Future<void> _sync(String fcmToken) async {
    try {
      final authToken = StorageService.getToken();
      if (authToken == null || authToken.isEmpty) return;
      // Use the public static helper so we don't access the private _instance.
      await ApiClient.post(
        ApiEndpoints.VENDOR_FCM_TOKEN,
        body: {'fcm_token': fcmToken},
      );
    } catch (_) {}
  }

  static void _showBanner(RemoteMessage msg) {
    final title = msg.notification?.title ?? 'ShopQ Vendor';
    final body  = msg.notification?.body  ?? '';
    Get.snackbar(
      title,
      body,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  static void _onTap(RemoteMessage msg) {
    Get.toNamed('/home');
  }
}

// Backward-compat alias
typedef FcmHelper = NotificationService;
