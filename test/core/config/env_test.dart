import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/config/env.dart';

void main() {
  group('Env & AppEnvironment', () {
    tearDown(() {
      Env.reset();
    });

    test('default environment is prod', () {
      expect(Env.currentEnvironment, AppEnvironment.prod);
      expect(Env.baseUrl, 'https://ghorbd.com/api');
      expect(Env.mediaBaseUrl, 'https://ghorbd.com');
      expect(Env.isProduction, isTrue);
      expect(Env.isDevelopment, isFalse);
    });

    test('AppEnvironment.fromString parses all supported values', () {
      expect(AppEnvironment.fromString('prod'), AppEnvironment.prod);
      expect(AppEnvironment.fromString('production'), AppEnvironment.prod);
      expect(AppEnvironment.fromString('staging'), AppEnvironment.staging);
      expect(AppEnvironment.fromString('stage'), AppEnvironment.staging);
      expect(AppEnvironment.fromString('local'), AppEnvironment.local);
      expect(AppEnvironment.fromString('dev'), AppEnvironment.local);
      expect(AppEnvironment.fromString('development'), AppEnvironment.local);
      expect(AppEnvironment.fromString('emulator'), AppEnvironment.emulator);
      expect(AppEnvironment.fromString('android_emulator'), AppEnvironment.emulator);
      expect(AppEnvironment.fromString('lan'), AppEnvironment.lan);
      expect(AppEnvironment.fromString('unknown_val'), AppEnvironment.prod);
      expect(AppEnvironment.fromString(null), AppEnvironment.prod);
    });

    test('base URLs match API_AUDIT.md specifications for each environment', () {
      expect(
        Env.getBaseUrlForEnvironment(AppEnvironment.prod),
        'https://ghorbd.com/api',
      );
      expect(
        Env.getBaseUrlForEnvironment(AppEnvironment.staging),
        'https://staging.ghorbd.com/api',
      );
      expect(
        Env.getBaseUrlForEnvironment(AppEnvironment.local),
        'http://localhost:5000/api',
      );
      expect(
        Env.getBaseUrlForEnvironment(AppEnvironment.emulator),
        'http://10.0.2.2:5000/api',
      );
      expect(
        Env.getBaseUrlForEnvironment(AppEnvironment.lan, lanIp: '192.168.0.25'),
        'http://192.168.0.25:5000/api',
      );
    });

    test('media URLs match API_AUDIT.md specifications for each environment', () {
      expect(
        Env.getMediaBaseUrlForEnvironment(AppEnvironment.prod),
        'https://ghorbd.com',
      );
      expect(
        Env.getMediaBaseUrlForEnvironment(AppEnvironment.staging),
        'https://staging.ghorbd.com',
      );
      expect(
        Env.getMediaBaseUrlForEnvironment(AppEnvironment.local),
        'http://localhost:5000',
      );
      expect(
        Env.getMediaBaseUrlForEnvironment(AppEnvironment.emulator),
        'http://10.0.2.2:5000',
      );
      expect(
        Env.getMediaBaseUrlForEnvironment(AppEnvironment.lan, lanIp: '192.168.0.25'),
        'http://192.168.0.25:5000',
      );
    });

    test('Env.setOverride correctly overrides environment and base URLs', () {
      Env.setOverride(
        environment: AppEnvironment.staging,
        baseUrl: 'https://custom-stage.ghorbd.com/api',
        mediaBaseUrl: 'https://custom-stage.ghorbd.com',
      );

      expect(Env.currentEnvironment, AppEnvironment.staging);
      expect(Env.baseUrl, 'https://custom-stage.ghorbd.com/api');
      expect(Env.mediaBaseUrl, 'https://custom-stage.ghorbd.com');
      expect(Env.isProduction, isFalse);
      expect(Env.isDevelopment, isTrue);
    });

    test('Env timeouts are properly configured to 15 seconds', () {
      expect(Env.connectTimeout, const Duration(seconds: 15));
      expect(Env.receiveTimeout, const Duration(seconds: 15));
      expect(Env.sendTimeout, const Duration(seconds: 15));
    });
  });
}
