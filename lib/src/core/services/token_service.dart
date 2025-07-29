import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';

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
          await _saveToken(token, expiryTime);

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
  static Future<void> _saveToken(String token, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
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

  /// Validasi token yang tersimpan
  static Future<bool> isTokenValid() async {
    final token = await getStoredToken();
    return token != null;
  }

  /// Clear token dari local storage
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
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
