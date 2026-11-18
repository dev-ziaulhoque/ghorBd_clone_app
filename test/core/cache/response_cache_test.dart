import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/cache/response_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResponseCache (Round 2)', () {
    test('write then read returns payload from memory and persists it',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = ResponseCache(prefs);

      await cache.write('areas_popular', [
        {'id': 'a1', 'name': 'Uttara'},
      ]);

      final entry = await cache.read('areas_popular');
      expect(entry, isNotNull);
      expect((entry!.data as List).length, 1);
      expect(entry.isStale(ResponseCache.areasTtl), isFalse);

      // Persisted under the documented key with a timestamp envelope.
      final raw = prefs.getString('ghorbd_cache_areas_popular');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['t'], isA<int>());
      expect(decoded['d'], isA<List>());
    });

    test('a new instance reads the persisted entry (survives restart)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await ResponseCache(prefs).write('pricing_plans', [
        {'id': 'p1'},
      ]);

      final entry = await ResponseCache(prefs).read('pricing_plans');
      expect(entry, isNotNull);
      expect((entry!.data as List).single['id'], 'p1');
    });

    test('stale detection honours the TTL', () async {
      final old = CacheEntry(
        data: const [],
        fetchedAt: DateTime.now().subtract(const Duration(hours: 13)),
      );
      expect(old.isStale(ResponseCache.areasTtl), isTrue);
      expect(old.isStale(ResponseCache.staticContentTtl), isFalse);
    });

    test('write notifies listeners and records lastChangedKey', () async {
      final cache = ResponseCache();
      var notified = 0;
      cache.addListener(() => notified++);

      await cache.write('areas_popular', const []);
      expect(notified, 1);
      expect(cache.lastChangedKey, 'areas_popular');

      await cache.write('pricing_plans', const []);
      expect(notified, 2);
      expect(cache.lastChangedKey, 'pricing_plans');
    });

    test('corrupt persisted payload is treated as a miss', () async {
      SharedPreferences.setMockInitialValues({
        'ghorbd_cache_areas_popular': 'not-json{{{',
      });
      final prefs = await SharedPreferences.getInstance();
      final cache = ResponseCache(prefs);

      expect(await cache.read('areas_popular'), isNull);
      expect(prefs.getString('ghorbd_cache_areas_popular'), isNull);
    });

    test('miss returns null; remove deletes the entry', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = ResponseCache(prefs);

      expect(await cache.read('nope'), isNull);
      await cache.write('nope', 42);
      expect((await cache.read('nope'))!.data, 42);
      await cache.remove('nope');
      expect(await cache.read('nope'), isNull);
    });
  });
}
