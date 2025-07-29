import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String storeId;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.storeId,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      product: Product.fromJson(json['products'] ?? {}),
      quantity: json['quantity'] ?? 1,
      storeId: json['store_id'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'quantity': quantity,
      'store_id': storeId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get totalPrice => product.sellingPrice * quantity;
} 