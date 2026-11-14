import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';

/// SSL Pinning & Certificate Verification Hook for Dio.
/// Follows Security Requirement: "SSL pinning: Enable in production build (pin config via env)".
/// In dev/staging/local environments, pinning is turned off by default.
class CertificatePinning {
  CertificatePinning._();

  /// SHA-256 Fingerprints can be injected via dart-define or config
  static const String _envFingerprints = String.fromEnvironment('SSL_PIN_SHA256', defaultValue: '');

  static List<String> get configuredPins {
    if (_envFingerprints.isEmpty) return const [];
    return _envFingerprints.split(',').map((s) => s.trim().toLowerCase()).toList();
  }

  /// Configures certificate validation on the Dio client.
  /// When [forceEnable] is null, enforcement depends on [Env.isProduction].
  static void configure(Dio dio, {bool? forceEnable, List<String>? customPins}) {
    final bool enable = forceEnable ?? Env.isProduction;

    // Pinning hook is off in dev
    if (!enable || kIsWeb) {
      return;
    }

    final pins = customPins ?? configuredPins;

    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final securityContext = SecurityContext(withTrustedRoots: true);
        final client = HttpClient(context: securityContext);

        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // In production, reject any bad/untrusted certificate
          if (pins.isEmpty) {
            // Default strict: never accept invalid certificate
            return false;
          }

          // If custom SHA-256 pins are provided, verify against certificate DER SHA-256 hash
          final certFingerprint = sha256.convert(cert.der).toString().toLowerCase();

          for (final pin in pins) {
            final cleanPin = pin.replaceAll(':', '').replaceAll(' ', '').toLowerCase();
            if (certFingerprint == cleanPin) {
              return true;
            }
          }

          debugPrint('SSL Pinning failure for $host: $certFingerprint does not match allowed pins.');
          return false;
        };

        return client;
      };
    }
  }
}
