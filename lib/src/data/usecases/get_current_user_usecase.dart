import 'package:ourbit_pos/src/data/objects/user.dart';
import 'package:ourbit_pos/src/data/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<AppUser?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
