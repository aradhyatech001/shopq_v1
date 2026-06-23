class ProductModel {
  final int? id;
  final String name;
  final String? description;
  final int? mainCategoryId;
  final String? categoryName;
  final int? subcategoryId;
  final String? types;
  final List<dynamic> variants;
  final List<dynamic> images;
  final List<dynamic> highlights;
  final List<dynamic> info;
  final bool isActive;

  const ProductModel({
    this.id,
    required this.name,
    this.description,
    this.mainCategoryId,
    this.categoryName,
    this.subcategoryId,
    this.types,
    required this.variants,
    required this.images,
    required this.highlights,
    required this.info,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description']?.toString(),
        mainCategoryId: json['main_category_id'],
        categoryName: json['category_name']?.toString(),
        subcategoryId: json['subcategory_id'],
        types: json['types']?.toString(),
        variants: (json['variants'] as List?) ?? [],
        images: (json['images'] as List?) ?? [],
        highlights: (json['highlights'] as List?) ?? [],
        info: (json['info'] as List?) ?? [],
        isActive: json['is_active'] == 1 || json['is_active'] == true,
      );
}
