import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/config/app_preferences.dart';
import '../core/security/session_manager.dart';
import '../l10n/app_localizations.dart';
import '../shared/theme/theme.dart';
import '../shared/widgets/app_motion.dart';
import 'di/injection.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  final Locale? locale;
  final ThemeMode themeMode;

  const App({
    super.key,
    this.locale,
    this.themeMode = ThemeMode.system,
  });

  @override
  Widget build(BuildContext context) {
    if (sl.isRegistered<AppPreferencesService>()) {
      return ListenableBuilder(
        listenable: sl<AppPreferencesService>(),
        builder: (context, _) {
          final prefs = sl<AppPreferencesService>();
          return MaterialApp.router(
            title: 'GhorBD',
            debugShowCheckedModeBanner: false,
            // Theme changes crossfade (AnimatedTheme) instead of
            // snapping when the user switches Light/Dark (Round 3).
            themeAnimationDuration: AppMotion.medium,
            themeAnimationCurve: AppMotion.curve,
            routerConfig: AppRouter.router,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: prefs.themeMode,
            locale: locale ?? prefs.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) {
                if (sl.isRegistered<SessionManager>()) {
                  sl<SessionManager>().recordActivity();
                }
              },
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      );
    }

    return MaterialApp.router(
      title: 'GhorBD',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: AppMotion.medium,
      themeAnimationCurve: AppMotion.curve,
      routerConfig: AppRouter.router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale ?? const Locale('bn'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          if (sl.isRegistered<SessionManager>()) {
            sl<SessionManager>().recordActivity();
          }
        },
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
