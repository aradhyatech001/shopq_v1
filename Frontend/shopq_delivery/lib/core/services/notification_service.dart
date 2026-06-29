import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../network/api_endpoints.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../../modules/notifications/controllers/notification_controller.dart';
import '../../modules/notifications/utils/deeplink_router.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage _) async {}

const AndroidNotificationChannel _kChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notifications',
  description: 'Delivery tasks and reminders.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (resp) {
        final p = resp.payload;
        if (p != null && p.isNotEmpty) {
          try {
            DeepLinkRouter.open(Map<String, dynamic>.from(jsonDecode(p)));
          } catch (_) {}
        }
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_kChannel);

    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    final token = await messaging.getToken();
    if (token != null) await _sync(token);
    messaging.onTokenRefresh.listen(_sync);

    try {
      await messaging.subscribeToTopic('all_delivery');
    } catch (_) {}

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
      await ApiClient.post(
        ApiEndpoints.DELIVERY_FCM_TOKEN,
        body: {
          'fcm_token': fcmToken,
          'platform': _platform(),
          'language': Get.deviceLocale?.languageCode ?? 'en',
        },
      );
    } catch (_) {}
  }

  static String _platform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'other';
    }
  }

  static void _showBanner(RemoteMessage msg) {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().refreshUnread();
    }
    final n = msg.notification;

    if (!kIsWeb && n != null && n.android != null) {
      _localNotifications.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _kChannel.id,
            _kChannel.name,
            channelDescription: _kChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(msg.data),
      );
      return;
    }

    if (kIsWeb) {
      Get.snackbar(
        n?.title ?? 'ShopQ Delivery',
        n?.body ?? '',
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        onTap: (_) => DeepLinkRouter.open(Map<String, dynamic>.from(msg.data)),
      );
    }
  }

  static void _onTap(RemoteMessage msg) {
    DeepLinkRouter.open(Map<String, dynamic>.from(msg.data));
  }
}

typedef FcmHelper = NotificationService;
