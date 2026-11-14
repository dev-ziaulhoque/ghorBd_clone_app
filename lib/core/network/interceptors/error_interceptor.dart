import 'package:dio/dio.dart';
import '../../error/exceptions.dart';
import '../api_result.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final transformedException = mapDioExceptionToAppException(err);

    final modifiedDioException = err.copyWith(
      error: transformedException,
      message: transformedException is ApiException
          ? transformedException.message
          : err.message,
    );

    handler.next(modifiedDioException);
  }

  static Exception mapDioExceptionToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkTimeoutException(
          'Connection timed out. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please verify your network and try again.',
        );

      case DioExceptionType.badResponse:
        final response = err.response;
        final statusCode = response?.statusCode;
        final dynamic data = response?.data;

        if (data is Map<String, dynamic> && data.containsKey('error')) {
          final errorResponse = ApiErrorResponse.fromJson(data);
          return ApiException(
            code: errorResponse.code,
            message: errorResponse.message,
            statusCode: statusCode,
            details: errorResponse.details,
          );
        }

        if (data is Map<String, dynamic> && data.containsKey('code')) {
          final errorResponse = ApiErrorResponse.fromJson(data);
          return ApiException(
            code: errorResponse.code,
            message: errorResponse.message,
            statusCode: statusCode,
            details: errorResponse.details,
          );
        }

        if (statusCode != null) {
          if (statusCode >= 500) {
            return ServerException(
              'Server encountered an internal error ($statusCode).',
              statusCode,
            );
          }
          return ApiException(
            code: 'HTTP_$statusCode',
            message: response?.statusMessage ?? 'Request failed with status $statusCode',
            statusCode: statusCode,
          );
        }

        return ServerException('Unknown server error occurred.', statusCode);

      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('Security certificate verification failed.');

      case DioExceptionType.unknown:
      default:
        if (err.error is Exception) {
          return err.error as Exception;
        }
        return NetworkException(err.message ?? 'An unexpected network error occurred.');
    }
  }
}
