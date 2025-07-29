import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';

class ClearCartUseCase {
  final PosRepository _posRepository;

  ClearCartUseCase(this._posRepository);

  Future<void> call() async {
    final storeId = await SupabaseService.getStoreId();
    if (storeId == null) return;
    await _posRepository.clearCart(storeId);
  }
}
