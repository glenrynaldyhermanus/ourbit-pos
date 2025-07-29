import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';

class AddToCartUseCase {
  final PosRepository _posRepository;

  AddToCartUseCase(this._posRepository);

  Future<void> call(String productId, int quantity) async {
    final storeId = await SupabaseService.getStoreId();
    if (storeId == null) return;
    await _posRepository.addToCart(storeId, productId, quantity);
  }
}
