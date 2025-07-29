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
}
