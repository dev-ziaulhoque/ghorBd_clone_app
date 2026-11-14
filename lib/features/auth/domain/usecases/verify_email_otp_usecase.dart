import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  final AuthRepository _repository;

  VerifyEmailOtpUseCase(this._repository);

  Future<Either<Failure, AuthSessionEntity>> call({
    required String email,
    required String otp,
  }) {
    return _repository.verifyEmailOtp(email: email, otp: otp);
  }
}
