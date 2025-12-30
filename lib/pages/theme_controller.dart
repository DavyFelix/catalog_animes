import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const key = "app_theme";
  ThemeMode themeMode = ThemeMode.system;

  ThemeController() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(key);

    switch (saved) {
      case "light":
        themeMode = ThemeMode.light;
        break;
      case "dark":
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
      await prefs.setString(key, "dark");
    } else {
      themeMode = ThemeMode.light;
      await prefs.setString(key, "light");
    }

    notifyListeners();
  }
}
