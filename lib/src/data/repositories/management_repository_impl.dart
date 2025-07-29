import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'management_repository.dart';

class ManagementRepositoryImpl implements ManagementRepository {
  final SupabaseClient _supabaseClient;

  ManagementRepositoryImpl(this._supabaseClient);

  // Products
  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final storeId = await LocalStorageService.getStoreId();
      if (storeId == null) {
        throw Exception('Store ID not found');
      }

      final response = await _supabaseClient
          .from('products')
          .select('*, categories(name)')
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select('*, categories(name)')
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product');
    }
  }

  @override
  Future<void> createProduct(Map<String, dynamic> productData) async {
    try {
      final storeId = await LocalStorageService.getStoreId();
      if (storeId == null) {
        throw Exception('Store ID not found');
      }

      // Add store_id to product data
      final productDataWithStore = {
        ...productData,
        'store_id': storeId,
      };

      await _supabaseClient.from('products').insert(productDataWithStore);
    } catch (e) {
      throw Exception('Failed to create product');
    }
  }

  @override
  Future<void> updateProduct(
      String id, Map<String, dynamic> productData) async {
    try {
      await _supabaseClient.from('products').update(productData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _supabaseClient.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product');
    }
  }

  // Categories
  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final response = await _supabaseClient
          .from('categories')
          .select('*, products(count)')
          .eq('business_id', businessId)
          .order('name', ascending: true);

      return (response as List)
          .map((category) {
            final products = category['products'] as List?;
            final productCount = products?.length ?? 0;

            return {
              ...category,
              'product_count': productCount,
            };
          })
          .toList()
          .cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch categories');
    }
  }

  @override
  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      // Add business_id to category data
      final categoryDataWithBusiness = {
        ...categoryData,
        'business_id': businessId,
      };

      await _supabaseClient.from('categories').insert(categoryDataWithBusiness);
    } catch (e) {
      throw Exception('Failed to create category');
    }
  }

  @override
  Future<void> updateCategory(
      String id, Map<String, dynamic> categoryData) async {
    try {
      await _supabaseClient
          .from('categories')
          .update(categoryData)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update category');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _supabaseClient.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category');
    }
  }

  // Customers
  @override
  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final response = await _supabaseClient
          .from('customers')
          .select('*')
          .eq('business_id', businessId)
          .order('name', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch customers');
    }
  }

  @override
  Future<void> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final customerDataWithBusiness = {
        ...customerData,
        'business_id': businessId,
      };

      await _supabaseClient.from('customers').insert(customerDataWithBusiness);
    } catch (e) {
      throw Exception('Failed to create customer');
    }
  }

  @override
  Future<void> updateCustomer(
      String id, Map<String, dynamic> customerData) async {
    try {
      await _supabaseClient.from('customers').update(customerData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update customer');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabaseClient.from('customers').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete customer');
    }
  }

  // Suppliers
  @override
  Future<List<Map<String, dynamic>>> getSuppliers() async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final response = await _supabaseClient
          .from('suppliers')
          .select('*')
          .eq('business_id', businessId)
          .order('name', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch suppliers');
    }
  }

  @override
  Future<void> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final supplierDataWithBusiness = {
        ...supplierData,
        'business_id': businessId,
      };

      await _supabaseClient.from('suppliers').insert(supplierDataWithBusiness);
    } catch (e) {
      throw Exception('Failed to create supplier');
    }
  }

  @override
  Future<void> updateSupplier(
      String id, Map<String, dynamic> supplierData) async {
    try {
      await _supabaseClient.from('suppliers').update(supplierData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update supplier');
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await _supabaseClient.from('suppliers').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete supplier');
    }
  }

  // Inventory
  @override
  Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select('id, name, stock, min_stock, categories(name)')
          .order('name', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch inventory');
    }
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _supabaseClient
          .from('products')
          .update({'stock': newStock}).eq('id', productId);
    } catch (e) {
      throw Exception('Failed to update stock');
    }
  }

  @override
  Future<void> addStock(String productId, int quantity) async {
    try {
      // Get current stock
      final response = await _supabaseClient
          .from('products')
          .select('stock')
          .eq('id', productId)
          .single();

      final currentStock = response['stock'] ?? 0;
      final newStock = currentStock + quantity;

      await _supabaseClient
          .from('products')
          .update({'stock': newStock}).eq('id', productId);
    } catch (e) {
      throw Exception('Failed to add stock');
    }
  }

  // Discounts
  @override
  Future<List<Map<String, dynamic>>> getDiscounts() async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final response = await _supabaseClient
          .from('discounts')
          .select('*')
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch discounts');
    }
  }

  @override
  Future<void> createDiscount(Map<String, dynamic> discountData) async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final discountDataWithBusiness = {
        ...discountData,
        'business_id': businessId,
      };

      await _supabaseClient.from('discounts').insert(discountDataWithBusiness);
    } catch (e) {
      throw Exception('Failed to create discount');
    }
  }

  @override
  Future<void> updateDiscount(
      String id, Map<String, dynamic> discountData) async {
    try {
      await _supabaseClient.from('discounts').update(discountData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update discount');
    }
  }

  @override
  Future<void> deleteDiscount(String id) async {
    try {
      await _supabaseClient.from('discounts').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete discount');
    }
  }

  @override
  Future<void> toggleDiscountStatus(String id, bool isActive) async {
    try {
      await _supabaseClient
          .from('discounts')
          .update({'is_active': isActive}).eq('id', id);
    } catch (e) {
      throw Exception('Failed to toggle discount status');
    }
  }

  // Expenses
  @override
  Future<List<Map<String, dynamic>>> getExpenses() async {
    try {
      final storeId = await LocalStorageService.getStoreId();
      if (storeId == null) {
        throw Exception('Store ID not found');
      }

      final response = await _supabaseClient
          .from('expenses')
          .select('*')
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch expenses');
    }
  }

  @override
  Future<void> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final storeId = await LocalStorageService.getStoreId();
      if (storeId == null) {
        throw Exception('Store ID not found');
      }

      final expenseDataWithStore = {
        ...expenseData,
        'store_id': storeId,
      };

      await _supabaseClient.from('expenses').insert(expenseDataWithStore);
    } catch (e) {
      throw Exception('Failed to create expense');
    }
  }

  @override
  Future<void> updateExpense(
      String id, Map<String, dynamic> expenseData) async {
    try {
      await _supabaseClient.from('expenses').update(expenseData).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update expense');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _supabaseClient.from('expenses').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete expense');
    }
  }

  @override
  Future<void> markExpenseAsPaid(String id) async {
    try {
      await _supabaseClient.from('expenses').update({
        'is_paid': true,
        'paid_at': DateTime.now().toIso8601String()
      }).eq('id', id);
    } catch (e) {
      throw Exception('Failed to mark expense as paid');
    }
  }

  // Loyalty Programs
  @override
  Future<List<Map<String, dynamic>>> getLoyaltyPrograms() async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final response = await _supabaseClient
          .from('loyalty_programs')
          .select('*, customer_loyalty_memberships(count)')
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((program) {
            final memberships =
                program['customer_loyalty_memberships'] as List?;
            final memberCount = memberships?.length ?? 0;

            return {
              ...program,
              'members': memberCount,
            };
          })
          .toList()
          .cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch loyalty programs');
    }
  }

  @override
  Future<void> createLoyaltyProgram(Map<String, dynamic> programData) async {
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final businessId = businessData?['id'];
      if (businessId == null) {
        throw Exception('Business ID not found');
      }

      final programDataWithBusiness = {
        ...programData,
        'business_id': businessId,
      };

      await _supabaseClient
          .from('loyalty_programs')
          .insert(programDataWithBusiness);
    } catch (e) {
      throw Exception('Failed to create loyalty program');
    }
  }

  @override
  Future<void> updateLoyaltyProgram(
      String id, Map<String, dynamic> programData) async {
    try {
      await _supabaseClient
          .from('loyalty_programs')
          .update(programData)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update loyalty program');
    }
  }

  @override
  Future<void> deleteLoyaltyProgram(String id) async {
    try {
      await _supabaseClient.from('loyalty_programs').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete loyalty program');
    }
  }

  @override
  Future<void> toggleLoyaltyProgramStatus(String id, bool isActive) async {
    try {
      await _supabaseClient
          .from('loyalty_programs')
          .update({'is_active': isActive}).eq('id', id);
    } catch (e) {
      throw Exception('Failed to toggle loyalty program status');
    }
  }
}
