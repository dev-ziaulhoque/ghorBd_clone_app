import 'dart:async';
import 'secure_storage.dart';

enum SessionStatus {
  unauthenticated,
  authenticated,
  expired,
}

class SessionManager {
  final AppSecureStorage _secureStorage;
  final Duration idleTimeout;
  final Future<void> Function()? onSessionExpired;

  DateTime? _lastActivityTime;
  Timer? _idleCheckTimer;
  final _statusController = StreamController<SessionStatus>.broadcast();
  SessionStatus _currentStatus = SessionStatus.unauthenticated;

  SessionManager({
    required AppSecureStorage secureStorage,
    this.idleTimeout = const Duration(minutes: 30),
    this.onSessionExpired,
  }) : _secureStorage = secureStorage;

  Stream<SessionStatus> get statusStream => _statusController.stream;
  SessionStatus get currentStatus => _currentStatus;
  DateTime? get lastActivityTime => _lastActivityTime;

  Future<void> initialize() async {
    final hasSession = await _secureStorage.hasValidSession();
    if (hasSession) {
      _currentStatus = SessionStatus.authenticated;
      _lastActivityTime = DateTime.now();
      _startIdleTimer();
    } else {
      _currentStatus = SessionStatus.unauthenticated;
    }
    _statusController.add(_currentStatus);
  }

  void recordActivity() {
    if (_currentStatus == SessionStatus.authenticated) {
      _lastActivityTime = DateTime.now();
    }
  }

  Future<void> startSession({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? userRole,
    String? userEmail,
  }) async {
    await _secureStorage.saveUserSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      userRole: userRole,
      userEmail: userEmail,
    );

    _lastActivityTime = DateTime.now();
    _currentStatus = SessionStatus.authenticated;
    _statusController.add(_currentStatus);
    _startIdleTimer();
  }

  Future<void> endSession() async {
    _idleCheckTimer?.cancel();
    _idleCheckTimer = null;
    _lastActivityTime = null;

    await _secureStorage.clearAll();
    _currentStatus = SessionStatus.unauthenticated;
    _statusController.add(_currentStatus);
  }

  Future<void> handleSessionTimeout() async {
    _idleCheckTimer?.cancel();
    _idleCheckTimer = null;
    _lastActivityTime = null;

    await _secureStorage.clearAll();
    _currentStatus = SessionStatus.expired;
    _statusController.add(_currentStatus);

    if (onSessionExpired != null) {
      await onSessionExpired!();
    }
  }

  void _startIdleTimer() {
    _idleCheckTimer?.cancel();
    // Periodically check for idle timeout
    _idleCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkIdleTimeout();
    });
  }

  Future<bool> checkIdleTimeout() async {
    if (_currentStatus != SessionStatus.authenticated || _lastActivityTime == null) {
      return false;
    }

    final elapsed = DateTime.now().difference(_lastActivityTime!);
    if (elapsed >= idleTimeout) {
      await handleSessionTimeout();
      return true;
    }
    return false;
  }

  void dispose() {
    _idleCheckTimer?.cancel();
    _statusController.close();
  }
}
