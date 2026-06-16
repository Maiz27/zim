import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds app-wide UI state: the active [ThemeMode] (System / Light / Dark) and
/// the navigator/key handles used for global navigation and full rebuilds.
class AppProvider extends ChangeNotifier {
  AppProvider() {
    _loadThemeMode();
  }

  static const String _prefsKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Key key = UniqueKey();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void setKey(Key value) {
    key = value;
    notifyListeners();
  }

  void setNavigatorKey(GlobalKey<NavigatorState> value) {
    navigatorKey = value;
    notifyListeners();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _decode(prefs.getString(_prefsKey));
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(mode));
  }

  static ThemeMode _decode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
