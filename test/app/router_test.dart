import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/app/app.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/app/router/app_router.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/login_page.dart';

void main() {
  setUpAll(() async {
    await configureDependencies();
  });

  group('AppRouter & Auth Guard', () {
    tearDown(() {
      AppRouter.setAuthOverride(false);
      AppRouter.router.go(AppRoutes.home);
    });

    testWidgets('initial route renders GhorBD Home screen', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.text('GhorBD Home (SCR-001)'), findsWidgets);
    });

    testWidgets('unauthenticated user navigating to protected route is redirected to login',
        (tester) async {
      AppRouter.setAuthOverride(false);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      AppRouter.router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('authenticated user can access protected route directly',
        (tester) async {
      AppRouter.setAuthOverride(true);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      AppRouter.router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard: My Listings (SCR-013)'), findsWidgets);
    });

    testWidgets('authenticated user navigating to login is redirected to home',
        (tester) async {
      AppRouter.setAuthOverride(true);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      AppRouter.router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      expect(find.text('GhorBD Home (SCR-001)'), findsWidgets);
    });

    testWidgets('public route (listings) is accessible to unauthenticated user',
        (tester) async {
      AppRouter.setAuthOverride(false);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      AppRouter.router.go(AppRoutes.listings);
      await tester.pumpAndSettle();

      expect(find.text('Listings (SCR-002)'), findsWidgets);
    });
  });
}
