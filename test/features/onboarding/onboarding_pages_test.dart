import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/core/config/app_preferences.dart';
import 'package:ghorbad_clone_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:ghorbad_clone_app/features/onboarding/presentation/pages/splash_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:ghorbad_clone_app/shared/widgets/brand_logo.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _buildOnboarding({VoidCallback? onFinished}) {
  return MaterialApp(
    locale: const Locale('bn'),
    localizationsDelegates: _delegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: OnboardingPage(onFinished: onFinished),
  );
}

Widget _buildSplashApp() {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const Text('ONBOARDING_SCREEN')),
      GoRoute(path: '/', builder: (_, __) => const Text('HOME_SCREEN')),
    ],
  );
  return MaterialApp.router(
    locale: const Locale('bn'),
    localizationsDelegates: _delegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

void main() {
  group('SplashPage', () {
    tearDown(() async {
      if (sl.isRegistered<AppPreferencesService>()) {
        await sl.unregister<AppPreferencesService>();
      }
    });

    testWidgets('shows brand logo and tagline, then routes home for returning users',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'ghorbd_pref_onboarding_seen': true,
      });
      final prefs = await SharedPreferences.getInstance();
      sl.registerSingleton<AppPreferencesService>(AppPreferencesService(prefs));

      await tester.pumpWidget(_buildSplashApp());
      await tester.pump();

      expect(find.byType(BrandLogo), findsOneWidget);
      expect(find.text('আপনার পছন্দের ঘর খুঁজুন সহজেই'), findsOneWidget);

      // Advance past the 1800ms dwell
      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('HOME_SCREEN'), findsOneWidget);
    });

    testWidgets('routes first-run users to onboarding', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      sl.registerSingleton<AppPreferencesService>(AppPreferencesService(prefs));

      await tester.pumpWidget(_buildSplashApp());
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ONBOARDING_SCREEN'), findsOneWidget);
    });
  });

  group('OnboardingPage', () {
    testWidgets('shows setup step first, then the three value-prop pages via Next',
        (tester) async {
      var finished = false;
      await tester.pumpWidget(_buildOnboarding(onFinished: () => finished = true));
      await tester.pumpAndSettle();

      // Page 1 (Round 2): theme + language setup step.
      expect(find.text('আপনার পছন্দ বেছে নিন'), findsOneWidget);
      expect(find.text('লাইট'), findsOneWidget);
      expect(find.text('ডার্ক'), findsOneWidget);
      expect(find.text('সিস্টেম'), findsOneWidget);
      expect(find.text('বাংলা'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('পরবর্তী'), findsOneWidget);
      expect(find.text('এড়িয়ে যান'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('পছন্দের বাসা খুঁজুন'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('সরাসরি বাড়িওয়ালার সাথে যোগাযোগ'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('যাচাইকৃত ব্যাজ, সম্পূর্ণ বিনামূল্যে'), findsOneWidget);
      expect(find.text('শুরু করুন'), findsOneWidget);
      expect(finished, isFalse);

      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
    });

    testWidgets('setup step persists theme and language choices',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferencesService(prefs);
      sl.registerSingleton<AppPreferencesService>(service);
      addTearDown(() async {
        if (sl.isRegistered<AppPreferencesService>()) {
          await sl.unregister<AppPreferencesService>();
        }
      });

      // Default (Round 2): light theme, Bangla.
      expect(service.themeMode, ThemeMode.light);
      expect(service.locale.languageCode, 'bn');

      await tester.pumpWidget(_buildOnboarding(onFinished: () {}));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('setup_theme_dark')));
      await tester.pumpAndSettle();
      expect(service.themeMode, ThemeMode.dark);
      expect(prefs.getString('ghorbd_pref_theme_mode'), 'dark');

      await tester.tap(find.byKey(const Key('setup_language_en')));
      await tester.pumpAndSettle();
      expect(service.locale.languageCode, 'en');
      expect(prefs.getString('ghorbd_pref_language'), 'en');

      await tester.tap(find.byKey(const Key('setup_theme_light')));
      await tester.pumpAndSettle();
      expect(service.themeMode, ThemeMode.light);
      expect(prefs.getString('ghorbd_pref_theme_mode'), 'light');
    });

    testWidgets('Skip finishes onboarding immediately', (tester) async {
      var finished = false;
      await tester.pumpWidget(_buildOnboarding(onFinished: () => finished = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding_skip_button')));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
    });
  });
}
