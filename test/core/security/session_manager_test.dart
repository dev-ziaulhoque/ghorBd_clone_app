import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/security/secure_storage.dart';
import 'package:ghorbad_clone_app/core/security/session_manager.dart';
import 'secure_storage_test.dart';

void main() {
  late FakeFlutterSecureStorage fakeStorage;
  late AppSecureStorage secureStorage;
  late SessionManager sessionManager;
  late List<SessionStatus> recordedStatuses;
  var onSessionExpiredCalled = false;

  setUp(() {
    fakeStorage = FakeFlutterSecureStorage();
    secureStorage = AppSecureStorage(storage: fakeStorage);
    recordedStatuses = [];
    onSessionExpiredCalled = false;

    sessionManager = SessionManager(
      secureStorage: secureStorage,
      idleTimeout: const Duration(milliseconds: 100),
      onSessionExpired: () async {
        onSessionExpiredCalled = true;
      },
    );

    sessionManager.statusStream.listen(recordedStatuses.add);
  });

  tearDown(() {
    sessionManager.dispose();
  });

  group('SessionManager', () {
    test('initializes as unauthenticated when no tokens exist', () async {
      await sessionManager.initialize();
      await Future<void>.delayed(Duration.zero);

      expect(sessionManager.currentStatus, SessionStatus.unauthenticated);
      expect(recordedStatuses, contains(SessionStatus.unauthenticated));
    });

    test('initializes as authenticated when existing tokens are found', () async {
      await secureStorage.saveTokens(
        accessToken: 'access_abc',
        refreshToken: 'refresh_xyz',
      );

      await sessionManager.initialize();
      await Future<void>.delayed(Duration.zero);

      expect(sessionManager.currentStatus, SessionStatus.authenticated);
      expect(sessionManager.lastActivityTime, isNotNull);
      expect(recordedStatuses, contains(SessionStatus.authenticated));
    });

    test('startSession stores tokens, sets authenticated status and updates activity', () async {
      await sessionManager.startSession(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
        userId: 'uid_1',
        userRole: 'tenant',
      );
      await Future<void>.delayed(Duration.zero);

      expect(sessionManager.currentStatus, SessionStatus.authenticated);
      expect(await secureStorage.getAccessToken(), 'new_access');
      expect(await secureStorage.getRefreshToken(), 'new_refresh');
      expect(sessionManager.lastActivityTime, isNotNull);
      expect(recordedStatuses, contains(SessionStatus.authenticated));
    });

    test('recordActivity updates lastActivityTime', () async {
      await sessionManager.startSession(
        accessToken: 'token',
        refreshToken: 'refresh',
      );

      final initialTime = sessionManager.lastActivityTime!;
      await Future<void>.delayed(const Duration(milliseconds: 10));

      sessionManager.recordActivity();
      final updatedTime = sessionManager.lastActivityTime!;

      expect(updatedTime.isAfter(initialTime), isTrue);
    });

    test('endSession clears storage and sets status to unauthenticated', () async {
      await sessionManager.startSession(
        accessToken: 'token',
        refreshToken: 'refresh',
      );
      expect(sessionManager.currentStatus, SessionStatus.authenticated);

      await sessionManager.endSession();
      await Future<void>.delayed(Duration.zero);

      expect(sessionManager.currentStatus, SessionStatus.unauthenticated);
      expect(await secureStorage.hasValidSession(), isFalse);
      expect(recordedStatuses.last, SessionStatus.unauthenticated);
    });

    test('idle timeout triggers session expiration and invokes onSessionExpired', () async {
      await sessionManager.startSession(
        accessToken: 'token',
        refreshToken: 'refresh',
      );

      expect(await sessionManager.checkIdleTimeout(), isFalse);

      // Wait past the 100ms timeout
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final timedOut = await sessionManager.checkIdleTimeout();
      await Future<void>.delayed(Duration.zero);

      expect(timedOut, isTrue);
      expect(sessionManager.currentStatus, SessionStatus.expired);
      expect(onSessionExpiredCalled, isTrue);
      expect(await secureStorage.hasValidSession(), isFalse);
    });
  });
}
