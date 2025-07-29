import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/data/objects/user.dart';
import 'package:ourbit_pos/src/data/repositories/auth_repository.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<AppUser?> signIn(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('Sign in successful for user: ${response.user!.email}');

        // Load and cache user data after successful login
        await SupabaseService.loadUserDataAfterLogin();

        return AppUser(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: response.user!.userMetadata?['full_name'] ??
              response.user!.email?.split('@')[0] ??
              'User',
          avatar: response.user!.userMetadata?['avatar_url'],
        );
      }

      print('Sign in failed: No user returned');
      return null;
    } catch (e) {
      print('Sign in error: $e');
      print('Error type: ${e.runtimeType}');
      if (e is AuthException) {
        print('Auth error message: ${e.message}');
        print('Auth error status code: ${e.statusCode}');
      }
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Clear local storage first
      await LocalStorageService.clearAllData();

      // Then sign out from Supabase
      await _supabaseClient.auth.signOut();
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to sign out');
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      return AppUser(
        id: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User',
        avatar: user.userMetadata?['avatar_url'],
      );
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      return user != null;
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return false;
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      // Coba recover session dengan token
      await _supabaseClient.auth.recoverSession(token);
      final user = _supabaseClient.auth.currentUser;
      return user != null;
    } catch (e) {
      print('Token validation failed: $e');
      return false;
    }
  }

  @override
  Future<AppUser?> authenticateWithToken(String token) async {
    try {
      // Set session dengan token
      await SupabaseService.setSessionToken(token);

      // Load user data setelah authentication
      await SupabaseService.loadUserDataAfterLogin();

      // Get current user
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      return AppUser(
        id: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User',
        avatar: user.userMetadata?['avatar_url'],
      );
    } catch (e) {
      print('Authentication with token failed: $e');
      return null;
    }
  }
}
