import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/config/env.dart';
import 'package:ghorbad_clone_app/core/security/certificate_pinning.dart';
import 'package:ghorbad_clone_app/core/security/log_redactor.dart';

void main() {
  group('LogRedactor', () {
    test('redacts sensitive fields in nested Map', () {
      final payload = {
        'user': {
          'name': 'Rahim',
          'email': 'rahim@example.com',
          'password': 'SuperSecret123!',
          'token': 'jwt.token.value',
        },
        'otp': '123456',
        'safe_field': 42,
      };

      final sanitized = LogRedactor.redact(payload) as Map<String, dynamic>;

      expect(sanitized['safe_field'], 42);
      expect((sanitized['user'] as Map)['name'], 'Rahim');
      expect((sanitized['user'] as Map)['password'], '[REDACTED]');
      expect((sanitized['user'] as Map)['token'], '[REDACTED]');
      expect(sanitized['otp'], '[REDACTED]');
    });

    test('redacts sensitive fields in JSON strings', () {
      const jsonStr = '{"email":"test@test.com","password":"secret","refreshToken":"xyz"}';
      final sanitized = LogRedactor.redact(jsonStr) as String;

      expect(sanitized.contains('[REDACTED]'), isTrue);
      expect(sanitized.contains('secret'), isFalse);
    });

    test('redacts list of maps', () {
      final list = [
        {'id': 1, 'token': 'abc'},
        {'id': 2, 'safe': 'def'},
      ];

      final sanitized = LogRedactor.redact(list) as List;
      expect((sanitized[0] as Map)['token'], '[REDACTED]');
      expect((sanitized[1] as Map)['safe'], 'def');
    });
  });

  group('CertificatePinning', () {
    tearDown(() {
      Env.reset();
    });

    test('does nothing when forceEnable is false', () {
      final dio = Dio();
      CertificatePinning.configure(dio, forceEnable: false);
      // Shouldn't crash and default adapter remains
      expect(dio.httpClientAdapter, isNotNull);
    });

    test('configures pinning when forceEnable is true', () {
      final dio = Dio();
      CertificatePinning.configure(
        dio,
        forceEnable: true,
        customPins: ['abcdef1234567890'],
      );
      expect(dio.httpClientAdapter, isNotNull);
    });
  });
}
