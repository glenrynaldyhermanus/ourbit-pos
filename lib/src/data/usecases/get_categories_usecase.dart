import 'package:ourbit_pos/src/data/repositories/management_repository.dart';

class GetCategoriesUseCase {
  final ManagementRepository _managementRepository;

  GetCategoriesUseCase(this._managementRepository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await _managementRepository.getCategories();
  }
}
