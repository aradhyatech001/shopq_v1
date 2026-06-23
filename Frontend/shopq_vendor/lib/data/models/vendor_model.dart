class VendorModel {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? shopName;
  final String? shopDescription;
  final String? logo;
  final String? status;
  final Map<String, dynamic>? activeSubscription;

  const VendorModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.shopName,
    this.shopDescription,
    this.logo,
    this.status,
    this.activeSubscription,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone']?.toString(),
        shopName: json['shop_name']?.toString(),
        shopDescription: json['shop_description']?.toString(),
        logo: json['logo']?.toString(),
        status: json['status']?.toString(),
        activeSubscription: json['active_subscription'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'shop_name': shopName,
        'shop_description': shopDescription,
        'logo': logo,
        'status': status,
        'active_subscription': activeSubscription,
      };
}
