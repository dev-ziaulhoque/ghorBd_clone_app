import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/core/security/secure_storage.dart';
import 'package:ghorbad_clone_app/core/security/session_manager.dart';
import 'package:ghorbad_clone_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/auth/data/datasources/google_sign_in_data_source.dart';
import 'package:ghorbad_clone_app/features/auth/data/models/auth_response_model.dart';
import 'package:ghorbad_clone_app/features/auth/data/models/user_model.dart';
import 'package:ghorbad_clone_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/security/secure_storage_test.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late FakeFlutterSecureStorage fakeStorage;
  late AppSecureStorage secureStorage;
  late SessionManager sessionManager;
  late AuthRepositoryImpl repository;

  final testUser = UserModel.fromJson({
    'id': '665f1c2e9b1d4a0012ab34cd',
    'name': 'Rahim Uddin',
    'email': 'rahim@example.com',
    'phone': '+8801711000000',
    'role': 'owner',
    'listerType': 'owner',
    'verified': true,
    'emailVerifiedAt': '2026-10-01T08:00:00.000Z',
    'isOwner': true,
    'isAdmin': false,
  });

  final testSession = AuthSessionModel(
    user: testUser,
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
    expiresIn: '15m',
    emailVerified: true,
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    fakeStorage = FakeFlutterSecureStorage();
    secureStorage = AppSecureStorage(storage: fakeStorage);
    sessionManager = SessionManager(secureStorage: secureStorage);

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      secureStorage: secureStorage,
      sessionManager: sessionManager,
    );
  });

  group('AuthRepositoryImpl', () {
    test('login returns AuthSessionEntity and saves tokens on success', () async {
      when(() => mockRemoteDataSource.login(
            email: 'rahim@example.com',
            password: 'secret123',
          )).thenAnswer((_) async => testSession);

      final result = await repository.login(
        email: 'rahim@example.com',
        password: 'secret123',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (session) {
          expect(session.user.id, '665f1c2e9b1d4a0012ab34cd');
          expect(session.accessToken, 'test_access_token');
          expect(session.refreshToken, 'test_refresh_token');
        },
      );

      // Verify tokens stored
      expect(await secureStorage.getAccessToken(), 'test_access_token');
      expect(await secureStorage.getRefreshToken(), 'test_refresh_token');
      expect(sessionManager.currentStatus, SessionStatus.authenticated);
    });

    test('login maps 401 INVALID_CREDENTIALS to UnauthorizedFailure', () async {
      when(() => mockRemoteDataSource.login(
            email: 'wrong@example.com',
            password: 'badpassword',
          )).thenThrow(
        const ApiException(
          message: 'Incorrect email or password',
          code: 'INVALID_CREDENTIALS',
          statusCode: 401,
        ),
      );

      final result = await repository.login(
        email: 'wrong@example.com',
        password: 'badpassword',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<UnauthorizedFailure>());
          expect(failure.code, 'INVALID_CREDENTIALS');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('login maps 403 EMAIL_NOT_VERIFIED to ForbiddenFailure', () async {
      when(() => mockRemoteDataSource.login(
            email: 'unverified@example.com',
            password: 'password',
          )).thenThrow(
        const ApiException(
          message: 'Email not verified',
          code: 'EMAIL_NOT_VERIFIED',
          statusCode: 403,
        ),
      );

      final result = await repository.login(
        email: 'unverified@example.com',
        password: 'password',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ForbiddenFailure>());
          expect(failure.code, 'EMAIL_NOT_VERIFIED');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('register returns RegistrationResultEntity on success', () async {
      final regResult = RegistrationResultModel(
        user: testUser,
        email: 'rahim@example.com',
        emailOtpRequired: true,
        devEmailOtp: '482913',
      );

      when(() => mockRemoteDataSource.register(
            name: 'Rahim Uddin',
            email: 'rahim@example.com',
            phone: '+8801711000000',
            password: 'secret123',
            role: 'owner',
            listerType: 'owner',
          )).thenAnswer((_) async => regResult);

      final result = await repository.register(
        name: 'Rahim Uddin',
        email: 'rahim@example.com',
        phone: '+8801711000000',
        password: 'secret123',
        role: 'owner',
        listerType: 'owner',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (data) {
          expect(data.email, 'rahim@example.com');
          expect(data.emailOtpRequired, isTrue);
          expect(data.devEmailOtp, '482913');
        },
      );
    });

    test('verifyEmailOtp persists session and returns AuthSessionEntity', () async {
      when(() => mockRemoteDataSource.verifyEmailOtp(
            email: 'rahim@example.com',
            otp: '482913',
          )).thenAnswer((_) async => testSession);

      final result = await repository.verifyEmailOtp(
        email: 'rahim@example.com',
        otp: '482913',
      );

      expect(result.isRight(), isTrue);
      expect(await secureStorage.getAccessToken(), 'test_access_token');
      expect(sessionManager.currentStatus, SessionStatus.authenticated);
    });

    test('logout clears secure storage and resets session status', () async {
      await secureStorage.saveTokens(
        accessToken: 'old_access',
        refreshToken: 'old_refresh',
      );
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(await secureStorage.getAccessToken(), isNull);
      expect(await secureStorage.getRefreshToken(), isNull);
      expect(sessionManager.currentStatus, SessionStatus.unauthenticated);
    });

    test('getCurrentUser returns user entity from remote', () async {
      when(() => mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => testUser);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (user) => expect(user?.id, '665f1c2e9b1d4a0012ab34cd'),
      );
    });
    test('loginWithGoogle fails gracefully when no Google datasource is wired', () async {
      final result = await repository.loginWithGoogle();
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.code, 'GOOGLE_UNAVAILABLE'),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('loginWithGoogle maps a cancelled Google flow to GOOGLE_CANCELLED', () async {
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        secureStorage: secureStorage,
        sessionManager: sessionManager,
        googleSignInDataSource: _CancelledGoogleDataSource(),
      );
      final result = await repo.loginWithGoogle();
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.code, 'GOOGLE_CANCELLED'),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('loginWithGoogle maps a missing backend endpoint (404) to GOOGLE_UNAVAILABLE', () async {
      when(() => mockRemoteDataSource.loginWithGoogle(idToken: 'token-123'))
          .thenThrow(const ServerException('Not Found', 404));
      final repo = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        secureStorage: secureStorage,
        sessionManager: sessionManager,
        googleSignInDataSource: _FakeGoogleDataSource(),
      );
      final result = await repo.loginWithGoogle();
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.code, 'GOOGLE_UNAVAILABLE'),
        (_) => fail('Expected Left but got Right'),
      );
    });

  });
}

class _FakeGoogleDataSource implements GoogleSignInDataSource {
  @override
  Future<String> getIdToken() async => 'token-123';
}

class _CancelledGoogleDataSource implements GoogleSignInDataSource {
  @override
  Future<String> getIdToken() async =>
      throw const GoogleSignInCancelledException();
}
