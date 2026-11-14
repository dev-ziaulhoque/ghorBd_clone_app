import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    super.emailVerified,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as String? ?? '15m',
      emailVerified: json['emailVerified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      if (emailVerified != null) 'emailVerified': emailVerified,
    };
  }
}

class RegistrationResultModel extends RegistrationResultEntity {
  const RegistrationResultModel({
    required super.user,
    required super.email,
    required super.emailOtpRequired,
    super.devEmailOtp,
  });

  factory RegistrationResultModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final verificationJson = json['verification'] as Map<String, dynamic>? ?? {};

    return RegistrationResultModel(
      user: UserModel.fromJson(userJson),
      email: verificationJson['email'] as String? ?? (userJson['email'] as String? ?? ''),
      emailOtpRequired: verificationJson['emailOtpRequired'] as bool? ?? true,
      devEmailOtp: verificationJson['devEmailOtp'] as String?,
    );
  }
}
