import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, RegistrationResultEntity>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? listerType,
  }) {
    return _repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
      listerType: listerType,
    );
  }
}
