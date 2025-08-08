import 'package:equatable/equatable.dart';
import 'package:ourbit_pos/src/data/objects/cart_item.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';

abstract class CashierState extends Equatable {
  const CashierState();

  @override
  List<Object?> get props => [];
}

class CashierInitial extends CashierState {}

class CashierLoading extends CashierState {}

class CashierLoaded extends CashierState {
  final List<Product> products;
  final List<CartItem> cartItems;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> productTypes;
  final String searchTerm;
  final String selectedCategory;
  final String selectedType;
  final double total;
  final double tax;
  final double discount;
  final double finalTotal;

  const CashierLoaded({
    required this.products,
    required this.cartItems,
    this.categories = const [],
    this.productTypes = const [],
    this.searchTerm = '',
    this.selectedCategory = 'all',
    this.selectedType = 'all',
    required this.total,
    required this.tax,
    required this.discount,
    required this.finalTotal,
  });

  CashierLoaded copyWith({
    List<Product>? products,
    List<CartItem>? cartItems,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? productTypes,
    String? searchTerm,
    String? selectedCategory,
    String? selectedType,
    double? total,
    double? tax,
    double? discount,
    double? finalTotal,
  }) {
    return CashierLoaded(
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
      categories: categories ?? this.categories,
      productTypes: productTypes ?? this.productTypes,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedType: selectedType ?? this.selectedType,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      finalTotal: finalTotal ?? this.finalTotal,
    );
  }

  @override
  List<Object?> get props => [
        products,
        cartItems,
        categories,
        productTypes,
        searchTerm,
        selectedCategory,
        selectedType,
        total,
        tax,
        discount,
        finalTotal,
      ];
}

class CashierError extends CashierState {
  final String message;

  const CashierError(this.message);

  @override
  List<Object?> get props => [message];
}
