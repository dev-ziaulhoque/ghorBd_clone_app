import 'package:dio/dio.dart';
import '../config/env.dart';
import '../security/certificate_pinning.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  late final Dio _dio;

  /// In-flight GET requests, keyed by method + path + sorted query.
  /// Identical concurrent GETs share one network call (Round 2 dedupe):
  /// e.g. Home firing the same listings query twice no longer pays the
  /// ~1.2–1.9 s backend TTFB twice.
  final Map<String, Future<Response<dynamic>>> _inFlightGets = {};

  DioClient({
    Dio? customDio,
    AuthInterceptor? authInterceptor,
  }) {
    if (customDio != null) {
      _dio = customDio;
    } else {
      _dio = Dio(
        BaseOptions(
          baseUrl: Env.baseUrl,
          connectTimeout: Env.connectTimeout,
          receiveTimeout: Env.receiveTimeout,
          sendTimeout: Env.sendTimeout,
          // Keep connections alive so repeat calls to the slow backend
          // reuse the TLS session instead of re-handshaking every time.
          persistentConnection: true,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );

      // Configure SSL Pinning hook (automatically disabled in dev/local)
      CertificatePinning.configure(_dio);

      _dio.interceptors.addAll([
        if (authInterceptor != null) authInterceptor,
        RetryInterceptor(dio: _dio),
        LoggingInterceptor(),
        ErrorInterceptor(),
      ]);
    }
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    // Dedupe identical in-flight GETs. Only plain, untyped GETs without
    // cancellation/progress/custom options are shared — anything with
    // its own lifecycle keeps its own call.
    final canDedupe = T == dynamic &&
        cancelToken == null &&
        onReceiveProgress == null &&
        options == null;
    if (!canDedupe) {
      return _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    }

    final key = _dedupeKey(path, queryParameters);
    final existing = _inFlightGets[key];
    if (existing != null) {
      return existing.then((r) => r as Response<T>);
    }
    final future = _dio.get<T>(
      path,
      queryParameters: queryParameters,
    );
    _inFlightGets[key] = future;
    // Evict once settled (success or error) so the next call re-fetches.
    future.whenComplete(() {
      if (identical(_inFlightGets[key], future)) {
        _inFlightGets.remove(key);
      }
    }).ignore();
    return future;
  }

  static String _dedupeKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return 'GET $path';
    final keys = query.keys.toList()..sort();
    final qs = keys.map((k) => '$k=${query[k]}').join('&');
    return 'GET $path?$qs';
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
