import 'package:ourbit_pos/src/core/services/supabase_service.dart';
import 'package:ourbit_pos/src/data/objects/cart_item.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';

class ProcessCheckoutUseCase {
  final PosRepository _posRepository;

  ProcessCheckoutUseCase(this._posRepository);

  Future<String?> call({
    required List<Map<String, dynamic>> cartItems,
    required double subtotal,
    required double tax,
    required double total,
    required String paymentMethodId,
    String? salesNotes,
  }) async {
    final storeId = await SupabaseService.getStoreId();
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (storeId == null || userId == null) return null;

    // Convert Map<String, dynamic> to CartItem objects
    final cartItemObjects = cartItems
        .map((item) => CartItem(
              id: item['id'],
              storeId: storeId,
              createdAt: DateTime.now(),
              product: Product(
                id: item['product_id'],
                name: item['product']['name'],
                purchasePrice: 0.0,
                sellingPrice: item['price'].toDouble(),
                stock: 0,
                minStock: 0,
                weightGrams: 0,
                discountType: 1,
                discountValue: 0.0,
                isActive: true,
                categoryId: '',
                storeId: storeId,
                type: 'product',
                autoSku: true,
                createdAt: DateTime.now(),
                imageUrl: item['product']['image_url'],
                description: '',
              ),
              quantity: item['quantity'],
            ))
        .toList();

    final saleId = await _posRepository.processCheckout(
      storeId: storeId,
      cashierUserId: userId,
      cartItems: cartItemObjects,
      paymentMethodId: paymentMethodId,
      taxRate: tax / subtotal, // Calculate tax rate
      note: salesNotes,
    );
    return saleId;
  }
}
