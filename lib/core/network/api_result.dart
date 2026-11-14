import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';

class PaginationMeta extends Equatable {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      perPage: json['perPage'] as int? ?? (json['limit'] as int? ?? 12),
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'perPage': perPage,
        'total': total,
        'totalPages': totalPages,
      };

  @override
  List<Object?> get props => [page, perPage, total, totalPages];
}

class ApiErrorResponse extends Equatable {
  final String code;
  final String message;
  final List<ApiErrorDetail> details;

  const ApiErrorResponse({
    required this.code,
    required this.message,
    this.details = const [],
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final dynamic errorObj = json['error'] ?? json;
    if (errorObj is Map<String, dynamic>) {
      final detailsList = (errorObj['details'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ApiErrorDetail.fromJson)
              .toList() ??
          const [];

      return ApiErrorResponse(
        code: errorObj['code']?.toString() ?? 'UNKNOWN_ERROR',
        message: errorObj['message']?.toString() ?? 'An unexpected error occurred',
        details: detailsList,
      );
    }

    return const ApiErrorResponse(
      code: 'UNKNOWN_ERROR',
      message: 'An unexpected error occurred',
      details: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'error': {
          'code': code,
          'message': message,
          if (details.isNotEmpty)
            'details': details.map((d) => d.toJson()).toList(),
        },
      };

  @override
  List<Object?> get props => [code, message, details];
}

sealed class ApiResult<T> extends Equatable {
  const ApiResult();

  const factory ApiResult.success(T data, {PaginationMeta? meta}) = ApiSuccess<T>;
  const factory ApiResult.failure(ApiErrorResponse error, {int? statusCode}) = ApiFailure<T>;

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccess<T>(data: final d) => d,
        _ => null,
      };

  ApiErrorResponse? get errorOrNull => switch (this) {
        ApiFailure<T>(error: final err) => err,
        _ => null,
      };

  PaginationMeta? get metaOrNull => switch (this) {
        ApiSuccess<T>(meta: final m) => m,
        _ => null,
      };

  R when<R>({
    required R Function(T data, PaginationMeta? meta) success,
    required R Function(ApiErrorResponse error, int? statusCode) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(data: final d, meta: final m) => success(d, m),
      ApiFailure<T>(error: final err, statusCode: final status) => failure(err, status),
    };
  }

  Either<Failure, T> toEither() {
    return switch (this) {
      ApiSuccess<T>(data: final d) => Right(d),
      ApiFailure<T>(error: final err, statusCode: final status) =>
        Left(mapApiErrorToFailure(err, statusCode: status)),
    };
  }

  factory ApiResult.fromResponse(
    dynamic json,
    T Function(dynamic dataJson) fromJsonT, {
    int? statusCode,
  }) {
    if (json is Map<String, dynamic> && json.containsKey('error')) {
      return ApiFailure(
        ApiErrorResponse.fromJson(json),
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 400) {
      final error = json is Map<String, dynamic>
          ? ApiErrorResponse.fromJson(json)
          : ApiErrorResponse(
              code: 'HTTP_$statusCode',
              message: 'Request failed with status $statusCode',
            );
      return ApiFailure(error, statusCode: statusCode);
    }

    if (json is Map<String, dynamic>) {
      final PaginationMeta? meta = json['meta'] is Map<String, dynamic>
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null;

      final dynamic payload = json.containsKey('data') ? json['data'] : json;
      return ApiSuccess(fromJsonT(payload), meta: meta);
    }

    return ApiSuccess(fromJsonT(json));
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  final PaginationMeta? meta;

  const ApiSuccess(this.data, {this.meta});

  @override
  List<Object?> get props => [data, meta];
}

class ApiFailure<T> extends ApiResult<T> {
  final ApiErrorResponse error;
  final int? statusCode;

  const ApiFailure(this.error, {this.statusCode});

  @override
  List<Object?> get props => [error, statusCode];
}
