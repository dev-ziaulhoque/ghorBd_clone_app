import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/network/interceptors/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor Redaction & Debug Mode', () {
    late LoggingInterceptor interceptor;

    setUp(() {
      interceptor = LoggingInterceptor(isDebug: true);
    });

    test('redacts sensitive headers: Authorization, Cookie, Set-Cookie', () {
      final headers = {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret',
        'Cookie': 'token=secret123; refreshToken=secret456',
        'Set-Cookie': 'session=abc',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final sanitized = interceptor.sanitizeHeadersForTesting(headers);

      expect(sanitized['Authorization'], '[REDACTED]');
      expect(sanitized['Cookie'], '[REDACTED]');
      expect(sanitized['Set-Cookie'], '[REDACTED]');
      expect(sanitized['Content-Type'], 'application/json');
      expect(sanitized['Accept'], 'application/json');
    });

    test('redacts sensitive body fields: password, otp, token, refreshToken, secret', () {
      final body = {
        'name': 'Rahim Uddin',
        'email': 'rahim@example.com',
        'password': 'SuperSecretPassword!1',
        'confirmPassword': 'SuperSecretPassword!1',
        'otp': '123456',
        'token': 'access_token_value',
        'refreshToken': 'refresh_token_value',
        'pricePerMonth': 25000,
      };

      final sanitized = interceptor.sanitizeForTesting(body) as Map<String, dynamic>;

      expect(sanitized['name'], 'Rahim Uddin');
      expect(sanitized['email'], 'rahim@example.com');
      expect(sanitized['pricePerMonth'], 25000);
      expect(sanitized['password'], '[REDACTED]');
      expect(sanitized['confirmPassword'], '[REDACTED]');
      expect(sanitized['otp'], '[REDACTED]');
      expect(sanitized['token'], '[REDACTED]');
      expect(sanitized['refreshToken'], '[REDACTED]');
    });

    test('redacts recursively inside nested maps and lists', () {
      final nestedData = {
        'user': {
          'id': 'user-123',
          'auth': {
            'password': 'my-password',
            'token': 'secret-jwt',
          },
        },
        'items': [
          {'title': 'Ad 1', 'secret': 'hidden'},
          {'title': 'Ad 2', 'secret': 'also-hidden'},
        ],
      };

      final sanitized = interceptor.sanitizeForTesting(nestedData) as Map<String, dynamic>;

      expect((sanitized['user'] as Map)['id'], 'user-123');
      expect(((sanitized['user'] as Map)['auth'] as Map)['password'], '[REDACTED]');
      expect(((sanitized['user'] as Map)['auth'] as Map)['token'], '[REDACTED]');

      final items = sanitized['items'] as List;
      expect((items[0] as Map)['title'], 'Ad 1');
      expect((items[0] as Map)['secret'], '[REDACTED]');
      expect((items[1] as Map)['title'], 'Ad 2');
      expect((items[1] as Map)['secret'], '[REDACTED]');
    });

    test('when isDebug is false, onRequest/onResponse/onError immediately forward to handler', () {
      final nonDebugInterceptor = LoggingInterceptor(isDebug: false);

      var nextRequestCalled = false;
      nonDebugInterceptor.onRequest(
        RequestOptions(path: '/listings'),
        _MockRequestHandler(onNext: (_) => nextRequestCalled = true),
      );
      expect(nextRequestCalled, isTrue);

      var nextResponseCalled = false;
      nonDebugInterceptor.onResponse(
        Response(
          requestOptions: RequestOptions(path: '/listings'),
          statusCode: 200,
        ),
        _MockResponseHandler(onNext: (_) => nextResponseCalled = true),
      );
      expect(nextResponseCalled, isTrue);

      var nextErrorCalled = false;
      nonDebugInterceptor.onError(
        DioException(requestOptions: RequestOptions(path: '/listings')),
        _MockErrorHandler(onNext: (_) => nextErrorCalled = true),
      );
      expect(nextErrorCalled, isTrue);
    });
  });
}

class _MockRequestHandler extends RequestInterceptorHandler {
  final void Function(RequestOptions) onNext;
  _MockRequestHandler({required this.onNext});

  @override
  void next(RequestOptions requestOptions) {
    onNext(requestOptions);
  }
}

class _MockResponseHandler extends ResponseInterceptorHandler {
  final void Function(Response) onNext;
  _MockResponseHandler({required this.onNext});

  @override
  void next(Response response) {
    onNext(response);
  }
}

class _MockErrorHandler extends ErrorInterceptorHandler {
  final void Function(DioException) onNext;
  _MockErrorHandler({required this.onNext});

  @override
  void next(DioException err) {
    onNext(err);
  }
}
