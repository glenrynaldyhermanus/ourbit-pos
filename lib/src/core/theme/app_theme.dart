import 'package:flutter/material.dart';

// Helper function untuk menggunakan system font
TextStyle _getSystemFont({
  required double fontSize,
  FontWeight? fontWeight,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

class AppColors {
  // Light Theme Colors
  static const Color primary = Color(0xFFFF5701); // Orange
  static const Color primaryLight = Color(0xFFE04E00);
  static const Color secondary = Color(0xFF191919);
  static const Color tertiary = Color(0xFFF8F9FA);
  static const Color tertiaryText = Color(0xFF9CA3AF);
  static const Color surfaceBackground = Color(0xFFFAFAFA);
  static const Color statusLight = Color(0xFF10B981);

  // Background Colors
  static const Color primaryBackground = Color(0xFFFAFAFA);
  static const Color secondaryBackground = Color(0xFFFFFFFF);

  static const Color primaryText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color mutedForeground = Color(0xFF94A3B8);
  static const Color muted = Color(0xFFF9FAFB);
  static const Color border = Color(0xFFE2E8F0);
  static const Color input = Color(0xFFF8FAFC);
  static const Color ring = Color(0xFFFF5701);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFFFF5701); // Orange
  static const Color darkPrimaryLight = Color(0xFFFF6B1A);
  static const Color darkSecondary = Color(0xFFFFFFFF);
  static const Color darkTertiary = Color(0xFF1F1F1F);
  static const Color darkTertiaryText = Color(0xFF9CA3AF);
  static const Color darkSurfaceBackground = Color(0xFF0F0F0F);
  static const Color darkStatusLight = Color(0xFF34D399);

  // Dark Background Colors
  static const Color darkPrimaryBackground = Color(0xFF0F0F0F);
  static const Color darkSecondaryBackground = Color(0xFF1A1A1A);

  static const Color darkPrimaryText = Color(0xFFF1F5F9);
  static const Color darkSecondaryText = Color(0xFFCBD5E1);
  static const Color darkMutedForeground = Color(0xFF64748B);
  static const Color darkMuted = Color(0xFF111827);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkInput = Color(0xFF1E293B);
  static const Color darkRing = Color(0xFFFF5701);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surfaceBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: AppColors.tertiaryText,
        onSurface: AppColors.primaryText,
        onError: Colors.white,
      ),
      textTheme: const TextTheme().copyWith(
        displayLarge: _getSystemFont(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        displayMedium: _getSystemFont(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        displaySmall: _getSystemFont(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        headlineLarge: _getSystemFont(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        headlineMedium: _getSystemFont(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        headlineSmall: _getSystemFont(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        titleLarge: _getSystemFont(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        titleMedium: _getSystemFont(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
        titleSmall: _getSystemFont(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
        bodyLarge: _getSystemFont(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.primaryText,
        ),
        bodyMedium: _getSystemFont(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.primaryText,
        ),
        bodySmall: _getSystemFont(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.secondaryText,
        ),
        labelLarge: _getSystemFont(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
        labelMedium: _getSystemFont(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
        labelSmall: _getSystemFont(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _getSystemFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _getSystemFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _getSystemFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.ring, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _getSystemFont(
          fontSize: 14,
          color: AppColors.mutedForeground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: const EdgeInsets.all(0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _getSystemFont(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        tertiary: AppColors.darkTertiary,
        surface: AppColors.darkSurfaceBackground,
        error: AppColors.darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: AppColors.darkTertiaryText,
        onSurface: AppColors.darkPrimaryText,
        onError: Colors.white,
      ),
      textTheme: const TextTheme().copyWith(
        displayLarge: _getSystemFont(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkPrimaryText,
        ),
        displayMedium: _getSystemFont(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkPrimaryText,
        ),
        displaySmall: _getSystemFont(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkPrimaryText,
        ),
        headlineLarge: _getSystemFont(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryText,
        ),
        headlineMedium: _getSystemFont(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryText,
        ),
        headlineSmall: _getSystemFont(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryText,
        ),
        titleLarge: _getSystemFont(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryText,
        ),
        titleMedium: _getSystemFont(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkPrimaryText,
        ),
        titleSmall: _getSystemFont(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkSecondaryText,
        ),
        bodyLarge: _getSystemFont(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.darkPrimaryText,
        ),
        bodyMedium: _getSystemFont(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkPrimaryText,
        ),
        bodySmall: _getSystemFont(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.darkSecondaryText,
        ),
        labelLarge: _getSystemFont(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkPrimaryText,
        ),
        labelMedium: _getSystemFont(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkSecondaryText,
        ),
        labelSmall: _getSystemFont(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.darkSecondaryText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _getSystemFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _getSystemFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _getSystemFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkRing, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkError, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _getSystemFont(
          fontSize: 14,
          color: AppColors.darkMutedForeground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: AppColors.darkTertiary,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        margin: const EdgeInsets.all(0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurfaceBackground,
        foregroundColor: AppColors.darkPrimaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _getSystemFont(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryText,
        ),
      ),
    );
  }
}
