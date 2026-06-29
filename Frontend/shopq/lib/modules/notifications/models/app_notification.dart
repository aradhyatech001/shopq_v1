/// A single in-app notification (Notification Center item).
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final String? image;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.image,
    this.data = const {},
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  /// Deep-link target carried in the data payload, e.g. `shopq://order/123`.
  String? get deeplink => data['deeplink']?.toString();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) =>
        (v == null) ? null : DateTime.tryParse(v.toString())?.toLocal();

    final rawData = json['data'];
    return AppNotification(
      id: int.tryParse('${json['id']}') ?? 0,
      type: json['type']?.toString() ?? 'custom',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      image: json['image']?.toString(),
      data: rawData is Map ? Map<String, dynamic>.from(rawData) : const {},
      readAt: parse(json['read_at']),
      createdAt: parse(json['created_at']),
    );
  }
}
