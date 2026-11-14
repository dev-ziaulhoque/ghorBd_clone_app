import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String token,
    required String newPassword,
  }) {
    return _repository.resetPassword(token: token, newPassword: newPassword);
  }
}
