import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/data/objects/cart_item.dart';

abstract class PosRepository {
  Future<List<Product>> getProducts();
  Future<List<Map<String, dynamic>>> getCategoriesByStoreId(String storeId);
  Future<List<CartItem>> getStoreCart(String storeId);
  Future<void> addToCart(String storeId, String productId, int quantity);
  Future<void> updateCartQuantity(
      String storeId, String productId, int quantity);
  Future<void> removeFromCart(String storeId, String productId);
  Future<void> clearCart(String storeId);

  // Payment
  Future<List<Map<String, dynamic>>> getStorePaymentMethods(String storeId);
  Future<String> processCheckout({
    required String storeId,
    required String cashierUserId,
    required List<CartItem> cartItems,
    required String paymentMethodId,
    required double taxRate,
    String? note,
  });
}
