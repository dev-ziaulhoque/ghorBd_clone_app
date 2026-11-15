import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/config/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesService Unit Tests', () {
    test('initializes with default bn locale and system theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      expect(service.locale.languageCode, 'bn');
      expect(service.themeMode, ThemeMode.system);
    });

    test('loads persisted language and theme mode', () async {
      SharedPreferences.setMockInitialValues({
        'ghorbd_pref_language': 'en',
        'ghorbd_pref_theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      expect(service.locale.languageCode, 'en');
      expect(service.themeMode, ThemeMode.dark);
    });

    test('setLocale updates and persists new language', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      bool notified = false;
      service.addListener(() => notified = true);

      await service.setLocale(const Locale('en'));

      expect(service.locale.languageCode, 'en');
      expect(prefs.getString('ghorbd_pref_language'), 'en');
      expect(notified, isTrue);
    });

    test('toggleLanguage toggles between bn and en', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      expect(service.locale.languageCode, 'bn');

      await service.toggleLanguage();
      expect(service.locale.languageCode, 'en');

      await service.toggleLanguage();
      expect(service.locale.languageCode, 'bn');
    });

    test('setThemeMode updates and persists themeMode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      await service.setThemeMode(ThemeMode.dark);
      expect(service.themeMode, ThemeMode.dark);
      expect(prefs.getString('ghorbd_pref_theme_mode'), 'dark');

      await service.setThemeMode(ThemeMode.light);
      expect(service.themeMode, ThemeMode.light);
      expect(prefs.getString('ghorbd_pref_theme_mode'), 'light');
    });
  });
}
