import 'package:ourbit_pos/src/data/objects/user.dart';

abstract class AuthRepository {
  Future<AppUser?> signIn(String email, String password);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<bool> validateToken(String token);
  Future<AppUser?> authenticateWithToken(String token);
}
