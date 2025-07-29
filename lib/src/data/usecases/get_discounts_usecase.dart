import 'package:ourbit_pos/src/data/repositories/management_repository.dart';

class GetDiscountsUseCase {
  final ManagementRepository _managementRepository;

  GetDiscountsUseCase(this._managementRepository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await _managementRepository.getDiscounts();
  }
}
