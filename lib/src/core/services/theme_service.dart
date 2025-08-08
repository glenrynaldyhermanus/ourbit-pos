import 'package:flutter/material.dart';
import 'local_storage_service.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final savedTheme = await LocalStorageService.getThemePreference();
    if (savedTheme != null) {
      _isDarkMode = savedTheme;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await LocalStorageService.saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    await LocalStorageService.saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  Future<void> resetTheme() async {
    await LocalStorageService.clearThemePreference();
    _isDarkMode = false;
    notifyListeners();
  }
}
