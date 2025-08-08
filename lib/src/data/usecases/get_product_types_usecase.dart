import 'package:ourbit_pos/src/data/repositories/management_repository.dart';

class GetProductTypesUseCase {
  final ManagementRepository _managementRepository;

  GetProductTypesUseCase(this._managementRepository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await _managementRepository.getProductTypes();
  }
}
