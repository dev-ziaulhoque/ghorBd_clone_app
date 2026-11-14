import 'package:equatable/equatable.dart';
import 'exceptions.dart';

abstract class Failure extends Equatable {
  final String message;
  final String messageKey;
  final String? code;

  const Failure({
    required this.message,
    required this.messageKey,
    this.code,
  });

  @override
  List<Object?> get props => [message, messageKey, code];

  static Failure fromApiCode({
    required String code,
    required String message,
    int? statusCode,
    List<ApiErrorDetail> details = const [],
    int? retryAfterSeconds,
  }) {
    final upperCode = code.toUpperCase().trim();

    // 1. Validation (422 and 400 validation-like codes)
    if (statusCode == 422 || upperCode == 'VALIDATION_ERROR') {
      return ValidationFailure(
        message: message,
        messageKey: 'error_validation',
        code: code,
        details: details,
      );
    }

    switch (upperCode) {
      // 400 Bad Request specifics from API_AUDIT.md
      case 'INVALID_ID':
        return ValidationFailure(
          message: message,
          messageKey: 'error_invalid_id',
          code: code,
          details: details,
        );
      case 'RESET_TOKEN_INVALID':
        return ValidationFailure(
          message: message,
          messageKey: 'error_reset_token_invalid',
          code: code,
          details: details,
        );
      case 'EMAIL_OTP_INVALID':
        return ValidationFailure(
          message: message,
          messageKey: 'error_email_otp_invalid',
          code: code,
          details: details,
        );
      case 'EMAIL_OTP_EXPIRED':
        return ValidationFailure(
          message: message,
          messageKey: 'error_email_otp_expired',
          code: code,
          details: details,
        );
      case 'DOCUMENT_LIMIT_REACHED':
        return ValidationFailure(
          message: message,
          messageKey: 'error_document_limit_reached',
          code: code,
          details: details,
        );
      case 'SELF_INQUIRY':
        return ValidationFailure(
          message: message,
          messageKey: 'error_self_inquiry',
          code: code,
          details: details,
        );
      case 'OWN_LISTING':
        return ValidationFailure(
          message: message,
          messageKey: 'error_own_listing',
          code: code,
          details: details,
        );

      // 401 Unauthorized codes from API_AUDIT.md
      case 'TOKEN_EXPIRED':
        return UnauthorizedFailure(
          message: message,
          messageKey: 'error_token_expired',
          code: code,
        );
      case 'TOKEN_INVALID':
        return UnauthorizedFailure(
          message: message,
          messageKey: 'error_token_invalid',
          code: code,
        );
      case 'INVALID_CREDENTIALS':
        return UnauthorizedFailure(
          message: message,
          messageKey: 'error_invalid_credentials',
          code: code,
        );
      case 'REFRESH_TOKEN_INVALID':
        return UnauthorizedFailure(
          message: message,
          messageKey: 'error_refresh_token_invalid',
          code: code,
        );
      case 'PASSWORD_CHANGED':
        return UnauthorizedFailure(
          message: message,
          messageKey: 'error_password_changed',
          code: code,
        );
      case 'ACCOUNT_MISSING':
        return UnauthorizedFailure(
          message: message,
          messageKey: 'error_account_missing',
          code: code,
        );
      case 'UNAUTHORIZED':
        return UnauthorizedFailure(
          message: message,
          messageKey: 'error_unauthorized',
          code: code,
        );

      // 403 Forbidden codes from API_AUDIT.md
      case 'EMAIL_NOT_VERIFIED':
        return ForbiddenFailure(
          message: message,
          messageKey: 'error_email_not_verified',
          code: code,
        );
      case 'FORBIDDEN':
        return ForbiddenFailure(
          message: message,
          messageKey: 'error_forbidden',
          code: code,
        );

      // 404 Not Found codes from API_AUDIT.md
      case 'NOT_FOUND':
        return NotFoundFailure(
          message: message,
          messageKey: 'error_not_found',
          code: code,
        );
      case 'NO_CONTACT_PHONE':
        return NotFoundFailure(
          message: message,
          messageKey: 'error_no_contact_phone',
          code: code,
        );
      case 'QUESTION_NOT_FOUND':
        return NotFoundFailure(
          message: message,
          messageKey: 'error_question_not_found',
          code: code,
        );

      // 409 Conflict codes from API_AUDIT.md
      case 'ACCOUNT_EXISTS':
        return ConflictFailure(
          message: message,
          messageKey: 'error_account_exists',
          code: code,
        );
      case 'DUPLICATE_LISTING':
        return ConflictFailure(
          message: message,
          messageKey: 'error_duplicate_listing',
          code: code,
        );
      case 'INVALID_TRANSITION':
        return ConflictFailure(
          message: message,
          messageKey: 'error_invalid_transition',
          code: code,
        );
      case 'ALREADY_REPORTED':
        return ConflictFailure(
          message: message,
          messageKey: 'error_already_reported',
          code: code,
        );
      case 'AREA_IN_USE':
        return ConflictFailure(
          message: message,
          messageKey: 'error_area_in_use',
          code: code,
        );

      // 413 Payload Too Large from API_AUDIT.md
      case 'FILE_TOO_LARGE':
        return PayloadTooLargeFailure(
          message: message,
          messageKey: 'error_file_too_large',
          code: code,
        );

      // 429 Rate Limit from API_AUDIT.md
      case 'TOO_MANY_REQUESTS':
        return RateLimitFailure(
          message: message,
          messageKey: 'error_rate_limit',
          code: code,
          retryAfterSeconds: retryAfterSeconds,
        );
      case 'EMAIL_OTP_ATTEMPTS':
        return RateLimitFailure(
          message: message,
          messageKey: 'error_email_otp_attempts',
          code: code,
          retryAfterSeconds: retryAfterSeconds,
        );

      // 500 Server errors from API_AUDIT.md
      case 'GEOCODER_UNAVAILABLE':
        return ServerFailure(
          message: message,
          messageKey: 'error_geocoder_unavailable',
          code: code,
          statusCode: statusCode ?? 500,
          details: details,
        );
    }

    // Status code fallbacks
    if (statusCode == 401) {
      return UnauthorizedFailure(
        message: message,
        messageKey: 'error_unauthorized',
        code: code,
      );
    }
    if (statusCode == 403) {
      return ForbiddenFailure(
        message: message,
        messageKey: 'error_forbidden',
        code: code,
      );
    }
    if (statusCode == 404) {
      return NotFoundFailure(
        message: message,
        messageKey: 'error_not_found',
        code: code,
      );
    }
    if (statusCode == 409) {
      return ConflictFailure(
        message: message,
        messageKey: 'error_conflict',
        code: code,
      );
    }
    if (statusCode == 413) {
      return PayloadTooLargeFailure(
        message: message,
        messageKey: 'error_file_too_large',
        code: code,
      );
    }
    if (statusCode == 429) {
      return RateLimitFailure(
        message: message,
        messageKey: 'error_rate_limit',
        code: code,
        retryAfterSeconds: retryAfterSeconds,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return ServerFailure(
        message: message,
        messageKey: 'error_server',
        code: code,
        statusCode: statusCode,
        details: details,
      );
    }

    // Default Unknown
    return UnknownFailure(
      message: message,
      messageKey: 'error_unknown',
      code: code,
    );
  }

  static Failure fromException(Object exception) {
    if (exception is Failure) return exception;

    if (exception is NetworkTimeoutException) {
      return TimeoutFailure(
        message: exception.message,
      );
    }

    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
      );
    }

    if (exception is ApiException) {
      return fromApiCode(
        code: exception.code,
        message: exception.message,
        statusCode: exception.statusCode,
        details: exception.details,
      );
    }

    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }

    return UnknownFailure(
      message: exception.toString(),
    );
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please verify your network and try again.',
    super.messageKey = 'error_network',
    super.code = 'NETWORK_ERROR',
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Connection timed out. Please try again.',
    super.messageKey = 'error_timeout',
    super.code = 'TIMEOUT_ERROR',
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    required super.message,
    super.messageKey = 'error_unauthorized',
    super.code = 'UNAUTHORIZED',
  });
}

typedef AuthFailure = UnauthorizedFailure;

class ValidationFailure extends Failure {
  final List<ApiErrorDetail> details;

  const ValidationFailure({
    required super.message,
    super.messageKey = 'error_validation',
    super.code = 'VALIDATION_ERROR',
    this.details = const [],
  });

  @override
  List<Object?> get props => [message, messageKey, code, details];
}

class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;

  const RateLimitFailure({
    required super.message,
    super.messageKey = 'error_rate_limit',
    super.code = 'TOO_MANY_REQUESTS',
    this.retryAfterSeconds,
  });

  @override
  List<Object?> get props => [message, messageKey, code, retryAfterSeconds];
}

class ServerFailure extends Failure {
  final int? statusCode;
  final List<ApiErrorDetail> details;

  const ServerFailure({
    required super.message,
    super.messageKey = 'error_server',
    super.code = 'SERVER_ERROR',
    this.statusCode,
    this.details = const [],
  });

  @override
  List<Object?> get props => [message, messageKey, code, statusCode, details];
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.messageKey = 'error_unknown',
    super.code = 'UNKNOWN_ERROR',
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    required super.message,
    super.messageKey = 'error_forbidden',
    super.code = 'FORBIDDEN',
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.messageKey = 'error_not_found',
    super.code = 'NOT_FOUND',
  });
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    required super.message,
    super.messageKey = 'error_conflict',
    super.code = 'CONFLICT',
  });
}

class PayloadTooLargeFailure extends Failure {
  const PayloadTooLargeFailure({
    required super.message,
    super.messageKey = 'error_file_too_large',
    super.code = 'FILE_TOO_LARGE',
  });
}

Failure mapApiErrorToFailure(dynamic error, {int? statusCode}) {
  if (error is Failure) return error;

  if (error is ApiException) {
    return Failure.fromApiCode(
      code: error.code,
      message: error.message,
      statusCode: error.statusCode ?? statusCode,
      details: error.details,
    );
  }

  String code = 'UNKNOWN_ERROR';
  String message = 'An unexpected error occurred';
  List<ApiErrorDetail> details = const [];

  if (error is ApiErrorDetail) {
    message = error.message;
  } else if (error is Map) {
    code = error['code']?.toString() ?? 'UNKNOWN_ERROR';
    message = error['message']?.toString() ?? 'An error occurred';
    if (error['details'] is List) {
      details = (error['details'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ApiErrorDetail.fromJson)
          .toList();
    }
  } else {
    try {
      final dynamic errObj = (error as dynamic).code;
      if (errObj != null) code = errObj.toString();
      final dynamic msgObj = (error as dynamic).message;
      if (msgObj != null) message = msgObj.toString();
      final dynamic detailsObj = (error as dynamic).details;
      if (detailsObj is List<ApiErrorDetail>) details = detailsObj;
    } catch (_) {}
  }

  return Failure.fromApiCode(
    code: code,
    message: message,
    statusCode: statusCode,
    details: details,
  );
}
