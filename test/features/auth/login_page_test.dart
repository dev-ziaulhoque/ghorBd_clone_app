import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/login_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

Widget _buildTestableLoginPage({required AuthBloc authBloc}) {
  return MaterialApp(
    locale: const Locale('bn'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const LoginPage(),
    ),
  );
}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const AuthCheckRequested());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('LoginPage Widget Tests', () {
    testWidgets('renders email, password fields and login button in Bangla', (tester) async {
      await tester.pumpWidget(_buildTestableLoginPage(authBloc: mockAuthBloc));
      await tester.pumpAndSettle();

      expect(find.text('লগইন'), findsWidgets);
      expect(find.text('ইমেইল'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড'), findsOneWidget);
      expect(find.text('অ্যাকাউন্ট নেই? রেজিস্ট্রেশন করুন'), findsOneWidget);
    });

    testWidgets('validation fails on empty submission', (tester) async {
      await tester.pumpWidget(_buildTestableLoginPage(authBloc: mockAuthBloc));
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'লগইন');
      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Field-specific validation messages (no generic error any more)
      expect(find.text('ইমেইল লিখুন'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড লিখুন'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('shows Google button and dispatches Google sign-in on tap', (tester) async {
      await tester.pumpWidget(_buildTestableLoginPage(authBloc: mockAuthBloc));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      expect(find.text('গুগল দিয়ে চালিয়ে যান'), findsOneWidget);
      expect(find.text('অথবা'), findsOneWidget);

      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pump();

      verify(() => mockAuthBloc.add(const AuthGoogleSignInRequested())).called(1);
    });

    testWidgets('shows SnackBar on AuthFailure', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthFailure(
            message: 'ভুল ইমেইল বা পাসওয়ার্ড।',
            messageKey: 'error_invalid_credentials',
          ),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(_buildTestableLoginPage(authBloc: mockAuthBloc));
      await tester.pump();

      expect(find.text('ভুল ইমেইল বা পাসওয়ার্ড।'), findsOneWidget);
    });

    testWidgets('shows loading spinner when AuthLoading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(_buildTestableLoginPage(authBloc: mockAuthBloc));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
