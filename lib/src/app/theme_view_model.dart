import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeViewModel extends ChangeNotifier {
  static const _storageKey = 'theme_mode';

  // Stockage sécurisé (utilisé seulement hors Web)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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

  ThemeViewModel() {
    _loadInitialMode();
  }

  Future<void> _loadInitialMode() async {
    try {
      // On lit toujours depuis SharedPreferences (fiable sur toutes les plateformes)
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_storageKey);

      if (value == 'light') {
        _mode = AppThemeMode.light;
      } else if (value == 'dark') {
        _mode = AppThemeMode.dark;
      } else if (value == 'system') {
        _mode = AppThemeMode.system;
      } else {
        _mode = AppThemeMode.system;
      }

      notifyListeners();
    } catch (_) {
      // En cas d'erreur, on garde le mode système
    }
  }

  Future<void> _persistMode() async {
    String value;
    switch (_mode) {
      case AppThemeMode.light:
        value = 'light';
        break;
      case AppThemeMode.dark:
        value = 'dark';
        break;
      case AppThemeMode.system:
        value = 'system';
        break;
    }

    try {
      // Persistance principale : SharedPreferences (toutes plateformes)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, value);

      // Bonus "stockage sécurisé" : on écrit aussi dans FlutterSecureStorage
      if (!kIsWeb) {
        await _secureStorage.write(key: _storageKey, value: value);
      }
    } catch (_) {
      // On ignore l'erreur, ce n'est pas bloquant pour l'app
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
    _persistMode();
    notifyListeners();
  }
}
