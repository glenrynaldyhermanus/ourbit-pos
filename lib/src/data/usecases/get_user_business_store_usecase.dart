import 'package:ourbit_pos/src/core/services/business_store_service.dart';

class GetUserBusinessStoreUseCase {
  final BusinessStoreService _businessStoreService;

  GetUserBusinessStoreUseCase(this._businessStoreService);

  Future<Map<String, dynamic>> execute() async {
    return await _businessStoreService.getUserBusinessAndStore();
  }
}
