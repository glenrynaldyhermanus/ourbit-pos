import 'package:ourbit_pos/src/data/objects/user.dart';
import 'package:ourbit_pos/src/data/repositories/auth_repository.dart';

class AuthenticateWithTokenUseCase {
  final AuthRepository _authRepository;

  AuthenticateWithTokenUseCase(this._authRepository);

  Future<AppUser?> execute(String token) async {
    try {
      // Validasi token terlebih dahulu
      final isValid = await _authRepository.validateToken(token);
      if (!isValid) {
        throw Exception('Invalid token');
      }

      // Authenticate dengan token
      return await _authRepository.authenticateWithToken(token);
    } catch (e) {
      return null;
    }
  }
}
