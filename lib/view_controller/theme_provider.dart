import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  // void toggle() {
  //   _mode = isDark ? ThemeMode.light : ThemeMode.dark;
  //   notifyListeners();
  // }

  // void setSystem() {
  //   _mode = ThemeMode.system;
  //   notifyListeners();
  // }

  void setThemeMode(AppThemeMode key) {
    _mode = switch (key) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
    notifyListeners();
  }
}

enum AppThemeMode { system, light, dark }
