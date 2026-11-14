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
      expect(find.text('নাম'), findsOneWidget);
      expect(find.text('ইমেইল'), findsOneWidget);
      expect(find.text('ফোন নম্বর'), findsOneWidget);
      expect(find.text('পাসওয়ার্ড'), findsOneWidget);
      expect(find.text('ভাড়াটিয়া / ক্রেতা'), findsOneWidget);
      expect(find.text('মালিক / লিস্টার'), findsOneWidget);
    });

    testWidgets('validation prevents empty submission', (tester) async {
      await tester.pumpWidget(_buildTestableRegisterPage(registerBloc: mockRegisterBloc));
      await tester.pumpAndSettle();

      final registerButton = find.widgetWithText(ElevatedButton, 'রেজিস্ট্রেশন');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('প্রদত্ত তথ্য সঠিক নয়। অনুগ্রহ করে সংশোধন করুন।'), findsWidgets);
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
