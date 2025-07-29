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
  final String searchTerm;
  final String selectedCategory;
  final double total;
  final double tax;
  final double discount;
  final double finalTotal;

  const CashierLoaded({
    required this.products,
    required this.cartItems,
    this.searchTerm = '',
    this.selectedCategory = 'all',
    required this.total,
    required this.tax,
    required this.discount,
    required this.finalTotal,
  });

  CashierLoaded copyWith({
    List<Product>? products,
    List<CartItem>? cartItems,
    String? searchTerm,
    String? selectedCategory,
    double? total,
    double? tax,
    double? discount,
    double? finalTotal,
  }) {
    return CashierLoaded(
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedCategory: selectedCategory ?? this.selectedCategory,
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
        searchTerm,
        selectedCategory,
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
