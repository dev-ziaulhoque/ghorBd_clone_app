import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/facets_entity.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/browse_repository.dart';
import '../datasources/browse_remote_data_source.dart';

class BrowseRepositoryImpl implements BrowseRepository {
  final BrowseRemoteDataSource _remoteDataSource;

  BrowseRepositoryImpl({required BrowseRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

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
    try {
      final models = await _remoteDataSource.getAreas(popular: popular);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
