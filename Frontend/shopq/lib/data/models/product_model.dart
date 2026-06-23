class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? category;
  final String? subcategoryId;
  final String? subcategory;
  final List<String> images;
  final List<Map<String, dynamic>> variants;
  final List<Map<String, dynamic>> highlights;
  final List<Map<String, dynamic>> info;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.category,
    this.subcategoryId,
    this.subcategory,
    this.images = const [],
    this.variants = const [],
    this.highlights = const [],
    this.info = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['category_id']?.toString(),
      category: json['category']?.toString(),
      subcategoryId: json['subcategory_id']?.toString(),
      subcategory: json['subcategory']?.toString(),
      images: List<String>.from(json['images'] ?? []),
      variants: List<Map<String, dynamic>>.from(json['variants'] ?? []),
      highlights: List<Map<String, dynamic>>.from(json['highlights'] ?? []),
      info: List<Map<String, dynamic>>.from(json['info'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category_id': categoryId,
        'category': category,
        'subcategory_id': subcategoryId,
        'subcategory': subcategory,
        'images': images,
        'variants': variants,
        'highlights': highlights,
        'info': info,
      };
}
