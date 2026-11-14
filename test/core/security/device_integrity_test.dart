import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/security/device_integrity.dart';

void main() {
  group('DeviceIntegrityService', () {
    test('isCompromised returns false in debug mode', () async {
      final service = DeviceIntegrityServiceImpl(allowInDebug: true);
      final isCompromised = await service.isCompromised();
      expect(isCompromised, isFalse);
    });

    test('checkSecurityStatus returns status safely without crashing', () async {
      final service = DeviceIntegrityServiceImpl();
      final status = await service.checkSecurityStatus();
      expect(
        status,
        anyOf([
          DeviceSecurityStatus.secure,
          DeviceSecurityStatus.unknown,
          DeviceSecurityStatus.developerMode,
          DeviceSecurityStatus.jailbrokenOrRooted,
        ]),
      );
    });
  });
}
