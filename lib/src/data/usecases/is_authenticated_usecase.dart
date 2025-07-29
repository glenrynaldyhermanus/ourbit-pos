import 'package:ourbit_pos/src/data/repositories/auth_repository.dart';

class IsAuthenticatedUseCase {
  final AuthRepository _authRepository;

  IsAuthenticatedUseCase(this._authRepository);

  Future<bool> call() async {
    return await _authRepository.isAuthenticated();
  }
}
