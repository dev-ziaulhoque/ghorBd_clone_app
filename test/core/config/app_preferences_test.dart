import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/config/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesService Unit Tests', () {
    test('initializes with default bn locale and light-first theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      expect(service.locale.languageCode, 'bn');
      expect(service.themeMode, ThemeMode.light);
    });

    test('loads persisted language; legacy theme without explicit marker migrates', () async {
      // Round 3 migration: a stored theme from the Round 1/2 era with
      // no explicit-choice marker is NOT treated as a user choice (see
      // the migration group below) — language is unaffected.
      SharedPreferences.setMockInitialValues({
        'ghorbd_pref_language': 'en',
        'ghorbd_pref_theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      expect(service.locale.languageCode, 'en');
      expect(service.themeMode, ThemeMode.light);
    });

    group('Round 3 one-time theme migration', () {
      test('legacy stored dark without marker resets once to light', () async {
        SharedPreferences.setMockInitialValues({
          'ghorbd_pref_theme_mode': 'dark',
        });
        final prefs = await SharedPreferences.getInstance();
        final service = AppPreferencesService(prefs);

        expect(service.themeMode, ThemeMode.light);
        expect(service.themeExplicitlyChosen, isTrue);
        expect(prefs.getString('ghorbd_pref_theme_mode'), 'light');
        expect(prefs.getBool('ghorbd_pref_theme_explicitly_chosen'), isTrue);

        // One-time only: a second service over the same store keeps the
        // settled value (no repeated resets).
        final second = AppPreferencesService(prefs);
        expect(second.themeMode, ThemeMode.light);
      });

      test('legacy stored system without marker resets to light', () async {
        SharedPreferences.setMockInitialValues({
          'ghorbd_pref_theme_mode': 'system',
        });
        final prefs = await SharedPreferences.getInstance();
        final service = AppPreferencesService(prefs);

        expect(service.themeMode, ThemeMode.light);
        expect(prefs.getString('ghorbd_pref_theme_mode'), 'light');
      });

      test('explicit dark with marker is respected permanently', () async {
        SharedPreferences.setMockInitialValues({
          'ghorbd_pref_theme_mode': 'dark',
          'ghorbd_pref_theme_explicitly_chosen': true,
        });
        final prefs = await SharedPreferences.getInstance();
        final service = AppPreferencesService(prefs);

        expect(service.themeMode, ThemeMode.dark);
        expect(prefs.getString('ghorbd_pref_theme_mode'), 'dark');
      });

      test('explicit choice after migration is never overridden', () async {
        SharedPreferences.setMockInitialValues({
          'ghorbd_pref_theme_mode': 'dark', // legacy, no marker
        });
        final prefs = await SharedPreferences.getInstance();
        final service = AppPreferencesService(prefs);
        expect(service.themeMode, ThemeMode.light); // migrated

        // The user now explicitly picks Dark (picker/Settings path).
        await service.setThemeMode(ThemeMode.dark);
        expect(service.themeMode, ThemeMode.dark);
        expect(prefs.getBool('ghorbd_pref_theme_explicitly_chosen'), isTrue);

        // A fresh service (next app launch) must keep Dark.
        final relaunched = AppPreferencesService(prefs);
        expect(relaunched.themeMode, ThemeMode.dark);
      });
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

      // Default is light-first (Round 2), so switch to dark first (a
      // no-change setThemeMode call intentionally does not rewrite
      // storage).
      await service.setThemeMode(ThemeMode.dark);
      expect(service.themeMode, ThemeMode.dark);
      expect(prefs.getString('ghorbd_pref_theme_mode'), 'dark');
      // An explicit choice records the marker so the Round 3 migration
      // never overrides it on a later launch.
      expect(prefs.getBool('ghorbd_pref_theme_explicitly_chosen'), isTrue);

      await service.setThemeMode(ThemeMode.light);
      expect(service.themeMode, ThemeMode.light);
      expect(prefs.getString('ghorbd_pref_theme_mode'), 'light');
    });

    test('onboardingSeen defaults to false and persists when set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);

      expect(service.onboardingSeen, isFalse);
      await service.setOnboardingSeen();
      expect(service.onboardingSeen, isTrue);
      expect(prefs.getBool('ghorbd_pref_onboarding_seen'), isTrue);
    });
  });
}
