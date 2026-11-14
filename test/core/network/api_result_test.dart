import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/core/network/api_result.dart';

void main() {
  group('ApiResult Response Contract Parsing', () {
    test('parses Shape 1: Single Item Success', () {
      final jsonResponse = {
        'data': {
          'listing': {
            'id': '6735a2b1f8e123456789abcd',
            'title': 'Furnished Flat in Dhanmondi',
            'pricePerMonth': 35000,
          }
        }
      };

      final result = ApiResult.fromResponse(
        jsonResponse,
        (data) => (data as Map<String, dynamic>)['listing'] as Map<String, dynamic>,
      );

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.metaOrNull, isNull);

      final listing = result.dataOrNull!;
      expect(listing['id'], '6735a2b1f8e123456789abcd');
      expect(listing['title'], 'Furnished Flat in Dhanmondi');
      expect(listing['pricePerMonth'], 35000);

      // Verify toEither returns Right
      final either = result.toEither();
      expect(either.isRight(), isTrue);
      either.fold(
        (failure) => fail('Expected Right, got Left($failure)'),
        (data) => expect(data['title'], 'Furnished Flat in Dhanmondi'),
      );
    });

    test('parses Shape 2: Paginated List Success', () {
      final jsonResponse = {
        'data': [
          {'id': 'item-1', 'title': 'House 1'},
          {'id': 'item-2', 'title': 'House 2'},
        ],
        'meta': {
          'page': 1,
          'perPage': 12,
          'total': 87,
          'totalPages': 8,
        }
      };

      final result = ApiResult.fromResponse(
        jsonResponse,
        (data) => (data as List<dynamic>).cast<Map<String, dynamic>>(),
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, 2);
      expect(result.metaOrNull, isNotNull);
      expect(result.metaOrNull?.page, 1);
      expect(result.metaOrNull?.perPage, 12);
      expect(result.metaOrNull?.total, 87);
      expect(result.metaOrNull?.totalPages, 8);

      final either = result.toEither();
      expect(either, isA<Right<Failure, List<Map<String, dynamic>>>>());
    });

    test('parses Shape 3: Error Response with validation details', () {
      final jsonResponse = {
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Validation failed',
          'details': [
            {
              'path': 'title',
              'message': 'String must contain at least 5 character(s)',
            },
            {
              'path': 'pricePerMonth',
              'message': 'Expected number, received nan',
            }
          ]
        }
      };

      final result = ApiResult<String>.fromResponse(
        jsonResponse,
        (data) => data.toString(),
        statusCode: 422,
      );

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);

      final error = result.errorOrNull!;
      expect(error.code, 'VALIDATION_ERROR');
      expect(error.message, 'Validation failed');
      expect(error.details.length, 2);
      expect(error.details[0].path, 'title');
      expect(error.details[0].message, 'String must contain at least 5 character(s)');

      // Check toEither maps to ValidationFailure
      final either = result.toEither();
      expect(either.isLeft(), isTrue);
      either.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          final valFailure = failure as ValidationFailure;
          expect(valFailure.code, 'VALIDATION_ERROR');
          expect(valFailure.details.length, 2);
        },
        (data) => fail('Expected Left, got Right'),
      );
    });

    test('when pattern matching executes correct callback', () {
      const successResult = ApiResult<int>.success(42);
      const errorResult = ApiResult<int>.failure(
        ApiErrorResponse(code: 'ERR', message: 'Something failed'),
      );

      final successMapped = successResult.when(
        success: (data, meta) => 'got $data',
        failure: (err, status) => 'error ${err.code}',
      );
      expect(successMapped, 'got 42');

      final errorMapped = errorResult.when(
        success: (data, meta) => 'got $data',
        failure: (err, status) => 'error ${err.code}',
      );
      expect(errorMapped, 'error ERR');
    });
  });

  group('Error Mapping to Domain Failures', () {
    test('maps 422 or VALIDATION_ERROR to ValidationFailure', () {
      const error = ApiErrorResponse(
        code: 'VALIDATION_ERROR',
        message: 'Invalid input fields',
        details: [ApiErrorDetail(path: 'phone', message: 'Invalid phone')],
      );

      final failure = mapApiErrorToFailure(error, statusCode: 422);
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).details.first.path, 'phone');
    });

    test('maps 401 and auth codes to AuthFailure', () {
      const codes = [
        'UNAUTHORIZED',
        'TOKEN_EXPIRED',
        'TOKEN_INVALID',
        'INVALID_CREDENTIALS',
        'REFRESH_TOKEN_INVALID',
        'PASSWORD_CHANGED',
        'ACCOUNT_MISSING',
      ];

      for (final code in codes) {
        final error = ApiErrorResponse(code: code, message: 'Auth error $code');
        final failure = mapApiErrorToFailure(error, statusCode: 401);
        expect(failure, isA<AuthFailure>(), reason: 'Code $code should map to AuthFailure');
      }
    });

    test('maps 403 and FORBIDDEN / EMAIL_NOT_VERIFIED to ForbiddenFailure', () {
      const error1 = ApiErrorResponse(code: 'FORBIDDEN', message: 'Access denied');
      final failure1 = mapApiErrorToFailure(error1, statusCode: 403);
      expect(failure1, isA<ForbiddenFailure>());

      const error2 = ApiErrorResponse(
        code: 'EMAIL_NOT_VERIFIED',
        message: 'Email must be verified',
      );
      final failure2 = mapApiErrorToFailure(error2, statusCode: 403);
      expect(failure2, isA<ForbiddenFailure>());
    });

    test('maps 404 and NOT_FOUND to NotFoundFailure', () {
      const error = ApiErrorResponse(code: 'NOT_FOUND', message: 'Listing not found');
      final failure = mapApiErrorToFailure(error, statusCode: 404);
      expect(failure, isA<NotFoundFailure>());
    });

    test('maps 409 and conflict codes to ConflictFailure', () {
      const error = ApiErrorResponse(
        code: 'ACCOUNT_EXISTS',
        message: 'Email is already registered',
      );
      final failure = mapApiErrorToFailure(error, statusCode: 409);
      expect(failure, isA<ConflictFailure>());
    });

    test('maps 413 or FILE_TOO_LARGE to PayloadTooLargeFailure', () {
      const error = ApiErrorResponse(
        code: 'FILE_TOO_LARGE',
        message: 'Photo exceeds 5MB size limit',
      );
      final failure = mapApiErrorToFailure(error, statusCode: 413);
      expect(failure, isA<PayloadTooLargeFailure>());
    });

    test('maps 429 and TOO_MANY_REQUESTS to RateLimitFailure', () {
      const error = ApiErrorResponse(
        code: 'TOO_MANY_REQUESTS',
        message: 'Too many requests. Please wait.',
      );
      final failure = mapApiErrorToFailure(error, statusCode: 429);
      expect(failure, isA<RateLimitFailure>());
    });

    test('maps 500 / unhandled codes to ServerFailure', () {
      const error = ApiErrorResponse(
        code: 'GEOCODER_UNAVAILABLE',
        message: 'Geocoding service unavailable',
      );
      final failure = mapApiErrorToFailure(error, statusCode: 500);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });
  });
}
