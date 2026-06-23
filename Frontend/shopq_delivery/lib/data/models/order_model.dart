class OrderModel {
  final String id, status, customerName, address, total;
  final List<dynamic> items;
  const OrderModel({
    required this.id,
    required this.status,
    required this.customerName,
    required this.address,
    required this.total,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['id']?.toString() ?? '',
    status: j['status']?.toString() ?? '',
    customerName: j['customer_name']?.toString() ?? '',
    address: j['address']?.toString() ?? '',
    total: j['total']?.toString() ?? '0',
    items: (j['items'] as List?) ?? [],
  );
}
