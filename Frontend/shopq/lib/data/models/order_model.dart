class OrderModel {
  final String id;
  final String status;
  final double total;
  final String? createdAt;
  final List<Map<String, dynamic>> items;

  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
    this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString(),
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'total': total,
        'created_at': createdAt,
        'items': items,
      };
}
