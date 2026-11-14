import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart' hide AuthFailure;
import 'package:ghorbad_clone_app/core/security/secure_storage.dart';
import 'package:ghorbad_clone_app/core/security/session_manager.dart';
import 'package:ghorbad_clone_app/features/auth/domain/entities/auth_session_entity.dart';
import 'package:ghorbad_clone_app/features/auth/domain/entities/user_entity.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/security/secure_storage_test.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late FakeFlutterSecureStorage fakeStorage;
  late SessionManager sessionManager;

  const testUser = UserEntity(
    id: 'user_123',
    name: 'Rahim Uddin',
    email: 'rahim@example.com',
    role: 'owner',
    verified: true,
  );

  const testSession = AuthSessionEntity(
    user: testUser,
    accessToken: 'access_123',
    refreshToken: 'refresh_123',
    expiresIn: '15m',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    fakeStorage = FakeFlutterSecureStorage();
    sessionManager = SessionManager(
      secureStorage: AppSecureStorage(storage: fakeStorage),
    );
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when AuthCheckRequested finds active user',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Right(testUser),
        );
        return AuthBloc(
          loginUseCase: mockLoginUseCase,
          logoutUseCase: mockLogoutUseCase,
          getCurrentUserUseCase: mockGetCurrentUserUseCase,
          sessionManager: sessionManager,
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when AuthCheckRequested finds no user',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Right(null),
        );
        return AuthBloc(
          loginUseCase: mockLoginUseCase,
          logoutUseCase: mockLogoutUseCase,
          getCurrentUserUseCase: mockGetCurrentUserUseCase,
          sessionManager: sessionManager,
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful AuthLoginRequested',
      build: () {
        when(() => mockLoginUseCase(
              email: 'rahim@example.com',
              password: 'password123',
            )).thenAnswer((_) async => const Right(testSession));
        return AuthBloc(
          loginUseCase: mockLoginUseCase,
          logoutUseCase: mockLogoutUseCase,
          getCurrentUserUseCase: mockGetCurrentUserUseCase,
          sessionManager: sessionManager,
        );
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'rahim@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthOtpRequiredState] when login fails with EMAIL_NOT_VERIFIED',
      build: () {
        when(() => mockLoginUseCase(
              email: 'unverified@example.com',
              password: 'password123',
            )).thenAnswer(
          (_) async => const Left(
            ForbiddenFailure(
              message: 'Email not verified',
              code: 'EMAIL_NOT_VERIFIED',
            ),
          ),
        );
        return AuthBloc(
          loginUseCase: mockLoginUseCase,
          logoutUseCase: mockLogoutUseCase,
          getCurrentUserUseCase: mockGetCurrentUserUseCase,
          sessionManager: sessionManager,
        );
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'unverified@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthOtpRequiredState(email: 'unverified@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on invalid credentials',
      build: () {
        when(() => mockLoginUseCase(
              email: 'wrong@example.com',
              password: 'wrong',
            )).thenAnswer(
          (_) async => const Left(
            UnauthorizedFailure(
              message: 'Incorrect email or password',
              messageKey: 'error_invalid_credentials',
              code: 'INVALID_CREDENTIALS',
            ),
          ),
        );
        return AuthBloc(
          loginUseCase: mockLoginUseCase,
          logoutUseCase: mockLogoutUseCase,
          getCurrentUserUseCase: mockGetCurrentUserUseCase,
          sessionManager: sessionManager,
        );
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'wrong@example.com',
          password: 'wrong',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(
          message: 'Incorrect email or password',
          messageKey: 'error_invalid_credentials',
          code: 'INVALID_CREDENTIALS',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on AuthLogoutRequested',
      build: () {
        when(() => mockLogoutUseCase()).thenAnswer(
          (_) async => const Right(null),
        );
        return AuthBloc(
          loginUseCase: mockLoginUseCase,
          logoutUseCase: mockLogoutUseCase,
          getCurrentUserUseCase: mockGetCurrentUserUseCase,
          sessionManager: sessionManager,
        );
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });
}
