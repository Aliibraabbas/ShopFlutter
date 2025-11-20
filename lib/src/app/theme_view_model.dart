import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeViewModel extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.system;

  AppThemeMode get mode => _mode;

  ThemeMode get flutterThemeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  void toggleMode() {
    if (_mode == AppThemeMode.system) {
      _mode = AppThemeMode.light;
    } else if (_mode == AppThemeMode.light) {
      _mode = AppThemeMode.dark;
    } else {
      _mode = AppThemeMode.system;
    }
    notifyListeners();
  }
}
