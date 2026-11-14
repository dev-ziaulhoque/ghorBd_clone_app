import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  final bool isDebug;

  LoggingInterceptor({bool? isDebug}) : isDebug = isDebug ?? kDebugMode;

  static const Set<String> _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-auth-token',
    'refresh-token',
  };

  static const Set<String> _sensitiveKeys = {
    'password',
    'oldpassword',
    'newpassword',
    'confirmpassword',
    'token',
    'refreshtoken',
    'accesstoken',
    'otp',
    'code',
    'pin',
    'secret',
    'credit_card',
    'cvv',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isDebug) {
      return handler.next(options);
    }

    final sanitizedHeaders = _sanitizeHeaders(options.headers);
    final sanitizedData = _sanitizeData(options.data);

    debugPrint('--> ${options.method.toUpperCase()} ${options.uri}');
    debugPrint('Headers: ${_formatJson(sanitizedHeaders)}');
    if (sanitizedData != null) {
      debugPrint('Body: ${_formatJson(sanitizedData)}');
    }
    debugPrint('--> END ${options.method.toUpperCase()}');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!isDebug) {
      return handler.next(response);
    }

    final sanitizedData = _sanitizeData(response.data);

    debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    if (sanitizedData != null) {
      debugPrint('Response: ${_formatJson(sanitizedData)}');
    }
    debugPrint('<-- END HTTP');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!isDebug) {
      return handler.next(err);
    }

    final sanitizedData = _sanitizeData(err.response?.data);

    debugPrint('<-- ERROR ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.uri}');
    debugPrint('Message: ${err.message}');
    if (sanitizedData != null) {
      debugPrint('Error Response: ${_formatJson(sanitizedData)}');
    }
    debugPrint('<-- END ERROR');

    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    headers.forEach((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString();
        if (_sensitiveKeys.contains(keyStr.toLowerCase().replaceAll('_', ''))) {
          sanitized[keyStr] = '[REDACTED]';
        } else {
          sanitized[keyStr] = _sanitizeData(value);
        }
      });
      return sanitized;
    }

    if (data is List) {
      return data.map(_sanitizeData).toList();
    }

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map || decoded is List) {
          return _sanitizeData(decoded);
        }
      } catch (_) {
        // Not a JSON string, return as is
      }
    }

    return data;
  }

  String _formatJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  // Exposed for testing
  dynamic sanitizeForTesting(dynamic data) => _sanitizeData(data);
  Map<String, dynamic> sanitizeHeadersForTesting(Map<String, dynamic> headers) =>
      _sanitizeHeaders(headers);
}
