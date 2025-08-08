import 'package:equatable/equatable.dart';

abstract class CashierEvent extends Equatable {
  const CashierEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends CashierEvent {}

class LoadCategories extends CashierEvent {}

class LoadCart extends CashierEvent {}

class AddToCart extends CashierEvent {
  final String productId;
  final int quantity;

  const AddToCart({
    required this.productId,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class UpdateCartQuantity extends CashierEvent {
  final String productId;
  final int quantity;

  const UpdateCartQuantity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCart extends CashierEvent {}

class SearchProducts extends CashierEvent {
  final String searchTerm;

  const SearchProducts(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

class FilterByCategory extends CashierEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}
