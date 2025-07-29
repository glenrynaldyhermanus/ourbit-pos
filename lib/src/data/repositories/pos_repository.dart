import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/data/objects/cart_item.dart';

abstract class PosRepository {
  Future<List<Product>> getProducts();
  Future<List<CartItem>> getStoreCart(String storeId);
  Future<void> addToCart(String storeId, String productId, int quantity);
  Future<void> updateCartQuantity(
      String storeId, String productId, int quantity);
  Future<void> removeFromCart(String storeId, String productId);
  Future<void> clearCart(String storeId);
}
