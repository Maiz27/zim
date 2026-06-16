import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the user's file-listing preferences (show-hidden, sort order) and their
/// persistence. Kept separate from CategoryProvider so toggling a setting only
/// rebuilds the small settings / sort surfaces — not the large file-list
/// consumers that listen to CategoryProvider.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  bool showHidden = false;
  int sort = 0;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    showHidden = prefs.getBool('hidden') ?? false;
    sort = prefs.getInt('sort') ?? 0;
    notifyListeners();
  }

  Future<void> setHidden(bool value) async {
    if (value == showHidden) return;
    showHidden = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hidden', value);
  }

  Future<void> setSort(int value) async {
    if (value == sort) return;
    sort = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sort', value);
  }
}
