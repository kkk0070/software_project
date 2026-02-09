// Flutter Material Design framework for UI theming
import 'package:flutter/material.dart';
// Storage service for persisting user preferences
import '../services/storage_service.dart';

/// ThemeProvider manages the app's theme state (light/dark mode)
/// Uses ChangeNotifier to notify widgets when theme changes
/// Persists theme preference using StorageService
class ThemeProvider with ChangeNotifier {
  // Private field to store current theme mode
  // Default to light mode on first app launch
  ThemeMode _themeMode = ThemeMode.light;

  /// Getter for current theme mode
  /// Used by MaterialApp to determine which theme to apply
  ThemeMode get themeMode => _themeMode;

  /// Convenience getter to check if dark mode is active
  /// Returns true if current mode is dark, false otherwise
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load saved theme preference from local storage
  /// Called during app initialization to restore user's choice
  /// If no preference is saved, keeps the default (light mode)
  Future<void> loadThemePreference() async {
    // Retrieve saved theme mode string from storage
    final savedTheme = await StorageService.getThemeMode();
    if (savedTheme != null) {
      // Convert string to ThemeMode enum and update state
      _themeMode = _themeModeFromString(savedTheme);
      // Notify all listening widgets to rebuild with new theme
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  /// Switches to opposite mode and persists the choice
  void toggleTheme() {
    // Switch theme: light -> dark or dark -> light
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    // Notify widgets to rebuild with new theme
    notifyListeners();
    // Save preference to storage for next app launch
    _saveThemePreference();
  }

  /// Set specific theme mode (light, dark, or system)
  /// Allows explicit control over theme selection
  /// 
  /// Parameters:
  /// - [mode] - The desired [ThemeMode] to apply
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    // Notify widgets to rebuild with new theme
    notifyListeners();
    // Persist the change to storage
    _saveThemePreference();
  }

  /// Private method to save theme preference to local storage
  /// Converts ThemeMode enum to string for storage
  Future<void> _saveThemePreference() async {
    // Save theme mode name ('light', 'dark', or 'system') to storage
    await StorageService.saveThemeMode(_themeMode.name);
  }

  /// Convert string representation to ThemeMode enum
  /// Used when loading saved preference from storage
  /// 
  /// Parameters:
  /// - [value] - String representation ('light', 'dark', 'system')
  /// 
  /// Returns the corresponding [ThemeMode] enum value
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system; // Follow system theme setting
      default:
        return ThemeMode.light; // Default to light if invalid value
    }
  }
}
