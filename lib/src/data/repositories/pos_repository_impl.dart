import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ourbit_pos/src/data/objects/cart_item.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'pos_repository.dart';

class PosRepositoryImpl implements PosRepository {
  final SupabaseClient _supabaseClient;

  PosRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final storeId = await LocalStorageService.getStoreId();
      if (storeId == null) {
        return [];
      }

      final response = await _supabaseClient
          .from('products')
          .select('*, categories(name)')
          .eq('store_id', storeId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final products =
          (response as List).map((json) => Product.fromJson(json)).toList();
      return products;
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoriesByStoreId(
      String storeId) async {
    try {
      // Get categories that have products in this store
      final response = await _supabaseClient
          .from('categories')
          .select('*, products!inner(*)')
          .eq('products.store_id', storeId)
          .eq('products.is_active', true)
          .order('name', ascending: true);

      return (response as List).map((category) {
        return {
          'id': category['id'],
          'name': category['name'],
          'business_id': category['business_id'],
          'created_at': category['created_at'],
          'updated_at': category['updated_at'],
        };
      }).toList();
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return [];
    }
  }

  @override
  Future<List<CartItem>> getStoreCart(String storeId) async {
    try {
      final response = await _supabaseClient
          .from('store_carts')
          .select('*, products(*)')
          .eq('store_id', storeId)
          .order('created_at', ascending: true);

      return (response as List).map((json) => CartItem.fromJson(json)).toList();
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return [];
    }
  }

  @override
  Future<void> addToCart(String storeId, String productId, int quantity) async {
    try {
      // Check if product already in cart
      final existingCart = await _supabaseClient
          .from('store_carts')
          .select()
          .eq('store_id', storeId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existingCart != null) {
        // Update quantity
        await _supabaseClient
            .from('store_carts')
            .update({'quantity': existingCart['quantity'] + quantity})
            .eq('store_id', storeId)
            .eq('product_id', productId);
      } else {
        // Insert new cart item
        await _supabaseClient.from('store_carts').insert({
          'store_id': storeId,
          'product_id': productId,
          'quantity': quantity,
        });
      }
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to add to cart');
    }
  }

  @override
  Future<void> updateCartQuantity(
      String storeId, String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(storeId, productId);
      } else {
        await _supabaseClient
            .from('store_carts')
            .update({'quantity': quantity})
            .eq('store_id', storeId)
            .eq('product_id', productId);
      }
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to update cart quantity');
    }
  }

  @override
  Future<void> removeFromCart(String storeId, String productId) async {
    try {
      await _supabaseClient
          .from('store_carts')
          .delete()
          .eq('store_id', storeId)
          .eq('product_id', productId);
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to remove from cart');
    }
  }

  @override
  Future<void> clearCart(String storeId) async {
    try {
      await _supabaseClient
          .from('store_carts')
          .delete()
          .eq('store_id', storeId);
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to clear cart');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStorePaymentMethods(
      String storeId) async {
    try {
      final response = await _supabaseClient
          .from('store_payment_methods')
          .select('id, payment_method_id, payment_methods(*, payment_types(*))')
          .eq('store_id', storeId)
          .eq('is_active', true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> processCheckout({
    required String storeId,
    required String cashierUserId,
    required List<CartItem> cartItems,
    required String paymentMethodId,
    required double taxRate,
    String? note,
  }) async {
    // Generate sale number
    final now = DateTime.now();
    final saleNumber =
        'POS-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    // Compute amounts
    final subtotal = cartItems.fold<double>(
        0, (sum, item) => sum + (item.product.sellingPrice * item.quantity));
    final taxAmount = subtotal * taxRate;
    final totalAmount = subtotal + taxAmount;

    // Insert sale
    final sale = await _supabaseClient
        .from('sales')
        .insert({
          'store_id': storeId,
          'sale_number': saleNumber,
          'sale_date': now.toIso8601String(),
          'subtotal': subtotal,
          'discount_amount': 0,
          'tax_amount': taxAmount,
          'total_amount': totalAmount,
          'payment_method_id': paymentMethodId,
          'status': 'completed',
          'cashier_id': cashierUserId,
          'notes': note,
        })
        .select()
        .single();

    final saleId = sale['id'] as String;

    // Insert sale items and update stock + inventory log
    for (final item in cartItems) {
      await _supabaseClient.from('sales_items').insert({
        'sale_id': saleId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price': item.product.sellingPrice,
        'discount_amount': 0,
        'tax_amount': 0,
        'total_amount': item.product.sellingPrice * item.quantity,
      });

      final productRow = await _supabaseClient
          .from('products')
          .select('stock')
          .eq('id', item.product.id)
          .single();
      final currentStock = (productRow['stock'] as num).toInt();
      final newStock = currentStock - item.quantity;

      await _supabaseClient
          .from('products')
          .update({'stock': newStock}).eq('id', item.product.id);

      await _supabaseClient.from('inventory_transactions').insert({
        'product_id': item.product.id,
        'store_id': storeId,
        'type': 2,
        'quantity': -item.quantity,
        'reference': 'POS-$saleNumber',
        'note': 'POS Sale',
        'previous_qty': currentStock,
        'new_qty': newStock,
        'unit_cost': item.product.sellingPrice,
        'total_cost': item.product.sellingPrice * item.quantity,
      });
    }

    // Finance transaction
    await _supabaseClient.from('financial_transactions').insert({
      'store_id': storeId,
      'transaction_date': now.toIso8601String(),
      'transaction_type': 'income',
      'category': 'sales',
      'description': 'POS Sale #$saleNumber',
      'amount': totalAmount,
      'payment_method_id': paymentMethodId,
      'status': 'completed',
    });

    // Clear cart
    await _supabaseClient.from('store_carts').delete().eq('store_id', storeId);

    return saleId;
  }
}
