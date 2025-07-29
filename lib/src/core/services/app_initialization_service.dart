import 'package:flutter/foundation.dart';
import 'package:ourbit_pos/src/core/services/token_service.dart';

class AppInitializationService {
  /// Initialize aplikasi dan handle token dari URL jika ada
  static Future<bool> initializeApp() async {
    try {
      // Hanya jalankan di web
      if (!kIsWeb) return false;

      // Coba handle token dari URL
      final hasToken = await TokenService.handleTokenFromUrl();

      if (hasToken) {
        return true;
      }

      // Cek apakah ada token yang tersimpan
      final hasStoredToken = await TokenService.isTokenValid();
      if (hasStoredToken) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generate URL untuk aplikasi Next.js dengan token
  static String generateNextJsUrl({
    required String baseUrl,
    required String token,
    required DateTime expiry,
  }) {
    return TokenService.generateNextJsUrl(baseUrl, token, expiry);
  }
}
