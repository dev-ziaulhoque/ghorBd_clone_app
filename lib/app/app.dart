import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';
import '../shared/theme/theme.dart';
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
    return MaterialApp.router(
      title: 'GhorBD',
      debugShowCheckedModeBanner: false,
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
    );
  }
}
