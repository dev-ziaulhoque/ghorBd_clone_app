import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegistrationResultModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? listerType,
  });

  Future<AuthSessionModel> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<bool> resendEmailOtp({
    required String email,
  });

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<bool> forgotPassword({
    required String email,
  });

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl({required DioClient client}) : _client = client;

  Options get _noAuthOptions => Options(
        extra: {AuthInterceptor.noAuthHeaderKey: true},
      );

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return <String, dynamic>{};
  }

  @override
  Future<RegistrationResultModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? listerType,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
          if (listerType != null) 'listerType': listerType,
        },
        options: _noAuthOptions,
      );

      final data = _extractData(response.data);
      return RegistrationResultModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthSessionModel> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.verifyEmailOtp,
        data: {
          'email': email,
          'otp': otp,
        },
        options: _noAuthOptions,
      );

      final data = _extractData(response.data);
      return AuthSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> resendEmailOtp({required String email}) async {
    try {
      final response = await _client.post(
        ApiEndpoints.resendEmailOtp,
        data: {'email': email},
        options: _noAuthOptions,
      );

      final data = _extractData(response.data);
      return data['sent'] as bool? ?? true;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
        options: _noAuthOptions,
      );

      final data = _extractData(response.data);
      return AuthSessionModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _client.get(ApiEndpoints.me);
      final data = _extractData(response.data);
      final userJson = data['user'];
      if (userJson == null) return null;
      return UserModel.fromJson(userJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _client.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
        options: _noAuthOptions,
      );

      final data = _extractData(response.data);
      return data['sent'] as bool? ?? true;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'password': newPassword,
        },
        options: _noAuthOptions,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.error is Exception) {
      return error.error as Exception;
    }
    return ServerException(error.message ?? 'Server error', error.response?.statusCode);
  }
}
