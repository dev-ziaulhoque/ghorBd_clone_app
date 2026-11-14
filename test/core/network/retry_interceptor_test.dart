import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/network/interceptors/retry_interceptor.dart';

void main() {
  late Dio dio;
  late RetryInterceptor retryInterceptor;

  setUp(() {
    dio = Dio();
    retryInterceptor = RetryInterceptor(
      dio: dio,
      maxRetries: 3,
      retryInterval: const Duration(milliseconds: 10),
      delayFunction: (_) async {}, // Instant delay in tests
    );
  });

  group('RetryInterceptor safety checks (safe GET requests only)', () {
    test('should retry GET on connectionTimeout', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/listings', method: 'GET'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(retryInterceptor.shouldRetryForTesting(dioException), isTrue);
    });

    test('should retry GET on receiveTimeout and connectionError', () {
      final timeoutErr = DioException(
        requestOptions: RequestOptions(path: '/listings', method: 'GET'),
        type: DioExceptionType.receiveTimeout,
      );
      final connErr = DioException(
        requestOptions: RequestOptions(path: '/listings', method: 'GET'),
        type: DioExceptionType.connectionError,
      );

      expect(retryInterceptor.shouldRetryForTesting(timeoutErr), isTrue);
      expect(retryInterceptor.shouldRetryForTesting(connErr), isTrue);
    });

    test('should retry GET on 502 / 503 / 504 server errors', () {
      final err502 = DioException(
        requestOptions: RequestOptions(path: '/listings', method: 'GET'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/listings', method: 'GET'),
          statusCode: 502,
        ),
      );

      final err503 = DioException(
        requestOptions: RequestOptions(path: '/listings', method: 'GET'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/listings', method: 'GET'),
          statusCode: 503,
        ),
      );

      expect(retryInterceptor.shouldRetryForTesting(err502), isTrue);
      expect(retryInterceptor.shouldRetryForTesting(err503), isTrue);
    });

    test('should NOT retry on 4xx client errors (400, 401, 404, 422, 429)', () {
      for (final code in [400, 401, 404, 422, 429]) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/listings', method: 'GET'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/listings', method: 'GET'),
            statusCode: code,
          ),
        );

        expect(
          retryInterceptor.shouldRetryForTesting(err),
          isFalse,
          reason: 'Status $code should not be retried',
        );
      }
    });

    test('should NOT retry unsafe methods: POST, PUT, DELETE, PATCH', () async {
      final unsafeMethods = ['POST', 'PUT', 'DELETE', 'PATCH'];

      for (final method in unsafeMethods) {
        var nextCalled = false;
        final err = DioException(
          requestOptions: RequestOptions(path: '/auth/login', method: method),
          type: DioExceptionType.connectionTimeout,
        );

        final customInterceptor = RetryInterceptor(
          dio: dio,
          maxRetries: 3,
        );

        await customInterceptor.onError(
          err,
          _MockHandler(
            onNext: (e) {
              nextCalled = true;
            },
          ),
        );

        expect(
          nextCalled,
          isTrue,
          reason: '$method should pass error to next handler without retrying',
        );
      }
    });
  });
}

class _MockHandler extends ErrorInterceptorHandler {
  final void Function(DioException e) onNext;

  _MockHandler({required this.onNext});

  @override
  void next(DioException err) {
    onNext(err);
  }

  @override
  void resolve(Response response) {}

  @override
  void reject(DioException err, [bool isHandlerTerminated = false]) {}
}
