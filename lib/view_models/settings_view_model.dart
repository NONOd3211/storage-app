import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._settingsService);

  final SettingsService _settingsService;

  ThemeMode get themeMode => _settingsService.themeMode;
  AppLanguageMode get languageMode => _settingsService.languageMode;
  Locale get manualLocale => _settingsService.manualLocale;

  Locale? get appLocale {
    if (languageMode == AppLanguageMode.system) {
      return null;
    }
    return manualLocale;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setLanguageFollowSystem() async {
    await _settingsService.setLanguageMode(AppLanguageMode.system);
    notifyListeners();
  }

  Future<void> setManualLanguage(Locale locale) async {
    await _settingsService.setManualLocale(locale);
    await _settingsService.setLanguageMode(AppLanguageMode.manual);
    notifyListeners();
  }
}
