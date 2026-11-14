import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

/// Emitted after successful registration; transitions to OTP entry screen.
class RegisterOtpSent extends RegisterState {
  final String email;
  final String? devEmailOtp;

  const RegisterOtpSent({required this.email, this.devEmailOtp});

  @override
  List<Object?> get props => [email, devEmailOtp];
}

/// Emitted after successful OTP verification; user is logged in and ready.
class RegisterSuccess extends RegisterState {
  final UserEntity user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends RegisterState {
  final String message;
  final String messageKey;
  final String? code;

  const RegisterFailure({
    required this.message,
    required this.messageKey,
    this.code,
  });

  @override
  List<Object?> get props => [message, messageKey, code];
}

class OtpVerificationFailure extends RegisterState {
  final String message;
  final String messageKey;
  final String? code;
  final String email;

  const OtpVerificationFailure({
    required this.message,
    required this.messageKey,
    this.code,
    required this.email,
  });

  @override
  List<Object?> get props => [message, messageKey, code, email];
}
