import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = 'theme_mode';
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoading => _isLoading;

  // Constructor - Load saved theme when provider is created
  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isLoading = false;
      notifyListeners();
      debugPrint('✅ Theme loaded: ${isDark ? "Dark" : "Light"} mode');
    } catch (e) {
      debugPrint('❌ Error loading theme preference: $e');
      _themeMode = ThemeMode.light; // Default to light on error
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save theme to SharedPreferences
  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
      debugPrint('💾 Theme saved: ${isDark ? "Dark" : "Light"} mode');
    } catch (e) {
      debugPrint('❌ Error saving theme preference: $e');
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemePreference(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemePreference(mode == ThemeMode.dark);
      notifyListeners();
    }
  }

  // Set light mode explicitly
  Future<void> setLightMode() async {
    if (_themeMode != ThemeMode.light) {
      _themeMode = ThemeMode.light;
      await _saveThemePreference(false);
      notifyListeners();
    }
  }

  // Set dark mode explicitly
  Future<void> setDarkMode() async {
    if (_themeMode != ThemeMode.dark) {
      _themeMode = ThemeMode.dark;
      await _saveThemePreference(true);
      notifyListeners();
    }
  }

  // Clear theme preference (reset to default)
  Future<void> clearThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
      _themeMode = ThemeMode.light;
      notifyListeners();
      debugPrint('🗑️ Theme preference cleared');
    } catch (e) {
      debugPrint('❌ Error clearing theme preference: $e');
    }
  }
}