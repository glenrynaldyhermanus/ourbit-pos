import 'package:ourbit_pos/src/data/repositories/management_repository.dart';

class GetExpensesUseCase {
  final ManagementRepository _managementRepository;

  GetExpensesUseCase(this._managementRepository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await _managementRepository.getExpenses();
  }
}
