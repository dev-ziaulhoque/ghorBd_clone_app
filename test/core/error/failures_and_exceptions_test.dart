import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';

void main() {
  group('Failures & Exceptions Contract', () {
    test('all Failure types have a non-empty messageKey for localization', () {
      const failures = <Failure>[
        NetworkFailure(),
        TimeoutFailure(),
        UnauthorizedFailure(message: 'Auth required'),
        ValidationFailure(message: 'Validation failed'),
        RateLimitFailure(message: 'Too many requests'),
        ServerFailure(message: 'Internal server error'),
        UnknownFailure(),
        ForbiddenFailure(message: 'Forbidden'),
        NotFoundFailure(message: 'Not found'),
        ConflictFailure(message: 'Conflict'),
        PayloadTooLargeFailure(message: 'Too large'),
      ];

      for (final failure in failures) {
        expect(
          failure.messageKey.isNotEmpty,
          isTrue,
          reason: '${failure.runtimeType} must have a non-empty messageKey',
        );
        expect(
          failure.messageKey.startsWith('error_'),
          isTrue,
          reason: '${failure.runtimeType} messageKey (${failure.messageKey}) should start with error_',
        );
        expect(
          failure.message.isNotEmpty,
          isTrue,
          reason: '${failure.runtimeType} must have a default human-readable message',
        );
      }
    });

    test('NetworkFailure has correct defaults', () {
      const failure = NetworkFailure();
      expect(failure.messageKey, 'error_network');
      expect(failure.code, 'NETWORK_ERROR');
      expect(failure.message, contains('internet connection'));
    });

    test('TimeoutFailure has correct defaults', () {
      const failure = TimeoutFailure();
      expect(failure.messageKey, 'error_timeout');
      expect(failure.code, 'TIMEOUT_ERROR');
      expect(failure.message, contains('timed out'));
    });

    test('UnauthorizedFailure has correct defaults and AuthFailure alias', () {
      const failure = UnauthorizedFailure(message: 'Session expired');
      expect(failure.messageKey, 'error_unauthorized');
      expect(failure.code, 'UNAUTHORIZED');
      expect(failure, isA<AuthFailure>());
    });

    test('ValidationFailure includes details and correct messageKey', () {
      const detail = ApiErrorDetail(path: 'title', message: 'Title is too short');
      const failure = ValidationFailure(
        message: 'Validation failed',
        details: [detail],
      );

      expect(failure.messageKey, 'error_validation');
      expect(failure.code, 'VALIDATION_ERROR');
      expect(failure.details, [detail]);
    });

    test('RateLimitFailure includes retryAfterSeconds and correct messageKey', () {
      const failure = RateLimitFailure(
        message: 'Rate limit exceeded',
        retryAfterSeconds: 60,
      );

      expect(failure.messageKey, 'error_rate_limit');
      expect(failure.code, 'TOO_MANY_REQUESTS');
      expect(failure.retryAfterSeconds, 60);
    });

    test('ServerFailure includes statusCode and details', () {
      const failure = ServerFailure(
        message: 'Server error',
        statusCode: 502,
      );

      expect(failure.messageKey, 'error_server');
      expect(failure.code, 'SERVER_ERROR');
      expect(failure.statusCode, 502);
    });

    test('UnknownFailure has correct defaults', () {
      const failure = UnknownFailure();
      expect(failure.messageKey, 'error_unknown');
      expect(failure.code, 'UNKNOWN_ERROR');
      expect(failure.message, contains('unexpected error'));
    });
  });

  group('API_AUDIT.md Real Error Codes to Failure Mapping', () {
    test('maps 400 Bad Request error codes to ValidationFailure with specific keys', () {
      final codeMap = {
        'INVALID_ID': 'error_invalid_id',
        'RESET_TOKEN_INVALID': 'error_reset_token_invalid',
        'EMAIL_OTP_INVALID': 'error_email_otp_invalid',
        'EMAIL_OTP_EXPIRED': 'error_email_otp_expired',
        'DOCUMENT_LIMIT_REACHED': 'error_document_limit_reached',
        'SELF_INQUIRY': 'error_self_inquiry',
        'OWN_LISTING': 'error_own_listing',
      };

      codeMap.forEach((code, expectedKey) {
        final failure = Failure.fromApiCode(
          code: code,
          message: 'Error for $code',
          statusCode: 400,
        );

        expect(failure, isA<ValidationFailure>(), reason: '$code should map to ValidationFailure');
        expect(failure.messageKey, expectedKey, reason: '$code should have messageKey $expectedKey');
        expect(failure.code, code);
      });
    });

    test('maps 401 Unauthorized error codes to UnauthorizedFailure with specific keys', () {
      final codeMap = {
        'TOKEN_EXPIRED': 'error_token_expired',
        'TOKEN_INVALID': 'error_token_invalid',
        'INVALID_CREDENTIALS': 'error_invalid_credentials',
        'REFRESH_TOKEN_INVALID': 'error_refresh_token_invalid',
        'PASSWORD_CHANGED': 'error_password_changed',
        'ACCOUNT_MISSING': 'error_account_missing',
        'UNAUTHORIZED': 'error_unauthorized',
      };

      codeMap.forEach((code, expectedKey) {
        final failure = Failure.fromApiCode(
          code: code,
          message: 'Error for $code',
          statusCode: 401,
        );

        expect(failure, isA<UnauthorizedFailure>(), reason: '$code should map to UnauthorizedFailure');
        expect(failure.messageKey, expectedKey, reason: '$code should have messageKey $expectedKey');
      });
    });

    test('maps 403 Forbidden codes to ForbiddenFailure with specific keys', () {
      final failure1 = Failure.fromApiCode(
        code: 'EMAIL_NOT_VERIFIED',
        message: 'Email not verified',
        statusCode: 403,
      );
      expect(failure1, isA<ForbiddenFailure>());
      expect(failure1.messageKey, 'error_email_not_verified');

      final failure2 = Failure.fromApiCode(
        code: 'FORBIDDEN',
        message: 'Forbidden role',
        statusCode: 403,
      );
      expect(failure2, isA<ForbiddenFailure>());
      expect(failure2.messageKey, 'error_forbidden');
    });

    test('maps 404 Not Found codes to NotFoundFailure with specific keys', () {
      final codeMap = {
        'NOT_FOUND': 'error_not_found',
        'NO_CONTACT_PHONE': 'error_no_contact_phone',
        'QUESTION_NOT_FOUND': 'error_question_not_found',
      };

      codeMap.forEach((code, expectedKey) {
        final failure = Failure.fromApiCode(
          code: code,
          message: 'Missing $code',
          statusCode: 404,
        );

        expect(failure, isA<NotFoundFailure>());
        expect(failure.messageKey, expectedKey);
      });
    });

    test('maps 409 Conflict codes to ConflictFailure with specific keys', () {
      final codeMap = {
        'ACCOUNT_EXISTS': 'error_account_exists',
        'DUPLICATE_LISTING': 'error_duplicate_listing',
        'INVALID_TRANSITION': 'error_invalid_transition',
        'ALREADY_REPORTED': 'error_already_reported',
        'AREA_IN_USE': 'error_area_in_use',
      };

      codeMap.forEach((code, expectedKey) {
        final failure = Failure.fromApiCode(
          code: code,
          message: 'Conflict $code',
          statusCode: 409,
        );

        expect(failure, isA<ConflictFailure>());
        expect(failure.messageKey, expectedKey);
      });
    });

    test('maps 413 FILE_TOO_LARGE to PayloadTooLargeFailure', () {
      final failure = Failure.fromApiCode(
        code: 'FILE_TOO_LARGE',
        message: 'File too large',
        statusCode: 413,
      );

      expect(failure, isA<PayloadTooLargeFailure>());
      expect(failure.messageKey, 'error_file_too_large');
    });

    test('maps 429 Rate Limit codes to RateLimitFailure with specific keys', () {
      final failure1 = Failure.fromApiCode(
        code: 'TOO_MANY_REQUESTS',
        message: 'Rate limited',
        statusCode: 429,
        retryAfterSeconds: 30,
      );
      expect(failure1, isA<RateLimitFailure>());
      expect(failure1.messageKey, 'error_rate_limit');
      expect((failure1 as RateLimitFailure).retryAfterSeconds, 30);

      final failure2 = Failure.fromApiCode(
        code: 'EMAIL_OTP_ATTEMPTS',
        message: 'Too many OTP attempts',
        statusCode: 429,
      );
      expect(failure2, isA<RateLimitFailure>());
      expect(failure2.messageKey, 'error_email_otp_attempts');
    });

    test('maps 500 / 502 / GEOCODER_UNAVAILABLE to ServerFailure', () {
      final geocoderFailure = Failure.fromApiCode(
        code: 'GEOCODER_UNAVAILABLE',
        message: 'Geocoder service down',
        statusCode: 500,
      );
      expect(geocoderFailure, isA<ServerFailure>());
      expect(geocoderFailure.messageKey, 'error_geocoder_unavailable');

      final genericServer = Failure.fromApiCode(
        code: 'INTERNAL_ERROR',
        message: 'Crash',
        statusCode: 502,
      );
      expect(genericServer, isA<ServerFailure>());
      expect(genericServer.messageKey, 'error_server');
    });

    test('maps unknown codes to UnknownFailure', () {
      final failure = Failure.fromApiCode(
        code: 'UNEXPECTED_CUSTOM_CODE',
        message: 'Something weird happened',
      );
      expect(failure, isA<UnknownFailure>());
      expect(failure.messageKey, 'error_unknown');
    });
  });

  group('Failure.fromException Mapping', () {
    test('maps NetworkTimeoutException to TimeoutFailure', () {
      const exception = NetworkTimeoutException('Connection timed out');
      final failure = Failure.fromException(exception);

      expect(failure, isA<TimeoutFailure>());
      expect(failure.messageKey, 'error_timeout');
      expect(failure.code, 'TIMEOUT_ERROR');
    });

    test('maps NetworkException to NetworkFailure', () {
      const exception = NetworkException('Socket failed');
      final failure = Failure.fromException(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.messageKey, 'error_network');
      expect(failure.code, 'NETWORK_ERROR');
    });

    test('maps ApiException to corresponding Failure type', () {
      const exception = ApiException(
        code: 'TOKEN_EXPIRED',
        message: 'Token has expired',
        statusCode: 401,
      );
      final failure = Failure.fromException(exception);

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.messageKey, 'error_token_expired');
      expect(failure.code, 'TOKEN_EXPIRED');
    });

    test('maps ServerException to ServerFailure', () {
      const exception = ServerException('DB failure', 500);
      final failure = Failure.fromException(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.messageKey, 'error_server');
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('maps unknown exception to UnknownFailure', () {
      const exception = FormatException('Bad format');
      final failure = Failure.fromException(exception);

      expect(failure, isA<UnknownFailure>());
      expect(failure.messageKey, 'error_unknown');
    });
  });
}
