import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/data/objects/user.dart';
import 'package:ourbit_pos/src/data/repositories/auth_repository.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/services/token_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<AppUser?> signIn(String email, String password) async {
    try {
      Logger.auth('Starting signIn process for $email');

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Logger.auth('User authenticated successfully');

        // Save the session token after successful authentication
        final session = _supabaseClient.auth.currentSession;
        if (session != null && session.accessToken.isNotEmpty) {
          Logger.auth('Saving session token');
          await TokenService.saveToken(
              session.accessToken,
              session.expiresAt != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      session.expiresAt! * 1000)
                  : DateTime.now().add(const Duration(hours: 1)));
          Logger.auth('Session token saved successfully');
        } else {
          Logger.warning('No session or access token available');
        }

        // User data will be loaded by BusinessStoreService in AuthBloc
        // Don't call loadUserDataAfterLogin here to avoid duplication

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
      Logger.error('SignIn error: $e');
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
      Logger.auth('Starting signOut process');
      // Clear local storage first
      Logger.auth('Clearing local storage');
      await LocalStorageService.clearAllData();
      Logger.auth('Local storage cleared');

      // Then sign out from Supabase
      Logger.auth('Signing out from Supabase');
      await _supabaseClient.auth.signOut();
      Logger.auth('Supabase signOut completed');
    } catch (e) {
      Logger.error('SignOut error: $e');
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
