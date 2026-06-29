import 'dart:convert';

import 'package:get/get.dart';

import 'package:shopq_delivery/core/network/api_client.dart';
import 'package:shopq_delivery/core/network/api_endpoints.dart';
import 'package:shopq_delivery/core/storage/storage_service.dart';
import '../models/app_notification.dart';

/// Drives the delivery Notification Center: list, unread badge, read/archive.
class NotificationController extends GetxController {
  final items = <AppNotification>[].obs;
  final unread = 0.obs;
  final loading = false.obs;

  bool get _loggedIn => (StorageService.getToken() ?? '').isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    if (_loggedIn) refreshUnread();
  }

  Future<void> fetch() async {
    if (!_loggedIn) return;
    loading.value = true;
    try {
      final res = await ApiClient.get(ApiEndpoints.NOTIFICATIONS);
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        items.assignAll((data['data'] as List)
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList());
        unread.value = items.where((n) => !n.isRead).length;
      }
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshUnread() async {
    if (!_loggedIn) return;
    try {
      final res = await ApiClient.get(ApiEndpoints.NOTIFICATIONS_UNREAD);
      final data = jsonDecode(res.body);
      if (data['success'] == true) unread.value = (data['unread'] ?? 0) as int;
    } catch (_) {}
  }

  Future<void> markRead(int id) async {
    final i = items.indexWhere((n) => n.id == id);
    if (i != -1 && !items[i].isRead) {
      items[i] = _copyRead(items[i]);
      items.refresh();
      if (unread.value > 0) unread.value--;
    }
    try {
      await ApiClient.post(ApiEndpoints.notificationRead(id));
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    items.assignAll(items.map((n) => n.isRead ? n : _copyRead(n)).toList());
    unread.value = 0;
    try {
      await ApiClient.post(ApiEndpoints.NOTIFICATIONS_READ_ALL);
    } catch (_) {}
  }

  Future<void> archive(int id) async {
    items.removeWhere((n) => n.id == id);
    refreshUnread();
    try {
      await ApiClient.post(ApiEndpoints.notificationArchive(id));
    } catch (_) {}
  }

  AppNotification _copyRead(AppNotification n) => AppNotification(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        image: n.image,
        data: n.data,
        readAt: DateTime.now(),
        createdAt: n.createdAt,
      );
}
