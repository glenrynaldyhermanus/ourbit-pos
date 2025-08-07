import 'package:equatable/equatable.dart';

abstract class ManagementEvent extends Equatable {
  const ManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ManagementEvent {}

class LoadCategories extends ManagementEvent {}

class LoadCustomers extends ManagementEvent {}

class LoadSuppliers extends ManagementEvent {}

class LoadInventory extends ManagementEvent {}

class LoadDiscounts extends ManagementEvent {}

class LoadExpenses extends ManagementEvent {}

class LoadLoyaltyPrograms extends ManagementEvent {}

class CreateProduct extends ManagementEvent {
  final Map<String, dynamic> productData;

  const CreateProduct({
    required this.productData,
  });

  @override
  List<Object?> get props => [productData];
}

class UpdateProduct extends ManagementEvent {
  final String productId;
  final Map<String, dynamic> productData;

  const UpdateProduct({
    required this.productId,
    required this.productData,
  });

  @override
  List<Object?> get props => [productId, productData];
}

class DeleteProduct extends ManagementEvent {
  final String productId;

  const DeleteProduct({
    required this.productId,
  });

  @override
  List<Object?> get props => [productId];
}

class CreateCategory extends ManagementEvent {
  final Map<String, dynamic> categoryData;

  const CreateCategory({
    required this.categoryData,
  });

  @override
  List<Object?> get props => [categoryData];
}

class UpdateCategory extends ManagementEvent {
  final String categoryId;
  final Map<String, dynamic> categoryData;

  const UpdateCategory({
    required this.categoryId,
    required this.categoryData,
  });

  @override
  List<Object?> get props => [categoryId, categoryData];
}

class DeleteCategory extends ManagementEvent {
  final String categoryId;

  const DeleteCategory({
    required this.categoryId,
  });

  @override
  List<Object?> get props => [categoryId];
}

class CreateCustomer extends ManagementEvent {
  final Map<String, dynamic> customerData;

  const CreateCustomer({
    required this.customerData,
  });

  @override
  List<Object?> get props => [customerData];
}

class UpdateCustomer extends ManagementEvent {
  final String customerId;
  final Map<String, dynamic> customerData;

  const UpdateCustomer({
    required this.customerId,
    required this.customerData,
  });

  @override
  List<Object?> get props => [customerId, customerData];
}

class DeleteCustomer extends ManagementEvent {
  final String customerId;

  const DeleteCustomer({
    required this.customerId,
  });

  @override
  List<Object?> get props => [customerId];
}

class CreateSupplier extends ManagementEvent {
  final Map<String, dynamic> supplierData;

  const CreateSupplier({
    required this.supplierData,
  });

  @override
  List<Object?> get props => [supplierData];
}

class UpdateSupplier extends ManagementEvent {
  final String supplierId;
  final Map<String, dynamic> supplierData;

  const UpdateSupplier({
    required this.supplierId,
    required this.supplierData,
  });

  @override
  List<Object?> get props => [supplierId, supplierData];
}

class DeleteSupplier extends ManagementEvent {
  final String supplierId;

  const DeleteSupplier({
    required this.supplierId,
  });

  @override
  List<Object?> get props => [supplierId];
}

class CreateDiscount extends ManagementEvent {
  final Map<String, dynamic> discountData;

  const CreateDiscount({
    required this.discountData,
  });

  @override
  List<Object?> get props => [discountData];
}

class UpdateDiscount extends ManagementEvent {
  final String discountId;
  final Map<String, dynamic> discountData;

  const UpdateDiscount({
    required this.discountId,
    required this.discountData,
  });

  @override
  List<Object?> get props => [discountId, discountData];
}

class DeleteDiscount extends ManagementEvent {
  final String discountId;

  const DeleteDiscount({
    required this.discountId,
  });

  @override
  List<Object?> get props => [discountId];
}

class CreateExpense extends ManagementEvent {
  final Map<String, dynamic> expenseData;

  const CreateExpense({
    required this.expenseData,
  });

  @override
  List<Object?> get props => [expenseData];
}

class UpdateExpense extends ManagementEvent {
  final String expenseId;
  final Map<String, dynamic> expenseData;

  const UpdateExpense({
    required this.expenseId,
    required this.expenseData,
  });

  @override
  List<Object?> get props => [expenseId, expenseData];
}

class DeleteExpense extends ManagementEvent {
  final String expenseId;

  const DeleteExpense({
    required this.expenseId,
  });

  @override
  List<Object?> get props => [expenseId];
}

class CreateLoyaltyProgram extends ManagementEvent {
  final Map<String, dynamic> programData;

  const CreateLoyaltyProgram({
    required this.programData,
  });

  @override
  List<Object?> get props => [programData];
}

class UpdateLoyaltyProgram extends ManagementEvent {
  final String programId;
  final Map<String, dynamic> programData;

  const UpdateLoyaltyProgram({
    required this.programId,
    required this.programData,
  });

  @override
  List<Object?> get props => [programId, programData];
}

class DeleteLoyaltyProgram extends ManagementEvent {
  final String programId;

  const DeleteLoyaltyProgram({
    required this.programId,
  });

  @override
  List<Object?> get props => [programId];
}

class UpdateStock extends ManagementEvent {
  final String productId;
  final int newStock;

  const UpdateStock({
    required this.productId,
    required this.newStock,
  });

  @override
  List<Object?> get props => [productId, newStock];
}

class ToggleDiscountStatus extends ManagementEvent {
  final String discountId;
  final bool isActive;

  const ToggleDiscountStatus({
    required this.discountId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [discountId, isActive];
}

class MarkExpenseAsPaid extends ManagementEvent {
  final String expenseId;

  const MarkExpenseAsPaid({
    required this.expenseId,
  });

  @override
  List<Object?> get props => [expenseId];
}

class ToggleLoyaltyProgramStatus extends ManagementEvent {
  final String programId;
  final bool isActive;

  const ToggleLoyaltyProgramStatus({
    required this.programId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [programId, isActive];
}

class SelectManagementMenu extends ManagementEvent {
  final String menuId;

  const SelectManagementMenu({
    required this.menuId,
  });

  @override
  List<Object?> get props => [menuId];
}
