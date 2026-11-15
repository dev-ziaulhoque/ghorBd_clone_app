import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing non-sensitive application preferences (Language, Theme Mode).
/// Backed by SharedPreferences (plain key-value storage, NOT for secrets).
class AppPreferencesService extends ChangeNotifier {
  static const String _keyLanguage = 'ghorbd_pref_language';
  static const String _keyThemeMode = 'ghorbd_pref_theme_mode';

  final SharedPreferences _prefs;
  late Locale _locale;
  late ThemeMode _themeMode;

  AppPreferencesService(this._prefs) {
    _loadPreferences();
  }

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void _loadPreferences() {
    // Default language is Bangla ('bn')
    final langCode = _prefs.getString(_keyLanguage) ?? 'bn';
    _locale = Locale(langCode);

    // Default theme is system
    final themeString = _prefs.getString(_keyThemeMode) ?? 'system';
    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }

  /// Sets the application locale ('bn' or 'en') and persists it.
  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode == newLocale.languageCode) return;
    _locale = newLocale;
    await _prefs.setString(_keyLanguage, newLocale.languageCode);
    notifyListeners();
  }

  /// Toggles between Bangla and English.
  Future<void> toggleLanguage() async {
    final next = _locale.languageCode == 'bn' ? const Locale('en') : const Locale('bn');
    await setLocale(next);
  }

  /// Sets the theme mode (light, dark, system) and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _prefs.setString(_keyThemeMode, val);
    notifyListeners();
  }
}
