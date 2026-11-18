import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a Google sign-in with the backend for an app session.
/// Fails gracefully (never fakes success) when the backend has no
/// `/auth/google` endpoint yet.
class LoginWithGoogleUseCase {
  final AuthRepository _repository;

  LoginWithGoogleUseCase(this._repository);

  Future<Either<Failure, AuthSessionEntity>> call() {
    return _repository.loginWithGoogle();
  }
}
