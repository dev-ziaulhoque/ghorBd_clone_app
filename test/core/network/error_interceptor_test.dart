import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/network/interceptors/error_interceptor.dart';

void main() {
  group('ErrorInterceptor & mapDioExceptionToAppException', () {
    test('transforms connectionTimeout to NetworkException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/listings'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timed out',
      );

      final appException = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(appException, isA<NetworkException>());
      expect(
        (appException as NetworkException).message,
        contains('timed out'),
      );
    });

    test('transforms connectionError to NetworkException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/listings'),
        type: DioExceptionType.connectionError,
        message: 'SocketException: failed to connect',
      );

      final appException = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(appException, isA<NetworkException>());
      expect(
        (appException as NetworkException).message,
        contains('No internet connection'),
      );
    });

    test('transforms 422 badResponse with error body to ApiException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 422,
          data: {
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Validation failed',
              'details': [
                {'path': 'email', 'message': 'Invalid email address'}
              ],
            }
          },
        ),
      );

      final appException = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(appException, isA<ApiException>());

      final apiException = appException as ApiException;
      expect(apiException.code, 'VALIDATION_ERROR');
      expect(apiException.statusCode, 422);
      expect(apiException.message, 'Validation failed');
      expect(apiException.details.length, 1);
      expect(apiException.details.first.path, 'email');
    });

    test('transforms 401 TOKEN_EXPIRED to ApiException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/profile'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 401,
          data: {
            'error': {
              'code': 'TOKEN_EXPIRED',
              'message': 'Access token expired',
            }
          },
        ),
      );

      final appException = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(appException, isA<ApiException>());

      final apiException = appException as ApiException;
      expect(apiException.code, 'TOKEN_EXPIRED');
      expect(apiException.statusCode, 401);
    });

    test('transforms 500 without JSON error body to ServerException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/listings'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/listings'),
          statusCode: 500,
          data: 'Internal Server Error',
        ),
      );

      final appException = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(appException, isA<ServerException>());

      final serverException = appException as ServerException;
      expect(serverException.statusCode, 500);
      expect(serverException.message, contains('500'));
    });
  });
}
