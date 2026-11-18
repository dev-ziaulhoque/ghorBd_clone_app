import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/security/secure_storage.dart';
import '../../../../core/security/session_manager.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/google_sign_in_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AppSecureStorage _secureStorage;
  final SessionManager _sessionManager;
  final GoogleSignInDataSource? _googleSignInDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AppSecureStorage secureStorage,
    required SessionManager sessionManager,
    GoogleSignInDataSource? googleSignInDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage,
        _sessionManager = sessionManager,
        _googleSignInDataSource = googleSignInDataSource;

  @override
  Future<Either<Failure, RegistrationResultEntity>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? listerType,
  }) async {
    try {
      final result = await _remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
        listerType: listerType,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final session = await _remoteDataSource.verifyEmailOtp(email: email, otp: otp);

      // Persist session into secure storage & session manager
      await _sessionManager.startSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.user.id,
        userRole: session.user.role,
        userEmail: session.user.email,
        userName: session.user.name,
        userPhone: session.user.phone,
      );

      return Right(session);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resendEmailOtp({required String email}) async {
    try {
      final sent = await _remoteDataSource.resendEmailOtp(email: email);
      return Right(sent);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.login(email: email, password: password);

      // Persist session into secure storage & session manager
      await _sessionManager.startSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.user.id,
        userRole: session.user.role,
        userEmail: session.user.email,
        userName: session.user.name,
        userPhone: session.user.phone,
      );

      return Right(session);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> loginWithGoogle() async {
    final google = _googleSignInDataSource;
    if (google == null) {
      return const Left(UnknownFailure(
        message: 'Google sign-in is not available yet',
        messageKey: 'error_google_unavailable',
        code: 'GOOGLE_UNAVAILABLE',
      ));
    }
    try {
      final idToken = await google.getIdToken();
      final session = await _remoteDataSource.loginWithGoogle(
        idToken: idToken,
      );

      // Persist session into secure storage & session manager (same
      // path as email login, so the router guard works unchanged)
      await _sessionManager.startSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.user.id,
        userRole: session.user.role,
        userEmail: session.user.email,
        userName: session.user.name,
        userPhone: session.user.phone,
      );

      return Right(session);
    } on GoogleSignInCancelledException {
      return const Left(UnknownFailure(
        message: 'Google sign-in was cancelled',
        messageKey: 'error_google_cancelled',
        code: 'GOOGLE_CANCELLED',
      ));
    } on ServerException catch (e) {
      // Backend has no /auth/google endpoint yet -> graceful error,
      // never a fake success.
      if (e.statusCode == 404 || e.statusCode == 501) {
        return const Left(UnknownFailure(
          message: 'Google sign-in is not available yet',
          messageKey: 'error_google_unavailable',
          code: 'GOOGLE_UNAVAILABLE',
        ));
      }
      return Left(Failure.fromException(e));
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      try {
        await _remoteDataSource.logout();
      } catch (_) {
        // Even if the server call fails or device is offline, delete tokens locally
      }
      await _sessionManager.endSession();
      await _secureStorage.clearAll();
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword({required String email}) async {
    try {
      final sent = await _remoteDataSource.forgotPassword(email: email);
      return Right(sent);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(token: token, newPassword: newPassword);
      // Invalidate current local session if any since password was reset
      await _sessionManager.endSession();
      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
