import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String? listerType;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.listerType,
  });

  @override
  List<Object?> get props => [name, email, phone, password, role, listerType];
}

/// User tapped "Continue with Google" on the register screen.
class GoogleSignInRequested extends RegisterEvent {
  const GoogleSignInRequested();
}

class VerifyOtpSubmitted extends RegisterEvent {
  final String email;
  final String otp;

  const VerifyOtpSubmitted({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ResendOtpRequested extends RegisterEvent {
  final String email;

  const ResendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
