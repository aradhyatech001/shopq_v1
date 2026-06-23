class RiderModel {
  final String id, name, email, phone;
  const RiderModel({required this.id, required this.name, required this.email, required this.phone});

  factory RiderModel.fromJson(Map<String, dynamic> j) => RiderModel(
    id: j['id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    phone: j['phone']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'phone': phone};
}
