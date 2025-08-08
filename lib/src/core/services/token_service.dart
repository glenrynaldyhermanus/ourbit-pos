import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';

// Conditional import untuk dart:html hanya di web
import 'token_service_web.dart' if (dart.library.io) 'token_service_stub.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'token_expiry';

  /// Menerima token dari URL parameters (hanya untuk web)
  static Future<bool> handleTokenFromUrl() async {
    if (!kIsWeb) return false;

    try {
      // First, handle hash fragment if present
      _handleHashFragment();
      // Convert hash URLs to path URLs for better routing
      _convertHashToPath();

      final uri = Uri.parse(TokenServiceWeb.getCurrentUrl());
      final token = uri.queryParameters['token'];
      final expiry = uri.queryParameters['expiry'];

      if (token != null && expiry != null) {
        // Validasi expiry
        final expiryTime = DateTime.tryParse(expiry);
        if (expiryTime != null && expiryTime.isAfter(DateTime.now())) {
          // Token masih valid
          await saveToken(token, expiryTime);

          // Load user data berdasarkan token
          await _loadUserDataFromToken(token);

          // Verify user is authenticated before clearing URL
          if (await SupabaseService.isUserAuthenticated()) {
            _clearUrlParameters();
            return true;
          } else {
            return false;
          }
        } else {}
      } else {}
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Menyimpan token ke local storage
  static Future<void> saveToken(String token, DateTime expiry) async {
    print('💾 TOKEN_SERVICE: Saving token to storage');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    print('✅ TOKEN_SERVICE: Token saved successfully');
  }

  /// Memuat data user berdasarkan token
  static Future<void> _loadUserDataFromToken(String token) async {
    try {
      // Set token ke Supabase client
      await SupabaseService.setSessionToken(token);

      // Give a small delay to ensure session is properly set
      await Future.delayed(const Duration(milliseconds: 500));

      // Load user data
      await SupabaseService.loadUserDataAfterLogin();
    } catch (e) {
      throw Exception('Failed to load user data from token');
    }
  }

  /// Mendapatkan token dari local storage
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryString = prefs.getString(_tokenExpiryKey);

    if (token != null && expiryString != null) {
      final expiry = DateTime.tryParse(expiryString);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return token;
      } else {
        // Token expired, hapus dari storage
        await clearToken();
      }
    }

    return null;
  }

  /// Refresh session if needed
  static Future<bool> refreshSessionIfNeeded() async {
    try {
      print('🔐 TOKEN_SERVICE: Starting refreshSessionIfNeeded()');

      final session = SupabaseService.client.auth.currentSession;
      if (session == null) {
        print('❌ TOKEN_SERVICE: No current session found');
        return false;
      }

      print('✅ TOKEN_SERVICE: Current session found');
      print('📅 TOKEN_SERVICE: Session expires at: ${session.expiresAt}');

      // Check if session will expire in the next 10 minutes
      if (session.expiresAt != null) {
        // Convert timestamp to DateTime - handle both seconds and milliseconds
        DateTime expiryTime;
        if (session.expiresAt! > 9999999999) {
          // Timestamp is in milliseconds
          expiryTime = DateTime.fromMillisecondsSinceEpoch(session.expiresAt!);
        } else {
          // Timestamp is in seconds
          expiryTime =
              DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
        }

        final now = DateTime.now();
        final timeUntilExpiry = expiryTime.difference(now);

        print(
            '⏰ TOKEN_SERVICE: Time until expiry: ${timeUntilExpiry.inMinutes} minutes');
        print('📅 TOKEN_SERVICE: Calculated expiry time: $expiryTime');

        // If session expires in less than 10 minutes, try to refresh
        if (timeUntilExpiry.inMinutes < 10) {
          print(
              '🔄 TOKEN_SERVICE: Session expires soon, attempting refresh...');
          try {
            await SupabaseService.client.auth.refreshSession();
            print('✅ TOKEN_SERVICE: Session refreshed successfully');
            return true;
          } catch (e) {
            print('❌ TOKEN_SERVICE: Session refresh failed: $e');
            return false;
          }
        } else {
          print('✅ TOKEN_SERVICE: Session still valid, no refresh needed');
        }
      } else {
        print('⚠️ TOKEN_SERVICE: Session has no expiry time');
      }

      return true;
    } catch (e) {
      print('❌ TOKEN_SERVICE: Error in refreshSessionIfNeeded: $e');
      return false;
    }
  }

  /// Validasi token yang tersimpan
  static Future<bool> isTokenValid() async {
    try {
      print('🔐 TOKEN_SERVICE: Starting isTokenValid() check');

      // First check if Supabase session is still valid
      final user = SupabaseService.client.auth.currentUser;
      print('👤 TOKEN_SERVICE: Current user: ${user?.email ?? "null"}');

      if (user == null) {
        print('❌ TOKEN_SERVICE: No current user found - AUTHENTICATED: false');
        await clearToken();
        return false;
      }

      // Check if session is still valid by trying to get user info
      final session = SupabaseService.client.auth.currentSession;
      print(
          '📋 TOKEN_SERVICE: Current session: ${session != null ? "exists" : "null"}');

      if (session == null) {
        print('❌ TOKEN_SERVICE: No valid session found - AUTHENTICATED: false');
        await clearToken();
        return false;
      }

      // Check if session is expired
      if (session.expiresAt != null) {
        // Convert timestamp to DateTime - handle both seconds and milliseconds
        DateTime expiryTime;
        if (session.expiresAt! > 9999999999) {
          // Timestamp is in milliseconds
          expiryTime = DateTime.fromMillisecondsSinceEpoch(session.expiresAt!);
        } else {
          // Timestamp is in seconds
          expiryTime =
              DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
        }

        final now = DateTime.now();
        final isExpired = expiryTime.isBefore(now);

        print('📅 TOKEN_SERVICE: Session expiry: ${expiryTime}');
        print('⏰ TOKEN_SERVICE: Current time: ${now}');
        print('🔍 TOKEN_SERVICE: Session expired: $isExpired');

        if (isExpired) {
          print('❌ TOKEN_SERVICE: Session has expired - AUTHENTICATED: false');
          await clearToken();
          return false;
        }
      } else {
        print('⚠️ TOKEN_SERVICE: Session has no expiry time');
      }

      // Check stored token - this is now REQUIRED
      final storedToken = await getStoredToken();
      final hasStoredToken = storedToken != null;

      print('💾 TOKEN_SERVICE: Stored token exists: $hasStoredToken');

      if (!hasStoredToken) {
        print('❌ TOKEN_SERVICE: No stored token found - AUTHENTICATED: false');
        print(
            '🚪 TOKEN_SERVICE: User will be logged out due to missing stored token');
        await clearToken();
        return false;
      }

      print(
          '✅ TOKEN_SERVICE: Both session and stored token are valid - AUTHENTICATED: true');
      return true;
    } catch (e) {
      print('❌ TOKEN_SERVICE: Error during token validation: $e');
      print(
          '❌ TOKEN_SERVICE: Clearing token due to error - AUTHENTICATED: false');
      await clearToken();
      return false;
    }
  }

  /// Clear token dari local storage
  static Future<void> clearToken() async {
    print('🗑️ TOKEN_SERVICE: Clearing stored token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
    print('✅ TOKEN_SERVICE: Token cleared from storage');
  }

  /// Force logout dan clear semua data
  static Future<void> forceLogout() async {
    print('🚪 TOKEN_SERVICE: Starting force logout process');

    try {
      // Clear Supabase session
      print('🔐 TOKEN_SERVICE: Signing out from Supabase');
      await SupabaseService.client.auth.signOut();
      print('✅ TOKEN_SERVICE: Supabase signOut completed');
    } catch (e) {
      print('⚠️ TOKEN_SERVICE: Error during Supabase signOut: $e');
    }

    // Clear all local data
    print('🗑️ TOKEN_SERVICE: Clearing all local data');
    await clearToken();
    await LocalStorageService.clearAllData();
    print('✅ TOKEN_SERVICE: Force logout completed');
  }

  /// Handle hash fragment di awal untuk mencegah GoRouter confusion
  static void _handleHashFragment() {
    if (kIsWeb) {
      final currentUrl = TokenServiceWeb.getCurrentUrl();
      if (currentUrl.contains('#')) {
        // Remove hash fragment immediately
        final cleanUrl = currentUrl.split('#')[0];
        TokenServiceWeb.replaceState(cleanUrl);
      }
    }
  }

  /// Convert hash URL to path URL (for backward compatibility)
  static void _convertHashToPath() {
    if (kIsWeb) {
      final currentUrl = TokenServiceWeb.getCurrentUrl();
      if (currentUrl.contains('#/')) {
        // Convert #/payment to /payment
        final path = currentUrl.split('#/')[1];
        final newUrl = '${currentUrl.split('#')[0]}/$path';
        TokenServiceWeb.replaceState(newUrl);
      }
    }
  }

  /// Clear URL parameters setelah token diproses
  static void _clearUrlParameters() {
    if (kIsWeb) {
      final uri = Uri.parse(TokenServiceWeb.getCurrentUrl());
      final newUri = uri.replace(queryParameters: {});
      // Remove hash fragment as well
      final cleanUrl = newUri.toString().split('#')[0];
      TokenServiceWeb.replaceState(cleanUrl);
    }
  }

  /// Generate URL untuk aplikasi Next.js dengan token
  static String generateNextJsUrl(
      String baseUrl, String token, DateTime expiry) {
    final uri = Uri.parse(baseUrl);
    return uri.replace(queryParameters: {
      'token': token,
      'expiry': expiry.toIso8601String(),
    }).toString();
  }
}
