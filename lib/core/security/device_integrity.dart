import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

enum DeviceSecurityStatus {
  secure,
  jailbrokenOrRooted,
  developerMode,
  unknown,
}

abstract class DeviceIntegrityService {
  Future<bool> isCompromised();
  Future<DeviceSecurityStatus> checkSecurityStatus();
}

class DeviceIntegrityServiceImpl implements DeviceIntegrityService {
  final bool _allowInDebug;

  DeviceIntegrityServiceImpl({bool allowInDebug = true})
      : _allowInDebug = allowInDebug;

  @override
  Future<bool> isCompromised() async {
    // In debug mode or non-mobile platforms (like test VM), do not block
    if (kDebugMode && _allowInDebug) {
      return false;
    }

    try {
      final isJailbroken = await FlutterJailbreakDetection.jailbroken;
      return isJailbroken;
    } catch (e) {
      debugPrint('Device integrity check failed or unsupported: $e');
      return false;
    }
  }

  @override
  Future<DeviceSecurityStatus> checkSecurityStatus() async {
    try {
      final isJailbroken = await FlutterJailbreakDetection.jailbroken;
      if (isJailbroken) {
        return DeviceSecurityStatus.jailbrokenOrRooted;
      }

      final isDevMode = await FlutterJailbreakDetection.developerMode;
      if (isDevMode) {
        return DeviceSecurityStatus.developerMode;
      }

      return DeviceSecurityStatus.secure;
    } catch (e) {
      debugPrint('Device security status check failed: $e');
      return DeviceSecurityStatus.unknown;
    }
  }
}
