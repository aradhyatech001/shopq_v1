import 'dart:convert';

import 'package:get/get.dart';

import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/storage/storage_service.dart';
import '../models/app_notification.dart';

/// Drives the Notification Center: list, unread badge, and read/archive/delete.
/// Registered as a permanent GetX service so the home bell badge can read the
/// unread count and the push handler can refresh the list on a new message.
class NotificationController extends GetxController {
  final items = <AppNotification>[].obs;
  final unread = 0.obs;
  final loading = false.obs;

  bool get _loggedIn => StorageService.token.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    if (_loggedIn) refreshUnread();
  }

  /// Full list (first page). Pull-to-refresh re-calls this.
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

  /// Cheap badge refresh (no list payload).
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

  /// Tile tap = read + click (drives campaign read/click analytics).
  Future<void> clicked(int id) async {
    final i = items.indexWhere((n) => n.id == id);
    if (i != -1 && !items[i].isRead) {
      items[i] = _copyRead(items[i]);
      items.refresh();
      if (unread.value > 0) unread.value--;
    }
    try {
      await ApiClient.post(ApiEndpoints.notificationClicked(id));
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

  Future<void> delete(int id) async {
    items.removeWhere((n) => n.id == id);
    refreshUnread();
    try {
      await ApiClient.instance.delete(ApiEndpoints.notificationDelete(id));
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
