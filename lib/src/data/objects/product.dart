class Product {
  final String id;
  final String name;
  final String? code;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final int minStock;
  final String? unit;
  final int weightGrams;
  final int discountType;
  final double discountValue;
  final String? description;
  final String? rackLocation;
  final String? imageUrl;
  final bool isActive;
  final String? categoryId;
  final String storeId;
  final String type;
  final bool autoSku;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    this.code,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.minStock,
    this.unit,
    required this.weightGrams,
    required this.discountType,
    required this.discountValue,
    this.description,
    this.rackLocation,
    this.imageUrl,
    required this.isActive,
    this.categoryId,
    required this.storeId,
    required this.type,
    required this.autoSku,
    required this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    print('Parsing product: ${json['name']}');
    print('Categories data: ${json['categories']}');
    print('Category name: ${json['categories']?['name']}');

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      unit: json['unit'],
      weightGrams: json['weight_grams'] ?? 0,
      discountType: json['discount_type'] ?? 1,
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      description: json['description'],
      rackLocation: json['rack_location'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      categoryId: json['category_id'],
      storeId: json['store_id'] ?? '',
      type: json['type'] ?? '',
      autoSku: json['auto_sku'] ?? true,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      categoryName: json['categories']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock': stock,
      'min_stock': minStock,
      'unit': unit,
      'weight_grams': weightGrams,
      'discount_type': discountType,
      'discount_value': discountValue,
      'description': description,
      'rack_location': rackLocation,
      'image_url': imageUrl,
      'is_active': isActive,
      'category_id': categoryId,
      'store_id': storeId,
      'type': type,
      'auto_sku': autoSku,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category_name': categoryName,
    };
  }
}
