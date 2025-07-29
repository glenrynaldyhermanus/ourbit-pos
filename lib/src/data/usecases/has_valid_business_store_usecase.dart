import 'package:ourbit_pos/src/core/services/business_store_service.dart';

class HasValidBusinessStoreUseCase {
  final BusinessStoreService _businessStoreService;

  HasValidBusinessStoreUseCase(this._businessStoreService);

  Future<bool> execute() async {
    return await _businessStoreService.hasValidBusinessAndStore();
  }
}
