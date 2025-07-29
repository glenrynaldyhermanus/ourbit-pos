import 'package:ourbit_pos/src/data/repositories/management_repository.dart';

class GetLoyaltyProgramsUseCase {
  final ManagementRepository _managementRepository;

  GetLoyaltyProgramsUseCase(this._managementRepository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await _managementRepository.getLoyaltyPrograms();
  }
}
