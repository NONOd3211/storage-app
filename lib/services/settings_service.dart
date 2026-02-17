import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _warningDaysKey = 'warning_days';
  static const String _urgentDaysKey = 'urgent_days';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 主题设置
  ThemeMode get themeMode {
    final value = _prefs.getString(_themeKey);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(_themeKey, value);
  }

  // 保质期阈值设置
  int get warningDays {
    return _prefs.getInt(_warningDaysKey) ?? 30;
  }

  Future<void> setWarningDays(int days) async {
    await _prefs.setInt(_warningDaysKey, days);
  }

  int get urgentDays {
    return _prefs.getInt(_urgentDaysKey) ?? 7;
  }

  Future<void> setUrgentDays(int days) async {
    await _prefs.setInt(_urgentDaysKey, days);
  }
}
