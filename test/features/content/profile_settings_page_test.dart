import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/app/router/app_router.dart';
import 'package:ghorbad_clone_app/core/config/app_preferences.dart';
import 'package:ghorbad_clone_app/features/content/presentation/pages/profile_settings_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (!sl.isRegistered<SharedPreferences>()) {
      sl.registerSingleton<SharedPreferences>(prefs);
    }
    if (!sl.isRegistered<AppPreferencesService>()) {
      sl.registerSingleton<AppPreferencesService>(AppPreferencesService(prefs));
    }
    AppRouter.setAuthOverride(false);
  });

  tearDown(() {
    AppRouter.setAuthOverride(null);
  });

  Widget buildTestableWidget() {
    return const MaterialApp(
      locale: Locale('bn'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProfileSettingsPage(),
    );
  }

  testWidgets('ProfileSettingsPage renders language selection and theme mode', (tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('প্রোফাইল ও সেটিংস'), findsOneWidget);
    expect(find.text('বাংলা (Bangla) - ডিফল্ট'), findsOneWidget);
    expect(find.text('English (ইংরেজি)'), findsOneWidget);
    expect(find.text('সিস্টেম ডিফল্ট'), findsOneWidget);
    expect(find.text('ডার্ক মোড (#0B1017)'), findsOneWidget);
  });

  testWidgets('ProfileSettingsPage renders Account Actions and delete dialog when authenticated', (tester) async {
    AppRouter.setAuthOverride(true);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Scroll down to Account Actions section
    await tester.scrollUntilVisible(
      find.text('অ্যাকাউন্ট মুছে ফেলুন'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('অ্যাকাউন্ট অ্যাকশন'), findsOneWidget);
    expect(find.text('অ্যাকাউন্ট মুছে ফেলুন'), findsOneWidget);

    // Tap delete account button
    await tester.tap(find.text('অ্যাকাউন্ট মুছে ফেলুন'));
    await tester.pumpAndSettle();

    // Verify dialog shows
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('মুছে ফেলুন'), findsOneWidget);
    expect(find.text('বাতিল'), findsOneWidget);
  });
}
