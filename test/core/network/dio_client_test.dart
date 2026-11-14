import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/config/env.dart';
import 'package:ghorbad_clone_app/core/network/dio_client.dart';
import 'package:ghorbad_clone_app/core/network/interceptors/error_interceptor.dart';
import 'package:ghorbad_clone_app/core/network/interceptors/logging_interceptor.dart';
import 'package:ghorbad_clone_app/core/network/interceptors/retry_interceptor.dart';

void main() {
  group('DioClient', () {
    test('initializes default Dio with Env options and interceptors', () {
      final client = DioClient();

      expect(client.dio.options.baseUrl, Env.baseUrl);
      expect(client.dio.options.connectTimeout, Env.connectTimeout);
      expect(client.dio.options.receiveTimeout, Env.receiveTimeout);
      expect(client.dio.options.sendTimeout, Env.sendTimeout);
      expect(client.dio.options.headers['Accept'], 'application/json');
      expect(client.dio.options.headers['Content-Type'], 'application/json');

      final interceptorTypes = client.dio.interceptors.map((i) => i.runtimeType).toList();
      expect(interceptorTypes, contains(RetryInterceptor));
      expect(interceptorTypes, contains(LoggingInterceptor));
      expect(interceptorTypes, contains(ErrorInterceptor));
    });

    test('accepts custom Dio instance', () {
      final customDio = Dio(BaseOptions(baseUrl: 'https://custom.api'));
      final client = DioClient(customDio: customDio);

      expect(client.dio.options.baseUrl, 'https://custom.api');
    });
  });
}
