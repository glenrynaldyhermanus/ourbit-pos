import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      print('🔍 DEBUG: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
    }
  }

  static void auth(String message) {
    if (kDebugMode) {
      print('🔐 AUTH: $message');
    }
  }

  static void token(String message) {
    if (kDebugMode) {
      print('🎫 TOKEN: $message');
    }
  }

  static void appbar(String message) {
    if (kDebugMode) {
      print('📱 APPBAR: $message');
    }
  }

  static void business(String message) {
    if (kDebugMode) {
      print('🏢 BUSINESS: $message');
    }
  }

  static void cashier(String message) {
    if (kDebugMode) {
      print('💰 CASHIER: $message');
    }
  }

  static void login(String message) {
    if (kDebugMode) {
      print('🔑 LOGIN: $message');
    }
  }

  static void supabase(String message) {
    if (kDebugMode) {
      print('☁️ SUPABASE: $message');
    }
  }
}
