import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockForgotPasswordUseCase extends Mock
    implements ForgotPasswordUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;

  setUpAll(() {
    registerFallbackValue(const ForgotPasswordSubmitted(email: ''));
    registerFallbackValue(
      const ResetPasswordSubmitted(token: '', newPassword: ''),
    );
  });

  setUp(() {
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();

    if (sl.isRegistered<ForgotPasswordUseCase>()) {
      sl.unregister<ForgotPasswordUseCase>();
    }
    sl.registerLazySingleton<ForgotPasswordUseCase>(
      () => mockForgotPasswordUseCase,
    );

    if (sl.isRegistered<ResetPasswordUseCase>()) {
      sl.unregister<ResetPasswordUseCase>();
    }
    sl.registerLazySingleton<ResetPasswordUseCase>(
      () => mockResetPasswordUseCase,
    );

    if (sl.isRegistered<ForgotPasswordBloc>()) {
      sl.unregister<ForgotPasswordBloc>();
    }
    sl.registerFactory<ForgotPasswordBloc>(
      () => ForgotPasswordBloc(
        forgotPasswordUseCase: mockForgotPasswordUseCase,
      ),
    );

    if (sl.isRegistered<ResetPasswordBloc>()) {
      sl.unregister<ResetPasswordBloc>();
    }
    sl.registerFactory<ResetPasswordBloc>(
      () => ResetPasswordBloc(
        resetPasswordUseCase: mockResetPasswordUseCase,
      ),
    );
  });

  tearDown(() {
    resetDependencies();
  });

  Widget buildTestableWidget(Widget child) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return MaterialApp.router(
      locale: const Locale('bn'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('bn'),
        Locale('en'),
      ],
      routerConfig: router,
    );
  }

  group('ForgotPasswordBloc', () {
    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [ForgotPasswordLoading, ForgotPasswordSuccess] on success',
      build: () {
        when(() => mockForgotPasswordUseCase(email: any(named: 'email')))
            .thenAnswer((_) async => const Right(true));
        return ForgotPasswordBloc(
          forgotPasswordUseCase: mockForgotPasswordUseCase,
        );
      },
      act: (bloc) =>
          bloc.add(const ForgotPasswordSubmitted(email: 'test@example.com')),
      expect: () => [
        isA<ForgotPasswordLoading>(),
        isA<ForgotPasswordSuccess>(),
      ],
    );

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [ForgotPasswordLoading, ForgotPasswordFailure] on failure',
      build: () {
        when(() => mockForgotPasswordUseCase(email: any(named: 'email')))
            .thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error', messageKey: 'error_server')),
        );
        return ForgotPasswordBloc(
          forgotPasswordUseCase: mockForgotPasswordUseCase,
        );
      },
      act: (bloc) =>
          bloc.add(const ForgotPasswordSubmitted(email: 'test@example.com')),
      expect: () => [
        isA<ForgotPasswordLoading>(),
        isA<ForgotPasswordFailure>(),
      ],
    );
  });

  group('ResetPasswordBloc', () {
    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'emits [ResetPasswordLoading, ResetPasswordSuccess] on success',
      build: () {
        when(
          () => mockResetPasswordUseCase(
            token: any(named: 'token'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => const Right(null));
        return ResetPasswordBloc(
          resetPasswordUseCase: mockResetPasswordUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const ResetPasswordSubmitted(
          token: 'token123',
          newPassword: 'newSecret456',
        ),
      ),
      expect: () => [
        isA<ResetPasswordLoading>(),
        isA<ResetPasswordSuccess>(),
      ],
    );

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'emits [ResetPasswordLoading, ResetPasswordFailure] on failure',
      build: () {
        when(
          () => mockResetPasswordUseCase(
            token: any(named: 'token'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(ValidationFailure(message: 'Invalid token', messageKey: 'error_reset_token_invalid')),
        );
        return ResetPasswordBloc(
          resetPasswordUseCase: mockResetPasswordUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const ResetPasswordSubmitted(
          token: 'expired_token',
          newPassword: 'newSecret456',
        ),
      ),
      expect: () => [
        isA<ResetPasswordLoading>(),
        isA<ResetPasswordFailure>(),
      ],
    );
  });

  group('ForgotPasswordPage Widget Tests', () {
    testWidgets('renders email field and submit button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ForgotPasswordPage()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);
      expect(find.byKey(const Key('forgot_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('forgot_back_button')), findsOneWidget);
    });

    testWidgets('validation prevents submission on empty or invalid email',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ForgotPasswordPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('forgot_submit_button')));
      await tester.pumpAndSettle();

      verifyNever(
        () => mockForgotPasswordUseCase(email: any(named: 'email')),
      );
    });

    testWidgets('submits email and shows success message on valid submission',
        (tester) async {
      when(() => mockForgotPasswordUseCase(email: any(named: 'email')))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(buildTestableWidget(const ForgotPasswordPage()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'user@example.com',
      );
      await tester.tap(find.byKey(const Key('forgot_submit_button')));
      await tester.pumpAndSettle();

      verify(
        () => mockForgotPasswordUseCase(email: 'user@example.com'),
      ).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('ResetPasswordPage Widget Tests', () {
    testWidgets('renders token and password fields and submit button',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ResetPasswordPage()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reset_token_field')), findsOneWidget);
      expect(find.byKey(const Key('reset_password_field')), findsOneWidget);
      expect(
        find.byKey(const Key('reset_confirm_password_field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('reset_submit_button')), findsOneWidget);
    });

    testWidgets('populates initialToken from constructor', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const ResetPasswordPage(initialToken: 'sample_token_xyz')),
      );
      await tester.pumpAndSettle();

      expect(find.text('sample_token_xyz'), findsOneWidget);
    });

    testWidgets('submits token and new password and shows success on valid input',
        (tester) async {
      when(
        () => mockResetPasswordUseCase(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(
        buildTestableWidget(
          const ResetPasswordPage(initialToken: 'valid_token_123'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reset_password_field')),
        'newPassword123',
      );
      await tester.enterText(
        find.byKey(const Key('reset_confirm_password_field')),
        'newPassword123',
      );

      final submitBtn = find.byKey(const Key('reset_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      verify(
        () => mockResetPasswordUseCase(
          token: 'valid_token_123',
          newPassword: 'newPassword123',
        ),
      ).called(1);
    });
  });
}
