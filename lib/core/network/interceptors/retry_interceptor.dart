import 'dart:async';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;
  final Future<void> Function(Duration duration)? delayFunction;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = const Duration(milliseconds: 500),
    this.delayFunction,
  });

  static const String _retryCountKey = 'retry_count';
  static const Set<String> _safeMethods = {'GET', 'HEAD'};

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final method = requestOptions.method.toUpperCase();

    // Safe requests only (GET, HEAD)
    if (!_safeMethods.contains(method)) {
      return handler.next(err);
    }

    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final currentRetry = (requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (currentRetry >= maxRetries) {
      return handler.next(err);
    }

    final nextRetry = currentRetry + 1;
    requestOptions.extra[_retryCountKey] = nextRetry;

    final delay = retryInterval * nextRetry;
    if (delayFunction != null) {
      await delayFunction!(delay);
    } else {
      await Future<void>.delayed(delay);
    }

    try {
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    } catch (e) {
      return handler.next(
        DioException(
          requestOptions: requestOptions,
          error: e,
        ),
      );
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        return statusCode != null &&
            (statusCode == 500 ||
                statusCode == 502 ||
                statusCode == 503 ||
                statusCode == 504);
      default:
        return false;
    }
  }

  bool shouldRetryForTesting(DioException err) => _shouldRetry(err);
}
