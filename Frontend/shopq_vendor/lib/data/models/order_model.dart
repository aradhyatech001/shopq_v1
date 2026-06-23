class OrderModel {
  final dynamic id;
  final dynamic parentOrderId;
  final String status;
  final String? paymentMethod;
  final String? paymentStatus;
  final List<dynamic> items;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? address;
  final dynamic total;
  final dynamic collectAmount;
  final String? createdAt;

  const OrderModel({
    this.id,
    this.parentOrderId,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    required this.items,
    this.user,
    this.address,
    this.total,
    this.collectAmount,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        parentOrderId: json['parent_order_id'],
        status: json['status']?.toString() ?? 'pending',
        paymentMethod: json['payment_method']?.toString(),
        paymentStatus: json['payment_status']?.toString(),
        items: (json['items'] as List?) ?? [],
        user: json['user'] as Map<String, dynamic>?,
        address: json['address'] as Map<String, dynamic>?,
        total: json['total'],
        collectAmount: json['collect_amount'],
        createdAt: json['created_at']?.toString(),
      );
}
