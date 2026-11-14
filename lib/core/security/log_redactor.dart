import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Utility class for redacting sensitive fields (passwords, tokens, OTPs, PII)
/// from logs, error messages, and analytics payloads.
class LogRedactor {
  LogRedactor._();

  static const Set<String> sensitiveKeys = {
    'password',
    'oldpassword',
    'newpassword',
    'confirmpassword',
    'token',
    'refreshtoken',
    'accesstoken',
    'authorization',
    'cookie',
    'setcookie',
    'otp',
    'code',
    'pin',
    'secret',
    'cvv',
    'creditcard',
    'cardnumber',
  };

  /// Redacts sensitive information from a map or list recursively.
  static dynamic redact(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString();
        final normalizedKey = keyStr.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (sensitiveKeys.contains(normalizedKey)) {
          sanitized[keyStr] = '[REDACTED]';
        } else {
          sanitized[keyStr] = redact(value);
        }
      });
      return sanitized;
    }

    if (data is List) {
      return data.map(redact).toList();
    }

    if (data is String) {
      // Check if it's a JSON string
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map || decoded is List) {
          return jsonEncode(redact(decoded));
        }
      } catch (_) {
        // Not a JSON string
      }
      return data;
    }

    return data;
  }

  /// Safe logging helper that prints only in debug mode and redacts sensitive data.
  static void log(String message, {dynamic data}) {
    if (!kDebugMode) return;

    if (data != null) {
      final sanitized = redact(data);
      debugPrint('$message: $sanitized');
    } else {
      debugPrint(message);
    }
  }
}
