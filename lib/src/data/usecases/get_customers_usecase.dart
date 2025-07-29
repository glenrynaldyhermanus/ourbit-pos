import 'package:ourbit_pos/src/data/repositories/management_repository.dart';

class GetCustomersUseCase {
  final ManagementRepository _managementRepository;

  GetCustomersUseCase(this._managementRepository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await _managementRepository.getCustomers();
  }
}
