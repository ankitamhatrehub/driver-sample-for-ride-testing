import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/app/theme/theme_state.dart';

class ThemeRepository {
  ThemeRepository(this._preferences);

  final SharedPreferences _preferences;

  static const pinkKey = 'is_pink_theme';
  static const genderKey = 'user_gender';
  static const appearanceKey = 'app_theme';

  ThemeState read() {
    final savedPink = _preferences.getBool(pinkKey);
    final gender = (_preferences.getString(genderKey) ?? '').toLowerCase();
    final label = _preferences.getString(appearanceKey) ?? 'Default';
    return ThemeState(
      isPink: savedPink ?? gender == 'female',
      themeMode: modeFor(label),
      appearanceLabel: label,
    );
  }

  Future<void> savePink(bool isPink) {
    return _preferences.setBool(pinkKey, isPink);
  }

  Future<void> saveAppearance(String label) {
    return _preferences.setString(appearanceKey, label);
  }

  static ThemeMode modeFor(String label) {
    switch (label) {
      case 'Dark Mode':
        return ThemeMode.dark;
      case 'Light Mode':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
