import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AuthState {
  final String message;
  final String messageKey;
  final String? code;

  const AuthFailure({
    required this.message,
    required this.messageKey,
    this.code,
  });

  @override
  List<Object?> get props => [message, messageKey, code];
}

/// Emitted on 403 EMAIL_NOT_VERIFIED so UI can transition immediately to the OTP verification screen.
/// Traceability: REQ-023 | API-010 error handling
class AuthOtpRequiredState extends AuthState {
  final String email;

  const AuthOtpRequiredState({required this.email});

  @override
  List<Object?> get props => [email];
}
