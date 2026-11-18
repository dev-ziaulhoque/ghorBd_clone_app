import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_event.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_state.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState>
    implements RegisterBloc {}

Widget _buildTestableVerifyOtpPage({
  required RegisterBloc registerBloc,
  required String email,
  String? devOtp,
}) {
  return MaterialApp(
    locale: const Locale('bn'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<RegisterBloc>.value(
      value: registerBloc,
      child: VerifyOtpPage(email: email, devOtp: devOtp),
    ),
  );
}

void main() {
  late MockRegisterBloc mockRegisterBloc;

  setUp(() {
    mockRegisterBloc = MockRegisterBloc();
    when(() => mockRegisterBloc.state).thenReturn(const RegisterInitial());
    when(() => mockRegisterBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('VerifyOtpPage Widget Tests', () {
    testWidgets('renders email, OTP field, verify button and resend option', (tester) async {
      when(() => mockRegisterBloc.state).thenReturn(const RegisterInitial());

      await tester.pumpWidget(_buildTestableVerifyOtpPage(
        registerBloc: mockRegisterBloc,
        email: 'user@example.com',
      ));
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('ওটিপি (OTP)'), findsOneWidget);
      expect(find.text('যাচাই করুন'), findsWidgets);
      expect(find.text('পুনরায় ওটিপি পাঠান'), findsOneWidget);
    });

    testWidgets('submits OTP on button tap', (tester) async {
      when(() => mockRegisterBloc.state).thenReturn(const RegisterInitial());

      await tester.pumpWidget(_buildTestableVerifyOtpPage(
        registerBloc: mockRegisterBloc,
        email: 'user@example.com',
        devOtp: '123456',
      ));
      await tester.pumpAndSettle();

      // The user types the code themselves (dev OTP is never prefilled)
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.pump();

      final verifyButton = find.widgetWithText(ElevatedButton, 'যাচাই করুন');
      await tester.tap(verifyButton);
      await tester.pump();

      verify(() => mockRegisterBloc.add(
            const VerifyOtpSubmitted(email: 'user@example.com', otp: '123456'),
          )).called(1);
    });

    testWidgets('does NOT prefill the backend dev OTP (production safety)', (tester) async {
      when(() => mockRegisterBloc.state).thenReturn(const RegisterInitial());

      await tester.pumpWidget(_buildTestableVerifyOtpPage(
        registerBloc: mockRegisterBloc,
        email: 'user@example.com',
        devOtp: '123456',
      ));
      await tester.pumpAndSettle();

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller?.text ?? '', isEmpty);
    });

    testWidgets('resend button fires ResendOtpRequested', (tester) async {
      when(() => mockRegisterBloc.state).thenReturn(const RegisterInitial());

      await tester.pumpWidget(_buildTestableVerifyOtpPage(
        registerBloc: mockRegisterBloc,
        email: 'user@example.com',
      ));
      await tester.pumpAndSettle();

      final resendButton = find.text('পুনরায় ওটিপি পাঠান');
      await tester.tap(resendButton);
      await tester.pump();

      verify(() => mockRegisterBloc.add(
            const ResendOtpRequested(email: 'user@example.com'),
          )).called(1);
    });

    testWidgets('shows SnackBar on OtpVerificationFailure', (tester) async {
      whenListen(
        mockRegisterBloc,
        Stream.fromIterable([
          const RegisterInitial(),
          const OtpVerificationFailure(
            message: 'ভুল ওটিপি (OTP) কোড।',
            messageKey: 'error_email_otp_invalid',
            email: 'user@example.com',
          ),
        ]),
        initialState: const RegisterInitial(),
      );

      await tester.pumpWidget(_buildTestableVerifyOtpPage(
        registerBloc: mockRegisterBloc,
        email: 'user@example.com',
      ));
      await tester.pump();

      expect(find.text('ভুল ওটিপি (OTP) কোড।'), findsOneWidget);
    });
  });
}
