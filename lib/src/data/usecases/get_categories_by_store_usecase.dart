import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';

class GetCategoriesByStoreUseCase {
  final PosRepository _posRepository;

  GetCategoriesByStoreUseCase(this._posRepository);

  Future<List<Map<String, dynamic>>> call() async {
    final storeId = await LocalStorageService.getStoreId();
    if (storeId == null) return [];
    
    return await _posRepository.getCategoriesByStoreId(storeId);
  }
}
