import 'package:ourbit_pos/src/data/objects/cart_item.dart';
import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';

class GetCartUseCase {
  final PosRepository _posRepository;

  GetCartUseCase(this._posRepository);

  Future<List<CartItem>> call() async {
    final storeId = await SupabaseService.getStoreId();
    if (storeId == null) return [];
    return await _posRepository.getStoreCart(storeId);
  }
}
