import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing non-sensitive application preferences (Language, Theme Mode).
/// Backed by SharedPreferences (plain key-value storage, NOT for secrets).
class AppPreferencesService extends ChangeNotifier {
  static const String _keyLanguage = 'ghorbd_pref_language';
  static const String _keyThemeMode = 'ghorbd_pref_theme_mode';
  static const String _keyOnboardingSeen = 'ghorbd_pref_onboarding_seen';

  /// Marker recording that the stored theme value is SETTLED: either the
  /// user explicitly picked a theme (first-run picker or Profile/Settings
  /// — both go through [setThemeMode]) or the Round 3 one-time migration
  /// below has already run. Installs without the marker hold a Round 1/2
  /// era value that may be the old dark-first default rather than a real
  /// user choice.
  static const String _keyThemeExplicitlyChosen =
      'ghorbd_pref_theme_explicitly_chosen';

  final SharedPreferences _prefs;
  late Locale _locale;
  late ThemeMode _themeMode;

  AppPreferencesService(this._prefs) {
    _loadPreferences();
  }

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  /// Whether the stored theme reflects an explicit user choice (or the
  /// one-time migration has already settled it). Exposed for tests.
  bool get themeExplicitlyChosen =>
      _prefs.getBool(_keyThemeExplicitlyChosen) ?? false;

  /// Whether the first-run onboarding has been completed/skipped.
  bool get onboardingSeen => _prefs.getBool(_keyOnboardingSeen) ?? false;

  /// Marks onboarding as seen (persisted; shown once per install).
  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_keyOnboardingSeen, true);
    notifyListeners();
  }

  void _loadPreferences() {
    // Default language is Bangla ('bn')
    final langCode = _prefs.getString(_keyLanguage) ?? 'bn';
    _locale = Locale(langCode);

    final storedTheme = _prefs.getString(_keyThemeMode);
    if (!themeExplicitlyChosen) {
      // One-time Round 3 migration. Round 1 shipped a dark-first default
      // and Round 2's light default only applied when nothing was stored,
      // so an existing install can hold 'dark' (or 'system' following a
      // dark phone) that the user never actually picked — which is why
      // upgraded users kept seeing the old dark-blue Home. Reset such
      // installs ONCE to the current LIGHT default and mark the value as
      // settled so this never runs again. A theme the user later picks
      // explicitly (picker/Settings) sets the same marker via
      // [setThemeMode] and is respected permanently — including Dark,
      // which now renders the post-navy dark palette from
      // `AppColors` (the stored value stays the plain 'dark' string, so
      // the palette swap needed no value migration).
      _themeMode = ThemeMode.light;
      if (storedTheme != 'light') {
        unawaited(_prefs.setString(_keyThemeMode, 'light'));
      }
      unawaited(_prefs.setBool(_keyThemeExplicitlyChosen, true));
      return;
    }

    // Settled value: respect the stored choice (default LIGHT — Round 2,
    // user-confirmed direction: clean white + emerald, fresh look).
    switch (storedTheme) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
        _themeMode = ThemeMode.system;
        break;
      case 'light':
      default:
        _themeMode = ThemeMode.light;
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
  ///
  /// This is only called from explicit user taps (the first-run picker
  /// and Profile/Settings), so it also records the choice as explicit —
  /// the Round 3 migration will never override it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      // Still an explicit tap on the already-active option: make sure
      // the marker is recorded even if the value itself doesn't change.
      if (!themeExplicitlyChosen) {
        await _prefs.setBool(_keyThemeExplicitlyChosen, true);
      }
      return;
    }
    _themeMode = mode;
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _prefs.setString(_keyThemeMode, val);
    await _prefs.setBool(_keyThemeExplicitlyChosen, true);
    notifyListeners();
  }
}
