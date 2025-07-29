import 'package:ourbit_pos/src/core/services/business_store_service.dart';

class SwitchStoreUseCase {
  final BusinessStoreService _businessStoreService;

  SwitchStoreUseCase(this._businessStoreService);

  Future<void> execute(String storeId) async {
    return await _businessStoreService.switchStore(storeId);
  }
}
