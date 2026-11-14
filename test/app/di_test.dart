import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/core/network/dio_client.dart';

void main() {
  group('Dependency Injection (get_it)', () {
    tearDown(() async {
      await resetDependencies();
    });

    test('configureDependencies registers DioClient as singleton', () async {
      expect(sl.isRegistered<DioClient>(), isFalse);

      await configureDependencies();

      expect(sl.isRegistered<DioClient>(), isTrue);
      final client1 = sl<DioClient>();
      final client2 = sl<DioClient>();
      expect(identical(client1, client2), isTrue);
    });

    test('resetDependencies clears registrations', () async {
      await configureDependencies();
      expect(sl.isRegistered<DioClient>(), isTrue);

      await resetDependencies();
      expect(sl.isRegistered<DioClient>(), isFalse);
    });
  });
}
