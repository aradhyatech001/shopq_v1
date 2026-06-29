import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../network/api_endpoints.dart';
import '../storage/storage_service.dart';
import '../network/api_client.dart';
import '../../modules/notifications/controllers/notification_controller.dart';
import '../../modules/notifications/utils/deeplink_router.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage _) async {
  // Firebase shows the system notification automatically.
  // Do not touch UI here — this runs in a separate isolate.
}

/// High-importance channel (matches the manifest's default_notification_channel_id)
/// so Android shows heads-up notifications with sound.
const AndroidNotificationChannel _kChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notifications',
  description: 'Order updates, offers and alerts.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);
    // iOS: show alert/badge/sound while the app is in the foreground too.
    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    // Android: local-notifications plugin shows foreground heads-up alerts
    // (FCM does not auto-display notifications while the app is in foreground).
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

    await syncTopics();

    FirebaseMessaging.onMessage.listen(_showBanner);
    FirebaseMessaging.onMessageOpenedApp.listen(_onTap);

    final initial = await messaging.getInitialMessage();
    if (initial != null) _onTap(initial);
  }

  static Future<void> syncAfterLogin() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _sync(token);
    await syncTopics();
  }

  /// Subscribe to the broadcast topics this device should receive:
  /// `all_customers` + the user's current `pincode_<code>` (re-subscribing
  /// when the pincode changes). Call again after the pincode is updated.
  static Future<void> syncTopics() async {
    final messaging = FirebaseMessaging.instance;
    try {
      await messaging.subscribeToTopic('all_customers');

      final current = StorageService.pincodeCode;
      final last = StorageService.subscribedPincode;
      if (current != last) {
        if (last.isNotEmpty) {
          await messaging.unsubscribeFromTopic(_pincodeTopic(last));
        }
        if (current.isNotEmpty) {
          await messaging.subscribeToTopic(_pincodeTopic(current));
        }
        StorageService.subscribedPincode = current;
      }
    } catch (_) {}
  }

  static String _pincodeTopic(String code) =>
      'pincode_${code.replaceAll(RegExp(r'[^a-zA-Z0-9_.\-~%]'), '_')}';

  // ── Internal ────────────────────────────────────────────────

  static Future<void> _sync(String fcmToken) async {
    try {
      if (StorageService.token.isEmpty) return;
      await ApiClient.instance.post(
        ApiEndpoints.FCM_TOKEN,
        data: {
          'fcm_token': fcmToken,
          'platform': _platform(),
          'language': Get.deviceLocale?.languageCode ?? 'en',
        },
        options: Options(contentType: 'application/x-www-form-urlencoded'),
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
    // Keep the notification badge / list fresh while the app is open.
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().refreshUnread();
    }

    final n = msg.notification;

    // Android: show a native heads-up notification.
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

    // Web: lightweight in-app banner (iOS is shown by the system via the
    // foreground presentation options set above).
    if (kIsWeb) {
      Get.snackbar(
        n?.title ?? 'ShopQ',
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

// Backward-compatibility typedef
typedef FcmHelper = NotificationService;
