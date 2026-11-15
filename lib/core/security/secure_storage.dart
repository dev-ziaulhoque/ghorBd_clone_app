import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  final FlutterSecureStorage _storage;

  AppSecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const String _keyAccessToken = 'ghorbd_access_token';
  static const String _keyRefreshToken = 'ghorbd_refresh_token';
  static const String _keyUserId = 'ghorbd_user_id';
  static const String _keyUserRole = 'ghorbd_user_role';
  static const String _keyUserEmail = 'ghorbd_user_email';
  static const String _keyUserName = 'ghorbd_user_name';
  static const String _keyUserPhone = 'ghorbd_user_phone';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserSession({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? userRole,
    String? userEmail,
    String? userName,
    String? userPhone,
  }) async {
    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    if (userId != null) {
      await _storage.write(key: _keyUserId, value: userId);
    }
    if (userRole != null) {
      await _storage.write(key: _keyUserRole, value: userRole);
    }
    if (userEmail != null) {
      await _storage.write(key: _keyUserEmail, value: userEmail);
    }
    if (userName != null) {
      await _storage.write(key: _keyUserName, value: userName);
    }
    if (userPhone != null) {
      await _storage.write(key: _keyUserPhone, value: userPhone);
    }
  }

  Future<String?> getUserId() => _storage.read(key: _keyUserId);
  Future<String?> getUserRole() => _storage.read(key: _keyUserRole);
  Future<String?> getUserEmail() => _storage.read(key: _keyUserEmail);
  Future<String?> getUserName() => _storage.read(key: _keyUserName);
  Future<String?> getUserPhone() => _storage.read(key: _keyUserPhone);

  Future<bool> hasValidSession() async {
    final refreshToken = await getRefreshToken();
    final accessToken = await getAccessToken();
    final userId = await getUserId();
    return (refreshToken != null && refreshToken.trim().isNotEmpty) ||
        (accessToken != null && accessToken.trim().isNotEmpty) ||
        (userId != null && userId.trim().isNotEmpty);
  }

  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUserRole),
      _storage.delete(key: _keyUserEmail),
      _storage.delete(key: _keyUserName),
      _storage.delete(key: _keyUserPhone),
    ]);
  }

  // Generic key/value access
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
}
