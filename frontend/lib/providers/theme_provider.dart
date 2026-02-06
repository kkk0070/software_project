import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Load theme preference from storage
  Future<void> loadThemePreference() async {
    final savedTheme = await StorageService.getThemeMode();
    if (savedTheme != null) {
      _themeMode = _themeModeFromString(savedTheme);
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveThemePreference();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveThemePreference();
  }

  // Save theme preference to storage
  Future<void> _saveThemePreference() async {
    await StorageService.saveThemeMode(_themeMode.name);
  }

  // Convert string to ThemeMode
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}
