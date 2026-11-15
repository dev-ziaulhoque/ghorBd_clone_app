import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/app/app.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/app/router/app_router.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/login_page.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/pages/home_page.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/pages/listings_page.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/pages/owner_dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  group('AppRouter & Auth Guard', () {
    tearDown(() {
      AppRouter.setAuthOverride(false);
      AppRouter.router.go(AppRoutes.home);
    });

    testWidgets('initial route renders GhorBD Home screen', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('unauthenticated user navigating to protected route is redirected to login',
        (tester) async {
      AppRouter.setAuthOverride(false);
      await tester.pumpWidget(const App());
      await tester.pump();

      AppRouter.router.go(AppRoutes.dashboard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('authenticated user can access protected route directly',
        (tester) async {
      AppRouter.setAuthOverride(true);
      await tester.pumpWidget(const App());
      await tester.pump();

      AppRouter.router.go(AppRoutes.dashboard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(OwnerDashboardPage), findsOneWidget);
    });

    testWidgets('authenticated user navigating to login is redirected to home',
        (tester) async {
      AppRouter.setAuthOverride(true);
      await tester.pumpWidget(const App());
      await tester.pump();

      AppRouter.router.go(AppRoutes.login);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('public route (listings) is accessible to unauthenticated user',
        (tester) async {
      AppRouter.setAuthOverride(false);
      await tester.pumpWidget(const App());
      await tester.pump();

      AppRouter.router.go(AppRoutes.listings);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListingsPage), findsOneWidget);
    });
  });
}
