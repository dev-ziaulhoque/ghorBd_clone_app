import 'dart:async';

import 'package:fpdart/fpdart.dart';
import '../../../../core/cache/response_cache.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pricing_plan_entity.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../datasources/pricing_remote_data_source.dart';
import '../models/pricing_plan_model.dart';

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource remoteDataSource;

  /// Optional response cache (Round 2): pricing plans are slow-changing,
  /// served stale-while-revalidate with a 12 h TTL. Null in existing
  /// tests -> network-only behaviour.
  final ResponseCache? _cache;

  static const String _cacheKey = 'pricing_plans';

  PricingRepositoryImpl({required this.remoteDataSource, ResponseCache? cache})
      : _cache = cache;

  @override
  Future<Either<Failure, List<PricingPlanEntity>>> getPricingPlans() async {
    final cache = _cache;
    if (cache != null) {
      final entry = await cache.read(_cacheKey);
      if (entry != null) {
        try {
          final cached = (entry.data as List<dynamic>)
              .map((j) => PricingPlanModel.fromJson(j as Map<String, dynamic>))
              .map((m) => m.toEntity())
              .toList();
          if (entry.isStale(ResponseCache.pricingTtl)) {
            unawaited(_refresh());
          }
          return Right(cached);
        } catch (_) {
          // Corrupt payload - fall through to the network.
        }
      }
    }
    try {
      final models = await remoteDataSource.getPricingPlans();
      if (cache != null) {
        unawaited(
          cache.write(_cacheKey, models.map((m) => m.toJson()).toList()),
        );
      }
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<void> _refresh() async {
    final cache = _cache;
    if (cache == null) return;
    try {
      final models = await remoteDataSource.getPricingPlans();
      await cache.write(_cacheKey, models.map((m) => m.toJson()).toList());
    } catch (_) {
      // Keep serving the stale entry.
    }
  }
}
