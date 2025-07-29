import 'package:ourbit_pos/src/core/services/business_store_service.dart';

class GetCurrentStoreIdUseCase {
  final BusinessStoreService _businessStoreService;

  GetCurrentStoreIdUseCase(this._businessStoreService);

  Future<String?> execute() async {
    return await _businessStoreService.getCurrentStoreId();
  }
}
