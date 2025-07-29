import 'package:ourbit_pos/src/data/objects/product.dart';

abstract class ManagementRepository {
  // Products
  Future<List<Product>> getAllProducts();
  Future<Product> getProductById(String id);
  Future<void> createProduct(Map<String, dynamic> productData);
  Future<void> updateProduct(String id, Map<String, dynamic> productData);
  Future<void> deleteProduct(String id);

  // Categories
  Future<List<Map<String, dynamic>>> getCategories();
  Future<void> createCategory(Map<String, dynamic> categoryData);
  Future<void> updateCategory(String id, Map<String, dynamic> categoryData);
  Future<void> deleteCategory(String id);

  // Customers
  Future<List<Map<String, dynamic>>> getCustomers();
  Future<void> createCustomer(Map<String, dynamic> customerData);
  Future<void> updateCustomer(String id, Map<String, dynamic> customerData);
  Future<void> deleteCustomer(String id);

  // Suppliers
  Future<List<Map<String, dynamic>>> getSuppliers();
  Future<void> createSupplier(Map<String, dynamic> supplierData);
  Future<void> updateSupplier(String id, Map<String, dynamic> supplierData);
  Future<void> deleteSupplier(String id);

  // Inventory
  Future<List<Map<String, dynamic>>> getInventory();
  Future<void> updateStock(String productId, int newStock);
  Future<void> addStock(String productId, int quantity);

  // Discounts
  Future<List<Map<String, dynamic>>> getDiscounts();
  Future<void> createDiscount(Map<String, dynamic> discountData);
  Future<void> updateDiscount(String id, Map<String, dynamic> discountData);
  Future<void> deleteDiscount(String id);
  Future<void> toggleDiscountStatus(String id, bool isActive);

  // Expenses
  Future<List<Map<String, dynamic>>> getExpenses();
  Future<void> createExpense(Map<String, dynamic> expenseData);
  Future<void> updateExpense(String id, Map<String, dynamic> expenseData);
  Future<void> deleteExpense(String id);
  Future<void> markExpenseAsPaid(String id);

  // Loyalty Programs
  Future<List<Map<String, dynamic>>> getLoyaltyPrograms();
  Future<void> createLoyaltyProgram(Map<String, dynamic> programData);
  Future<void> updateLoyaltyProgram(
      String id, Map<String, dynamic> programData);
  Future<void> deleteLoyaltyProgram(String id);
  Future<void> toggleLoyaltyProgramStatus(String id, bool isActive);
}
