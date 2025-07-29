import 'package:ourbit_pos/src/core/services/business_store_service.dart';

class GetCurrentBusinessIdUseCase {
  final BusinessStoreService _businessStoreService;

  GetCurrentBusinessIdUseCase(this._businessStoreService);

  Future<String?> execute() async {
    return await _businessStoreService.getCurrentBusinessId();
  }
}
