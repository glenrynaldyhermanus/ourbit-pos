import 'package:ourbit_pos/src/core/services/supabase_service.dart';
import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';

class GetStorePaymentMethodsUseCase {
  final PosRepository _posRepository;

  GetStorePaymentMethodsUseCase(this._posRepository);

  Future<List<Map<String, dynamic>>> call() async {
    final storeId = await SupabaseService.getStoreId();
    if (storeId == null) return [];
    return _posRepository.getStorePaymentMethods(storeId);
  }
}
