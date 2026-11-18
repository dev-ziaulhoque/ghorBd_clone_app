import 'dart:async';

import 'package:fpdart/fpdart.dart';
import '../../../../core/cache/response_cache.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/facets_entity.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/browse_repository.dart';
import '../datasources/browse_remote_data_source.dart';
import '../models/area_model.dart';

class BrowseRepositoryImpl implements BrowseRepository {
  final BrowseRemoteDataSource _remoteDataSource;

  /// Optional response cache (Round 2). When present, areas are served
  /// stale-while-revalidate; when absent the repository is network-only
  /// (existing tests construct it without a cache).
  final ResponseCache? _cache;

  BrowseRepositoryImpl({
    required BrowseRemoteDataSource remoteDataSource,
    ResponseCache? cache,
  })  : _remoteDataSource = remoteDataSource,
        _cache = cache;

  /// Cache key for an areas request (also used by HomeBloc's SWR listener).
  static String areasCacheKey({bool? popular}) =>
      popular == true ? 'areas_popular' : 'areas_all';

  @override
  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
            ListingFacetsEntity? facets,
          })>> getListings(ListingFilterParams params) async {
    try {
      final result = await _remoteDataSource.getListings(params);
      return Right((
        listings: result.listings.map((m) => m.toEntity()).toList(),
        total: result.total,
        totalPages: result.totalPages,
        facets: result.facets?.toEntity(),
      ));
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({ListingEntity listing, List<ListingEntity> similar})>>
      getListingDetail(String idOrSlug) async {
    try {
      final result = await _remoteDataSource.getListingDetail(idOrSlug);
      return Right((
        listing: result.listing.toEntity(),
        similar: result.similar.map((m) => m.toEntity()).toList(),
      ));
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
            ListingFacetsEntity facets,
          })>> searchListings(ListingFilterParams params) async {
    try {
      final result = await _remoteDataSource.searchListings(params);
      return Right((
        listings: result.listings.map((m) => m.toEntity()).toList(),
        total: result.total,
        totalPages: result.totalPages,
        facets: result.facets.toEntity(),
      ));
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AreaEntity>>> getAreas({bool? popular}) async {
    final cache = _cache;
    final key = areasCacheKey(popular: popular);
    if (cache != null) {
      final entry = await cache.read(key);
      if (entry != null) {
        try {
          final cached = (entry.data as List<dynamic>)
              .map((j) => AreaModel.fromJson(j as Map<String, dynamic>))
              .map((m) => m.toEntity())
              .toList();
          if (entry.isStale(ResponseCache.areasTtl)) {
            // Serve stale instantly; refresh in the background. The
            // cache write notifies listeners (HomeBloc) which re-emit
            // with the fresh areas when they arrive.
            unawaited(_refreshAreas(key, popular: popular));
          }
          return Right(cached);
        } catch (_) {
          // Corrupt cache payload — fall through to the network.
        }
      }
    }
    try {
      final models = await _remoteDataSource.getAreas(popular: popular);
      if (cache != null) {
        unawaited(
          cache.write(key, models.map((m) => m.toJson()).toList()),
        );
      }
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Background revalidation for a stale areas entry. Failures are
  /// swallowed — the stale copy stays in place for the next attempt.
  Future<void> _refreshAreas(String key, {bool? popular}) async {
    final cache = _cache;
    if (cache == null) return;
    try {
      final models = await _remoteDataSource.getAreas(popular: popular);
      await cache.write(key, models.map((m) => m.toJson()).toList());
    } catch (_) {
      // Keep serving the stale entry.
    }
  }
}
