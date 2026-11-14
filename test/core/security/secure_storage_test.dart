import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/security/secure_storage.dart';

class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear();
  }
}

void main() {
  late FakeFlutterSecureStorage fakeStorage;
  late AppSecureStorage secureStorage;

  setUp(() {
    fakeStorage = FakeFlutterSecureStorage();
    secureStorage = AppSecureStorage(storage: fakeStorage);
  });

  group('AppSecureStorage', () {
    test('saveTokens and getAccessToken / getRefreshToken', () async {
      expect(await secureStorage.getAccessToken(), isNull);
      expect(await secureStorage.getRefreshToken(), isNull);
      expect(await secureStorage.hasValidSession(), isFalse);

      await secureStorage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      expect(await secureStorage.getAccessToken(), 'access_123');
      expect(await secureStorage.getRefreshToken(), 'refresh_456');
      expect(await secureStorage.hasValidSession(), isTrue);
    });

    test('saveUserSession saves tokens and user profile metadata', () async {
      await secureStorage.saveUserSession(
        accessToken: 'access_token_jwt',
        refreshToken: 'refresh_token_jwt',
        userId: 'user_6735a2b1f8e123456789abcd',
        userRole: 'owner',
        userEmail: 'owner@ghorbd.com',
      );

      expect(await secureStorage.getAccessToken(), 'access_token_jwt');
      expect(await secureStorage.getRefreshToken(), 'refresh_token_jwt');
      expect(await secureStorage.getUserId(), 'user_6735a2b1f8e123456789abcd');
      expect(await secureStorage.getUserRole(), 'owner');
      expect(await secureStorage.getUserEmail(), 'owner@ghorbd.com');
      expect(await secureStorage.hasValidSession(), isTrue);
    });

    test('clearAll removes all session tokens and credentials', () async {
      await secureStorage.saveUserSession(
        accessToken: 'access_token_jwt',
        refreshToken: 'refresh_token_jwt',
        userId: 'user_123',
        userRole: 'tenant',
        userEmail: 'tenant@ghorbd.com',
      );

      expect(await secureStorage.hasValidSession(), isTrue);

      await secureStorage.clearAll();

      expect(await secureStorage.getAccessToken(), isNull);
      expect(await secureStorage.getRefreshToken(), isNull);
      expect(await secureStorage.getUserId(), isNull);
      expect(await secureStorage.getUserRole(), isNull);
      expect(await secureStorage.getUserEmail(), isNull);
      expect(await secureStorage.hasValidSession(), isFalse);
    });

    test('generic write, read, and delete operations', () async {
      expect(await secureStorage.read('custom_key'), isNull);

      await secureStorage.write('custom_key', 'custom_value');
      expect(await secureStorage.read('custom_key'), 'custom_value');

      await secureStorage.delete('custom_key');
      expect(await secureStorage.read('custom_key'), isNull);
    });
  });
}
