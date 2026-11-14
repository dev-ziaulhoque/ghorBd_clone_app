import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_data_source.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PlaceEntity>>> searchPlaces(String query) async {
    try {
      final models = await remoteDataSource.searchPlaces(query);
      return Right(models);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlaceEntity?>> reverseGeocode(
    double lat,
    double lng,
  ) async {
    try {
      final model = await remoteDataSource.reverseGeocode(lat, lng);
      return Right(model);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getMapListings(
    ListingFilterParams params,
  ) async {
    try {
      final models = await remoteDataSource.getMapListings(params);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
