import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendEmailOtpUseCase {
  final AuthRepository _repository;

  ResendEmailOtpUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String email,
  }) {
    return _repository.resendEmailOtp(email: email);
  }
}
