import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/features/auth/domain/entities/auth_session_entity.dart';
import 'package:ghorbad_clone_app/features/auth/domain/entities/user_entity.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/resend_email_otp_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/verify_email_otp_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_event.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockVerifyEmailOtpUseCase extends Mock implements VerifyEmailOtpUseCase {}
class MockResendEmailOtpUseCase extends Mock implements ResendEmailOtpUseCase {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late MockVerifyEmailOtpUseCase mockVerifyEmailOtpUseCase;
  late MockResendEmailOtpUseCase mockResendEmailOtpUseCase;

  const testUser = UserEntity(
    id: 'user_456',
    name: 'Karim',
    email: 'karim@example.com',
    role: 'owner',
    verified: false,
  );

  const testRegResult = RegistrationResultEntity(
    user: testUser,
    email: 'karim@example.com',
    emailOtpRequired: true,
    devEmailOtp: '123456',
  );

  const testSession = AuthSessionEntity(
    user: testUser,
    accessToken: 'access_abc',
    refreshToken: 'refresh_xyz',
    expiresIn: '15m',
    emailVerified: true,
  );

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockVerifyEmailOtpUseCase = MockVerifyEmailOtpUseCase();
    mockResendEmailOtpUseCase = MockResendEmailOtpUseCase();
  });

  group('RegisterBloc', () {
    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterLoading, RegisterOtpSent] on successful registration',
      build: () {
        when(() => mockRegisterUseCase(
              name: 'Karim',
              email: 'karim@example.com',
              phone: '01711000000',
              password: 'password',
              role: 'owner',
              listerType: 'owner',
            )).thenAnswer((_) async => const Right(testRegResult));
        return RegisterBloc(
          registerUseCase: mockRegisterUseCase,
          verifyEmailOtpUseCase: mockVerifyEmailOtpUseCase,
          resendEmailOtpUseCase: mockResendEmailOtpUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const RegisterSubmitted(
          name: 'Karim',
          email: 'karim@example.com',
          phone: '01711000000',
          password: 'password',
          role: 'owner',
          listerType: 'owner',
        ),
      ),
      expect: () => [
        const RegisterLoading(),
        const RegisterOtpSent(email: 'karim@example.com', devEmailOtp: '123456'),
      ],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterLoading, RegisterFailure] when registration fails (account exists)',
      build: () {
        when(() => mockRegisterUseCase(
              name: 'Karim',
              email: 'karim@example.com',
              phone: '01711000000',
              password: 'password',
              role: 'owner',
            )).thenAnswer(
          (_) async => const Left(
            ConflictFailure(
              message: 'Account already exists',
              code: 'ACCOUNT_EXISTS',
            ),
          ),
        );
        return RegisterBloc(
          registerUseCase: mockRegisterUseCase,
          verifyEmailOtpUseCase: mockVerifyEmailOtpUseCase,
          resendEmailOtpUseCase: mockResendEmailOtpUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const RegisterSubmitted(
          name: 'Karim',
          email: 'karim@example.com',
          phone: '01711000000',
          password: 'password',
          role: 'owner',
        ),
      ),
      expect: () => [
        const RegisterLoading(),
        const RegisterFailure(
          message: 'Account already exists',
          messageKey: 'error_conflict',
          code: 'ACCOUNT_EXISTS',
        ),
      ],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterLoading, RegisterSuccess] on valid OTP verification',
      build: () {
        when(() => mockVerifyEmailOtpUseCase(
              email: 'karim@example.com',
              otp: '123456',
            )).thenAnswer((_) async => const Right(testSession));
        return RegisterBloc(
          registerUseCase: mockRegisterUseCase,
          verifyEmailOtpUseCase: mockVerifyEmailOtpUseCase,
          resendEmailOtpUseCase: mockResendEmailOtpUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const VerifyOtpSubmitted(email: 'karim@example.com', otp: '123456'),
      ),
      expect: () => [
        const RegisterLoading(),
        const RegisterSuccess(testUser),
      ],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [RegisterLoading, OtpVerificationFailure] on invalid OTP',
      build: () {
        when(() => mockVerifyEmailOtpUseCase(
              email: 'karim@example.com',
              otp: '000000',
            )).thenAnswer(
          (_) async => const Left(
            ValidationFailure(
              message: 'Invalid OTP',
              code: 'EMAIL_OTP_INVALID',
            ),
          ),
        );
        return RegisterBloc(
          registerUseCase: mockRegisterUseCase,
          verifyEmailOtpUseCase: mockVerifyEmailOtpUseCase,
          resendEmailOtpUseCase: mockResendEmailOtpUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const VerifyOtpSubmitted(email: 'karim@example.com', otp: '000000'),
      ),
      expect: () => [
        const RegisterLoading(),
        const OtpVerificationFailure(
          message: 'Invalid OTP',
          messageKey: 'error_validation',
          code: 'EMAIL_OTP_INVALID',
          email: 'karim@example.com',
        ),
      ],
    );
  });
}
