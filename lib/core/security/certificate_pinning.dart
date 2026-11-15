import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';

/// SSL Pinning & Certificate Verification Hook for Dio.
/// Follows Security Requirement: "SSL pinning: Enable in production build (pin config via env)".
/// Follows PROGRESS.md: "2c: certificate_pinning hook (off in dev)".
/// Supports multiple comma-separated SHA-256 pins (primary and backup).
/// Fails closed in production if no valid pins are configured.
/// Pins apply strictly to the API host from `Env.apiHost`.
///
/// ### How to extract SHA-256 certificate pins:
/// 1. From a live server (e.g. api.ghorbd.com):
///    ```bash
///    openssl s_client -servername api.ghorbd.com -connect api.ghorbd.com:443 </dev/null 2>/dev/null \
///      | openssl x509 -outform DER \
///      | openssl dgst -sha256 -hex
///    ```
/// 2. From a certificate file (.crt or .pem):
///    ```bash
///    openssl x509 -in certificate.crt -outform DER | openssl dgst -sha256 -hex
///    ```
/// 3. Supply primary and backup pins during release build:
///    ```bash
///    flutter build apk --release \
///      --dart-define=SSL_PIN_SHA256="<primary_hex>,<backup_hex>"
///    ```
class CertificatePinning {
  CertificatePinning._();

  /// Real live production SHA-256 fingerprint for ghorbd.com extracted from live certificate:
  /// Subject: /CN=ghorbd.com, Issuer: Let's Encrypt (YE2)
  static const String liveProductionPin =
      'd852b21452f821df06b9a00cebb133096f45216beb2987010231fc05744c3cd4';

  /// Comma-separated SHA-256 fingerprints injected via --dart-define=SSL_PIN_SHA256="..."
  /// Defaults to the verified live certificate fingerprint for ghorbd.com.
  static const String _envFingerprints =
      String.fromEnvironment('SSL_PIN_SHA256', defaultValue: liveProductionPin);

  /// Parses and cleans multiple pins (primary and backup, comma-separated).
  static List<String> parsePins(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((s) => s.replaceAll(':', '').replaceAll(' ', '').trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<String> get configuredPins => parsePins(_envFingerprints);

  /// Validates a certificate DER hash against allowed pins for the given host.
  /// Returns `true` if valid, `false` otherwise.
  static bool verifyCertificate({
    required List<int> certDer,
    required String host,
    required String targetApiHost,
    required List<String> pins,
    required bool isProduction,
  }) {
    final cleanHost = host.toLowerCase().trim();
    final cleanTargetHost = targetApiHost.toLowerCase().trim();

    // Pins must apply strictly to the API host from env.dart, not website or third-party domains
    if (cleanHost != cleanTargetHost) {
      debugPrint('SSL Pinning: Host mismatch! Expected $cleanTargetHost, got $cleanHost. Failing request.');
      return false;
    }

    // In production builds, an empty pin list must FAIL CLOSED (block requests)
    if (pins.isEmpty) {
      if (isProduction) {
        debugPrint('SSL Pinning: Production build has empty pins for $cleanHost. Failing closed (blocked).');
        return false;
      }
      return true;
    }

    final certFingerprint = sha256.convert(certDer).toString().toLowerCase();

    for (final pin in pins) {
      if (certFingerprint == pin) {
        return true;
      }
    }

    debugPrint('SSL Pinning failure for $host: $certFingerprint does not match configured pins.');
    return false;
  }

  /// Configures certificate validation on the Dio client.
  /// When [forceEnable] is null, enforcement is active ONLY in release mode for production.
  /// In debug/development mode, pinning is disabled by default to avoid blocking developers.
  static void configure(
    Dio dio, {
    bool? forceEnable,
    List<String>? customPins,
    String? customApiHost,
  }) {
    final bool enable = forceEnable ?? (kReleaseMode && Env.isProduction);

    // Pinning hook is disabled on web or in non-production / debug builds unless forced
    if (!enable || kIsWeb) {
      return;
    }

    final pins = customPins ?? configuredPins;
    final targetHost = customApiHost ?? Env.apiHost;
    final isProd = forceEnable != null ? (forceEnable && Env.isProduction) : Env.isProduction;

    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        // Enforce custom certificate callback for all handshakes
        final securityContext = SecurityContext(withTrustedRoots: false);
        final client = HttpClient(context: securityContext);

        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return verifyCertificate(
            certDer: cert.der,
            host: host,
            targetApiHost: targetHost,
            pins: pins,
            isProduction: isProd || enable,
          );
        };

        return client;
      };
    }
  }
}
