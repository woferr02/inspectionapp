import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton notifier that drives [ThemeMode] across the app.
/// Persists user preference via SharedPreferences.
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier._();
  static final ThemeNotifier instance = ThemeNotifier._();

  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// Call once at startup to restore persisted preference.
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_key);
      if (stored == 'dark') {
        _mode = ThemeMode.dark;
      } else if (stored == 'system') {
        _mode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {}
  }

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    _persist();
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (_mode) {
        case ThemeMode.dark:
          prefs.setString(_key, 'dark');
          break;
        case ThemeMode.light:
          prefs.setString(_key, 'light');
          break;
        case ThemeMode.system:
          prefs.remove(_key);
          break;
      }
    } catch (_) {}
  }
}
