import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to handle Screen Protection (preventing screenshots / screen recordings on sensitive screens,
/// and blurring/hiding app preview in the recent apps switcher).
abstract class ScreenProtectionService {
  Future<bool> enableProtection();
  Future<bool> disableProtection();
}

class ScreenProtectionServiceImpl implements ScreenProtectionService {
  static const MethodChannel _channel =
      MethodChannel('com.ghorbd.app/screen_protection');

  @override
  Future<bool> enableProtection() async {
    if (kIsWeb) return false;
    try {
      final result = await _channel.invokeMethod<bool>('enableSecure');
      return result ?? true;
    } on PlatformException catch (e) {
      debugPrint('ScreenProtection: Failed to enable secure screen: $e');
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> disableProtection() async {
    if (kIsWeb) return false;
    try {
      final result = await _channel.invokeMethod<bool>('disableSecure');
      return result ?? true;
    } on PlatformException catch (e) {
      debugPrint('ScreenProtection: Failed to disable secure screen: $e');
      return false;
    } catch (_) {
      return false;
    }
  }
}
