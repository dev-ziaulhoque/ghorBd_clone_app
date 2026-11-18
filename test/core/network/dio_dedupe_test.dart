import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/network/dio_client.dart';

class _CountingAdapter implements HttpClientAdapter {
  int calls = 0;
  static const Duration delay = Duration(milliseconds: 60);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    await Future<void>.delayed(delay);
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DioClient GET dedupe (Round 2)', () {
    late _CountingAdapter adapter;
    late DioClient client;

    setUp(() {
      adapter = _CountingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
      dio.httpClientAdapter = adapter;
      client = DioClient(customDio: dio);
    });

    test('identical concurrent GETs share one network call', () async {
      final results = await Future.wait([
        client.get('/listings', queryParameters: {'page': 1}),
        client.get('/listings', queryParameters: {'page': 1}),
        client.get('/listings', queryParameters: {'page': 1}),
      ]);

      expect(adapter.calls, 1);
      for (final r in results) {
        expect(r.data['ok'], isTrue);
      }
    });

    test('query parameter order does not defeat dedupe', () async {
      await Future.wait([
        client.get('/listings', queryParameters: {'a': 1, 'b': 2}),
        client.get('/listings', queryParameters: {'b': 2, 'a': 1}),
      ]);
      expect(adapter.calls, 1);
    });

    test('different queries are not deduped', () async {
      await Future.wait([
        client.get('/listings', queryParameters: {'page': 1}),
        client.get('/listings', queryParameters: {'page': 2}),
      ]);
      expect(adapter.calls, 2);
    });

    test('settled requests are evicted: a later identical GET re-fetches',
        () async {
      await client.get('/areas');
      await client.get('/areas');
      expect(adapter.calls, 2);
    });

    test('persistentConnection is enabled on the default client', () {
      final defaultClient = DioClient();
      expect(defaultClient.dio.options.persistentConnection, isTrue);
    });
  });
}
