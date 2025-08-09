import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class GetCategoriesByStoreUseCase {
  final PosRepository _posRepository;

  GetCategoriesByStoreUseCase(this._posRepository);

  Future<List<Map<String, dynamic>>> call() async {
    final storeId = await LocalStorageService.getStoreId();
    Logger.debug(' getCategoriesByStoreUseCase - storeId: $storeId');

    if (storeId == null) {
      Logger.debug(
          'getCategoriesByStoreUseCase - storeId is null, returning empty list');
      return [];
    }

    final categories = await _posRepository.getCategoriesByStoreId(storeId);
    Logger.debug(
        'getCategoriesByStoreUseCase - categories length: ${categories.length}');
    return categories;
  }
}
