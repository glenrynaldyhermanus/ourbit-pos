import 'package:equatable/equatable.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';

abstract class ManagementState extends Equatable {
  const ManagementState();

  @override
  List<Object?> get props => [];
}

class ManagementInitial extends ManagementState {}

class ManagementLoading extends ManagementState {}

class ManagementError extends ManagementState {
  final String message;

  const ManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductsLoaded extends ManagementState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class CategoriesLoaded extends ManagementState {
  final List<Map<String, dynamic>> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CustomersLoaded extends ManagementState {
  final List<Map<String, dynamic>> customers;

  const CustomersLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class SuppliersLoaded extends ManagementState {
  final List<Map<String, dynamic>> suppliers;

  const SuppliersLoaded(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

class InventoryLoaded extends ManagementState {
  final List<Product> inventory;

  const InventoryLoaded(this.inventory);

  @override
  List<Object?> get props => [inventory];
}

class DiscountsLoaded extends ManagementState {
  final List<Map<String, dynamic>> discounts;

  const DiscountsLoaded(this.discounts);

  @override
  List<Object?> get props => [discounts];
}

class ExpensesLoaded extends ManagementState {
  final List<Map<String, dynamic>> expenses;

  const ExpensesLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class LoyaltyProgramsLoaded extends ManagementState {
  final List<Map<String, dynamic>> programs;

  const LoyaltyProgramsLoaded(this.programs);

  @override
  List<Object?> get props => [programs];
}

class ManagementMenuSelected extends ManagementState {
  final String selectedMenu;

  const ManagementMenuSelected(this.selectedMenu);

  @override
  List<Object?> get props => [selectedMenu];
}
