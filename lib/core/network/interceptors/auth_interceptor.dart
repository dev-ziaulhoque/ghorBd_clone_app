import 'dart:async';
import 'package:dio/dio.dart';
import '../../../app/di/injection.dart';
import '../../config/env.dart';
import '../../security/secure_storage.dart';
import '../../security/session_manager.dart';

class AuthInterceptor extends QueuedInterceptor {
  final AppSecureStorage secureStorage;
  final Dio refreshDio;
  final Future<void> Function()? onLogout;

  Completer<bool>? _refreshCompleter;

  AuthInterceptor({
    required this.secureStorage,
    Dio? refreshDio,
    this.onLogout,
  }) : refreshDio = refreshDio ??
            Dio(
              BaseOptions(
                baseUrl: Env.baseUrl,
                connectTimeout: Env.connectTimeout,
                receiveTimeout: Env.receiveTimeout,
                sendTimeout: Env.sendTimeout,
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  static const String noAuthHeaderKey = 'no_auth';
  static const String isRetryKey = 'is_retry_after_refresh';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[noAuthHeaderKey] == true) {
      return handler.next(options);
    }

    if (sl.isRegistered<SessionManager>()) {
      sl<SessionManager>().recordActivity();
    }

    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final statusCode = response?.statusCode;
    final requestOptions = err.requestOptions;

    // Do not intercept refresh call itself or already retried requests
    final isRefreshCall = requestOptions.path.contains('/auth/refresh');
    final alreadyRetried = requestOptions.extra[isRetryKey] == true;

    if (statusCode == 401 && !isRefreshCall && !alreadyRetried) {
      final isRefreshing = _refreshCompleter != null;

      if (!isRefreshing) {
        _refreshCompleter = Completer<bool>();
        final success = await _performRefreshToken();
        _refreshCompleter!.complete(success);
        _refreshCompleter = null;

        if (success) {
          return _retryRequest(requestOptions, handler);
        } else {
          await _handleLogout();
          return handler.next(err);
        }
      } else {
        // Wait for the single-flight refresh currently in progress
        final success = await _refreshCompleter!.future;
        if (success) {
          return _retryRequest(requestOptions, handler);
        } else {
          return handler.next(err);
        }
      }
    }

    handler.next(err);
  }

  Future<bool> _performRefreshToken() async {
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          final newAccessToken = data['accessToken']?.toString();
          final newRefreshToken = data['refreshToken']?.toString();

          if (newAccessToken != null && newRefreshToken != null) {
            await secureStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            return true;
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final newAccessToken = await secureStorage.getAccessToken();
    requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
    requestOptions.extra[isRetryKey] = true;

    try {
      final retryResponse = await refreshDio.fetch(requestOptions);
      handler.resolve(retryResponse);
    } on DioException catch (e) {
      handler.next(e);
    } catch (e) {
      handler.next(
        DioException(
          requestOptions: requestOptions,
          error: e,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await secureStorage.clearAll();
    if (onLogout != null) {
      await onLogout!();
    }
  }
}
