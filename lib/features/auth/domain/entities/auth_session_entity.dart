import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Represents an active authenticated session with JWT tokens.
/// Traceability: REQ-023 | API-006, API-010, API-011
class AuthSessionEntity extends Equatable {
  final UserEntity user;
  final String accessToken;
  final String refreshToken;
  final String expiresIn;
  final bool? emailVerified;

  const AuthSessionEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.emailVerified,
  });

  @override
  List<Object?> get props => [user, accessToken, refreshToken, expiresIn, emailVerified];
}

/// Represents the response from registration (when OTP verification is required).
/// Traceability: REQ-024 | API-005
class RegistrationResultEntity extends Equatable {
  final UserEntity user;
  final String email;
  final bool emailOtpRequired;
  final String? devEmailOtp;

  const RegistrationResultEntity({
    required this.user,
    required this.email,
    required this.emailOtpRequired,
    this.devEmailOtp,
  });

  @override
  List<Object?> get props => [user, email, emailOtpRequired, devEmailOtp];
}
