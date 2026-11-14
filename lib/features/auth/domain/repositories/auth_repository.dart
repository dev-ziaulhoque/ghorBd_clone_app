import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';
import '../entities/user_entity.dart';

/// Contract for Authentication operations.
/// Traceability: REQ-023, REQ-024 | SCR-010, SCR-011 | API-005 to API-016
abstract class AuthRepository {
  Future<Either<Failure, RegistrationResultEntity>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? listerType,
  });

  Future<Either<Failure, AuthSessionEntity>> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, bool>> resendEmailOtp({
    required String email,
  });

  Future<Either<Failure, AuthSessionEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, bool>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
}
