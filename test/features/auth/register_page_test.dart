import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_event.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_state.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/register_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState>
    implements RegisterBloc {}

Widget _buildTestableRegisterPage({required RegisterBloc registerBloc}) {
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
      child: const RegisterPage(),
    ),
  );
}

void main() {
  late MockRegisterBloc mockRegisterBloc;

  setUpAll(() {
    registerFallbackValue(const ResendOtpRequested(email: 'fallback@example.com'));
    registerFallbackValue(const RegisterSubmitted(
      name: 'Fallback',
      email: 'fallback@example.com',
      phone: '01711000000',
      password: 'password1',
      role: 'tenant',
    ));
  });

  setUp(() {
    mockRegisterBloc = MockRegisterBloc();
    when(() => mockRegisterBloc.state).thenReturn(const RegisterInitial());
    when(() => mockRegisterBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('RegisterPage Widget Tests', () {
    testWidgets('renders all registration fields and role choices', (tester) async {
      await tester.pumpWidget(_buildTestableRegisterPage(registerBloc: mockRegisterBloc));
      await tester.pumpAndSettle();

      expect(find.text('রেজিস্ট্রেশন'), findsWidgets);
      expect(find.text('পুরো নাম *'), findsOneWidget);
      expect(find.text('ইমেইল *'), findsOneWidget);
      expect(find.text('মোবাইল নম্বর *'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড *'), findsOneWidget);
      // Website-style role cards
      expect(find.text('বাসা খুঁজছি'), findsOneWidget);
      expect(find.text('আমার বাসা/সম্পত্তি ভাড়া দিতে চাই'), findsOneWidget);
      // Google button first, like the website
      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      expect(find.text('গুগল দিয়ে চালিয়ে যান'), findsOneWidget);
      expect(find.text('অথবা'), findsOneWidget);
    });

    testWidgets('owner card reveals the "আপনি কে?" lister selector', (tester) async {
      await tester.pumpWidget(_buildTestableRegisterPage(registerBloc: mockRegisterBloc));
      await tester.pumpAndSettle();

      // Hidden while the tenant card is selected
      expect(find.byKey(const Key('register_lister_type_selector')), findsNothing);

      await tester.tap(find.byKey(const Key('register_role_owner_card')));
      await tester.pumpAndSettle();

      expect(find.text('আপনি কে?'), findsOneWidget);
      expect(find.byKey(const Key('register_lister_type_selector')), findsOneWidget);
      expect(find.text('মালিক'), findsOneWidget);
      expect(find.text('এজেন্ট'), findsOneWidget);
      expect(find.text('ডেভেলপার/কোম্পানি'), findsOneWidget);
      // The website's 4th option has no backend value and must not appear
      expect(find.text('অন্যের হয়ে'), findsNothing);
    });

    testWidgets('weak password is rejected by the 8+letter+digit rule', (tester) async {
      await tester.pumpWidget(_buildTestableRegisterPage(registerBloc: mockRegisterBloc));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Rahim Uddin');
      await tester.enterText(fields.at(1), 'rahim@example.com');
      await tester.enterText(fields.at(2), '01711000000');
      await tester.enterText(fields.at(3), '123456'); // too short, no letter
      await tester.pump();

      final registerButton = find.widgetWithText(ElevatedButton, 'রেজিস্ট্রেশন');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(
        find.text('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে এবং এতে অক্ষর ও সংখ্যা দুটোই থাকতে হবে'),
        findsWidgets,
      );
      verifyNever(() => mockRegisterBloc.add(any(that: isA<RegisterSubmitted>())));
    });

    testWidgets('validation prevents empty submission', (tester) async {
      await tester.pumpWidget(_buildTestableRegisterPage(registerBloc: mockRegisterBloc));
      await tester.pumpAndSettle();

      final registerButton = find.widgetWithText(ElevatedButton, 'রেজিস্ট্রেশন');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Field-specific validation messages (no generic error any more)
      expect(find.text('পুরো নাম লিখুন'), findsOneWidget);
      expect(find.text('ইমেইল লিখুন'), findsOneWidget);
      expect(find.text('মোবাইল নম্বর লিখুন'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড লিখুন'), findsOneWidget);
      verifyNever(() => mockRegisterBloc.add(any()));
    });

    testWidgets('shows SnackBar on RegisterFailure', (tester) async {
      whenListen(
        mockRegisterBloc,
        Stream.fromIterable([
          const RegisterFailure(
            message: 'এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট খোলা আছে।',
            messageKey: 'error_account_exists',
          ),
        ]),
        initialState: const RegisterInitial(),
      );

      await tester.pumpWidget(_buildTestableRegisterPage(registerBloc: mockRegisterBloc));
      await tester.pump();

      expect(find.text('এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট খোলা আছে।'), findsOneWidget);
    });
  });
}
