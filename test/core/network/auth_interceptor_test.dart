import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/network/interceptors/auth_interceptor.dart';
import 'package:ghorbad_clone_app/core/security/secure_storage.dart';
import '../security/secure_storage_test.dart';

void main() {
  late FakeFlutterSecureStorage fakeStorage;
  late AppSecureStorage secureStorage;
  late Dio refreshDio;
  late AuthInterceptor authInterceptor;
  var onLogoutCalled = false;
  var refreshCallCount = 0;

  setUp(() {
    fakeStorage = FakeFlutterSecureStorage();
    secureStorage = AppSecureStorage(storage: fakeStorage);
    onLogoutCalled = false;
    refreshCallCount = 0;

    refreshDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

    authInterceptor = AuthInterceptor(
      secureStorage: secureStorage,
      refreshDio: refreshDio,
      onLogout: () async {
        onLogoutCalled = true;
      },
    );
  });

  group('AuthInterceptor', () {
    test('attaches Authorization header when access token is present', () async {
      await secureStorage.saveTokens(
        accessToken: 'valid_access_token_123',
        refreshToken: 'valid_refresh_token_456',
      );

      final options = RequestOptions(path: '/user/profile');
      final handler = _MockRequestHandler();

      await authInterceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer valid_access_token_123');
      expect(handler.nextCalled, isTrue);
    });

    test('does not attach Authorization header when no_auth is true', () async {
      await secureStorage.saveTokens(
        accessToken: 'valid_access_token_123',
        refreshToken: 'valid_refresh_token_456',
      );

      final options = RequestOptions(
        path: '/auth/login',
        extra: {AuthInterceptor.noAuthHeaderKey: true},
      );
      final handler = _MockRequestHandler();

      await authInterceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('concurrent 401s trigger exactly one refresh and retry all requests', () async {
      await secureStorage.saveTokens(
        accessToken: 'expired_access_token',
        refreshToken: 'valid_refresh_token',
      );

      // Setup refreshDio adapter to handle /auth/refresh and retries
      refreshDio.httpClientAdapter = _MockAdapter(
        onFetch: (options) async {
          if (options.path.contains('/auth/refresh')) {
            refreshCallCount++;
            return ResponseBody.fromString(
              '{"data": {"accessToken": "new_access_token", "refreshToken": "new_refresh_token"}}',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }

          // Retried requests
          if (options.headers['Authorization'] == 'Bearer new_access_token') {
            return ResponseBody.fromString(
              '{"data": {"success": true, "path": "${options.path}"}}',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }

          return ResponseBody.fromString('Unauthorized', 401);
        },
      );

      final err1 = DioException(
        requestOptions: RequestOptions(path: '/listings/1'),
        response: Response(
          requestOptions: RequestOptions(path: '/listings/1'),
          statusCode: 401,
        ),
      );
      final err2 = DioException(
        requestOptions: RequestOptions(path: '/listings/2'),
        response: Response(
          requestOptions: RequestOptions(path: '/listings/2'),
          statusCode: 401,
        ),
      );
      final err3 = DioException(
        requestOptions: RequestOptions(path: '/listings/3'),
        response: Response(
          requestOptions: RequestOptions(path: '/listings/3'),
          statusCode: 401,
        ),
      );

      final handler1 = _MockErrorHandler();
      final handler2 = _MockErrorHandler();
      final handler3 = _MockErrorHandler();

      // Trigger 3 concurrent 401 errors simultaneously
      await Future.wait([
        authInterceptor.onError(err1, handler1),
        authInterceptor.onError(err2, handler2),
        authInterceptor.onError(err3, handler3),
      ]);

      // Exactly ONE refresh call must have occurred
      expect(refreshCallCount, 1);

      // All 3 handlers must have resolved with successful retried responses
      expect(handler1.resolvedResponse?.statusCode, 200);
      expect(handler2.resolvedResponse?.statusCode, 200);
      expect(handler3.resolvedResponse?.statusCode, 200);

      // Verify tokens were updated in secure storage
      expect(await secureStorage.getAccessToken(), 'new_access_token');
      expect(await secureStorage.getRefreshToken(), 'new_refresh_token');
      expect(onLogoutCalled, isFalse);
    });

    test('refresh failure clears storage, triggers onLogout, and rejects requests', () async {
      await secureStorage.saveTokens(
        accessToken: 'expired_access_token',
        refreshToken: 'invalid_refresh_token',
      );

      // Setup refreshDio to return 401 for /auth/refresh
      refreshDio.httpClientAdapter = _MockAdapter(
        onFetch: (options) async {
          return ResponseBody.fromString(
            '{"error": {"code": "REFRESH_TOKEN_INVALID", "message": "Invalid refresh token"}}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final err = DioException(
        requestOptions: RequestOptions(path: '/profile'),
        response: Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 401,
        ),
      );
      final handler = _MockErrorHandler();

      await authInterceptor.onError(err, handler);

      // Should fail refresh and call next(err)
      expect(handler.nextCalled, isTrue);
      expect(onLogoutCalled, isTrue);
      expect(await secureStorage.hasValidSession(), isFalse);
    });

    test('401 on /auth/refresh itself does not trigger infinite refresh loop', () async {
      await secureStorage.saveTokens(
        accessToken: 'token',
        refreshToken: 'refresh',
      );

      final refreshErr = DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
        ),
      );
      final handler = _MockErrorHandler();

      await authInterceptor.onError(refreshErr, handler);

      expect(handler.nextCalled, isTrue);
      expect(refreshCallCount, 0); // No recursion
    });
  });
}

class _MockRequestHandler extends RequestInterceptorHandler {
  bool nextCalled = false;
  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}

class _MockErrorHandler extends ErrorInterceptorHandler {
  Response? resolvedResponse;
  bool nextCalled = false;

  @override
  void resolve(Response response) {
    resolvedResponse = response;
  }

  @override
  void next(DioException err) {
    nextCalled = true;
  }

  @override
  void reject(DioException err, [bool isHandlerTerminated = false]) {
    nextCalled = true;
  }
}

class _MockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  _MockAdapter({required this.onFetch});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}
