import 'package:equatable/equatable.dart';

class ApiErrorDetail extends Equatable {
  final String path;
  final String message;

  const ApiErrorDetail({
    required this.path,
    required this.message,
  });

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      path: json['path']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'message': message,
      };

  @override
  List<Object?> get props => [path, message];
}

class ApiException implements Exception, Equatable {
  final String code;
  final String message;
  final int? statusCode;
  final List<ApiErrorDetail> details;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details = const [],
  });

  @override
  List<Object?> get props => [code, message, statusCode, details];

  @override
  bool? get stringify => true;

  @override
  String toString() =>
      'ApiException(code: $code, message: $message, statusCode: $statusCode, details: $details)';
}

class NetworkException implements Exception, Equatable {
  final String message;

  const NetworkException([this.message = 'No internet connection or network failure']);

  @override
  List<Object?> get props => [message];

  @override
  bool? get stringify => true;

  @override
  String toString() => 'NetworkException($message)';
}

class NetworkTimeoutException extends NetworkException {
  const NetworkTimeoutException([
    super.message = 'Connection timed out. Please try again.',
  ]);

  @override
  String toString() => 'NetworkTimeoutException($message)';
}

class ServerException implements Exception, Equatable {
  final String message;
  final int? statusCode;

  const ServerException([
    this.message = 'Server error occurred',
    this.statusCode,
  ]);

  @override
  List<Object?> get props => [message, statusCode];

  @override
  bool? get stringify => true;

  @override
  String toString() => 'ServerException($statusCode: $message)';
}

class CacheException implements Exception, Equatable {
  final String message;

  const CacheException([this.message = 'Cache failure occurred']);

  @override
  List<Object?> get props => [message];

  @override
  bool? get stringify => true;

  @override
  String toString() => 'CacheException($message)';
}

class UnknownException implements Exception, Equatable {
  final String message;

  const UnknownException([this.message = 'An unexpected error occurred']);

  @override
  List<Object?> get props => [message];

  @override
  bool? get stringify => true;

  @override
  String toString() => 'UnknownException($message)';
}
