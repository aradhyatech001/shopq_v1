class CartItemModel {
  final String id;
  final String productId;
  final String variantId;
  final int quantity;
  final String? imageUrl;
  final String? productName;
  final double? price;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.quantity,
    this.imageUrl,
    this.productName,
    this.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      variantId: json['variant_id']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString(),
      productName: json['product_name']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'variant_id': variantId,
        'quantity': quantity,
        'image_url': imageUrl,
        'product_name': productName,
        'price': price,
      };
}
