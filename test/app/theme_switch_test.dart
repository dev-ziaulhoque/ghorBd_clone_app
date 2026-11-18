import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/app/app.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/core/config/app_preferences.dart';
import 'package:ghorbad_clone_app/features/onboarding/presentation/pages/splash_page.dart';
import 'package:ghorbad_clone_app/shared/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Round 3 regression: dark mode must actually work app-wide. The
/// first-run picker and Profile/Settings both call
/// [AppPreferencesService.setThemeMode]; this test drives that same
/// path against the real [App] widget and asserts the whole app flips
/// (the user reported "dark mode nai" — it didn't take effect).
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'ghorbd_pref_onboarding_seen': true,
    });
    await configureDependencies();
  });

  testWidgets('default is Light; selecting Dark applies app-wide; Light restores',
      (tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    MaterialApp appWidget() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    ThemeData visibleTheme() =>
        Theme.of(tester.element(find.byType(SplashPage)));

    // Fresh/migrated installs land on Light (Round 2/3 default).
    expect(appWidget().themeMode, ThemeMode.light);
    expect(visibleTheme().brightness, Brightness.light);

    // Simulate the picker/Settings Dark tap. The app crossfades themes
    // (AnimatedTheme, Round 3), so advance past the 300ms transition
    // before reading the visible brightness. (pumpAndSettle is unusable
    // here: the splash spinner animates forever by design.)
    final prefs = sl<AppPreferencesService>();
    await prefs.setThemeMode(ThemeMode.dark);
    await tester.pump(); // rebuild starts the crossfade
    await tester.pump(const Duration(milliseconds: 400));

    expect(appWidget().themeMode, ThemeMode.dark);
    expect(visibleTheme().brightness, Brightness.dark);
    // The dark scaffold is the emerald-black palette, never navy.
    expect(
      appWidget().darkTheme?.scaffoldBackgroundColor,
      AppColors.backgroundDark,
    );
    expect(AppColors.backgroundDark, const Color(0xFF0B1511));

    // Switching back to Light restores the light app.
    await prefs.setThemeMode(ThemeMode.light);
    await tester.pump(); // rebuild starts the crossfade
    await tester.pump(const Duration(milliseconds: 400));

    expect(appWidget().themeMode, ThemeMode.light);
    expect(visibleTheme().brightness, Brightness.light);

    // Unmount the app: SplashPage.dispose cancels its dwell timer, so
    // no timer is left pending at test end (and we avoid navigating
    // into Home, which would start real data fetches).
    await tester.pumpWidget(const SizedBox());
  });
}
