import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _warningDaysKey = 'warning_days';
  static const String _urgentDaysKey = 'urgent_days';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _warningReminderEnabledKey = 'warning_reminder_enabled';
  static const String _urgentReminderEnabledKey = 'urgent_reminder_enabled';
  static const String _oneDayReminderEnabledKey = 'one_day_reminder_enabled';
  static const String _dueDayReminderEnabledKey = 'due_day_reminder_enabled';

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

  // 通知设置
  bool get notificationEnabled {
    return _prefs.getBool(_notificationEnabledKey) ?? true;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs.setBool(_notificationEnabledKey, enabled);
  }

  // 四类提醒开关（默认开启）
  bool get warningReminderEnabled {
    return _prefs.getBool(_warningReminderEnabledKey) ?? true;
  }

  Future<void> setWarningReminderEnabled(bool enabled) async {
    await _prefs.setBool(_warningReminderEnabledKey, enabled);
  }

  bool get urgentReminderEnabled {
    return _prefs.getBool(_urgentReminderEnabledKey) ?? true;
  }

  Future<void> setUrgentReminderEnabled(bool enabled) async {
    await _prefs.setBool(_urgentReminderEnabledKey, enabled);
  }

  bool get oneDayReminderEnabled {
    return _prefs.getBool(_oneDayReminderEnabledKey) ?? true;
  }

  Future<void> setOneDayReminderEnabled(bool enabled) async {
    await _prefs.setBool(_oneDayReminderEnabledKey, enabled);
  }

  bool get dueDayReminderEnabled {
    return _prefs.getBool(_dueDayReminderEnabledKey) ?? true;
  }

  Future<void> setDueDayReminderEnabled(bool enabled) async {
    await _prefs.setBool(_dueDayReminderEnabledKey, enabled);
  }
}
