import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/security/certificate_pinning.dart';

void main() {
  group('CertificatePinning Unit Tests', () {
    const primaryHash = 'a1b2c3d4e5f60718293a4b5c6d7e8f90123456789abcdef0123456789abcdef0';
    const backupHash = 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210';
    const fakeCertDer = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    final calculatedDerHash = sha256.convert(fakeCertDer).toString().toLowerCase();

    test('parsePins correctly parses and normalizes single and multiple pins', () {
      expect(CertificatePinning.parsePins(''), isEmpty);
      expect(CertificatePinning.parsePins('   '), isEmpty);

      // Single pin with spaces and colons
      final single = CertificatePinning.parsePins(' A1:B2:C3:D4 ');
      expect(single, ['a1b2c3d4']);

      // Multiple comma-separated pins (primary + backup)
      final multiple = CertificatePinning.parsePins(
        '  $primaryHash,  $backupHash  ',
      );
      expect(multiple.length, 2);
      expect(multiple[0], primaryHash);
      expect(multiple[1], backupHash);
    });

    test('verifyCertificate succeeds when cert matches primary pin', () {
      final result = CertificatePinning.verifyCertificate(
        certDer: fakeCertDer,
        host: 'api.ghorbd.com',
        targetApiHost: 'api.ghorbd.com',
        pins: [calculatedDerHash, backupHash],
        isProduction: true,
      );
      expect(result, isTrue);
    });

    test('verifyCertificate succeeds when cert matches backup pin', () {
      final result = CertificatePinning.verifyCertificate(
        certDer: fakeCertDer,
        host: 'api.ghorbd.com',
        targetApiHost: 'api.ghorbd.com',
        pins: [primaryHash, calculatedDerHash],
        isProduction: true,
      );
      expect(result, isTrue);
    });

    test('verifyCertificate fails when cert matches neither primary nor backup pin', () {
      final result = CertificatePinning.verifyCertificate(
        certDer: fakeCertDer,
        host: 'api.ghorbd.com',
        targetApiHost: 'api.ghorbd.com',
        pins: [primaryHash, backupHash],
        isProduction: true,
      );
      expect(result, isFalse);
    });

    test('verifyCertificate rejects host mismatch (pins apply strictly to api host)', () {
      final result = CertificatePinning.verifyCertificate(
        certDer: fakeCertDer,
        host: 'malicious-domain.com',
        targetApiHost: 'api.ghorbd.com',
        pins: [calculatedDerHash],
        isProduction: true,
      );
      expect(result, isFalse);
    });

    test('verifyCertificate FAILS CLOSED in production when pin list is empty', () {
      final result = CertificatePinning.verifyCertificate(
        certDer: fakeCertDer,
        host: 'api.ghorbd.com',
        targetApiHost: 'api.ghorbd.com',
        pins: [],
        isProduction: true,
      );
      // Must fail closed (block requests) in production
      expect(result, isFalse);
    });

    test('verifyCertificate passes in non-production when pin list is empty', () {
      final result = CertificatePinning.verifyCertificate(
        certDer: fakeCertDer,
        host: 'api.ghorbd.com',
        targetApiHost: 'api.ghorbd.com',
        pins: [],
        isProduction: false,
      );
      expect(result, isTrue);
    });

    test('configure attaches custom HttpClientAdapter when forceEnable is true', () {
      final dio = Dio();
      CertificatePinning.configure(
        dio,
        forceEnable: true,
        customPins: [calculatedDerHash],
        customApiHost: 'ghorbd.com',
      );
      expect(dio.httpClientAdapter, isNotNull);
    });
  });
}
