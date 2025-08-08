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
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
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

      return null;
    } catch (e) {
      // Handle specific Supabase auth errors
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception(
            'Email atau password salah. Silakan cek kembali kredensial Anda.');
      } else if (e.toString().contains('Email not confirmed')) {
        throw Exception(
            'Email belum dikonfirmasi. Silakan cek email Anda dan klik link konfirmasi.');
      } else if (e.toString().contains('Too many requests')) {
        throw Exception(
            'Terlalu banyak percobaan login. Silakan coba lagi dalam beberapa menit.');
      } else if (e.toString().contains('User not found')) {
        throw Exception(
            'User tidak ditemukan. Silakan daftar terlebih dahulu.');
      } else {
        throw Exception('Gagal login: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('DEBUG: AuthRepository - Starting signOut process');
      // Clear local storage first
      print('DEBUG: AuthRepository - Clearing local storage');
      await LocalStorageService.clearAllData();
      print('DEBUG: AuthRepository - Local storage cleared');

      // Then sign out from Supabase
      print('DEBUG: AuthRepository - Signing out from Supabase');
      await _supabaseClient.auth.signOut();
      print('DEBUG: AuthRepository - Supabase signOut completed');
    } catch (e) {
      print('DEBUG: AuthRepository - SignOut error: $e');
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
      return null;
    }
  }
}
