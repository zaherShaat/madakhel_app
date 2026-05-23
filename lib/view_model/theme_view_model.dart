import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  String themeSharedKey = 'theme_mode';

  ThemeMode get mode => _mode;
  // bool get isDark => _mode == ThemeMode.dark;

  void setThemeMode(AppThemeMode key) {
    _mode = switch (key) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
    saveThemeMode();
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    // Load the theme mode from persistent storage (e.g., SharedPreferences)
    // and update _mode accordingly, then call notifyListeners().
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(themeSharedKey);
    if (savedMode != null) {
      _mode = switch (savedMode) {
        'system' => ThemeMode.system,
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      notifyListeners();
    }
  }

  Future<void> saveThemeMode() async {
    // Save the theme mode to persistent storage (e.g., SharedPreferences)
    // and update _mode accordingly, then call notifyListeners().
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeSharedKey, _mode.name);
  }
}

enum AppThemeMode { system, light, dark }
