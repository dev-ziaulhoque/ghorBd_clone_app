import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../domain/repositories/land_repository.dart';
import '../datasources/land_remote_data_source.dart';

class LandRepositoryImpl implements LandRepository {
  final LandRemoteDataSource remoteDataSource;

  LandRepositoryImpl({required this.remoteDataSource});

  @override
  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
          })>> getLandListings(ListingFilterParams params) async {
    try {
      final result = await remoteDataSource.getLandListings(params);
      return Right((
        listings: result.listings.map((m) => m.toEntity()).toList(),
        total: result.total,
        totalPages: result.totalPages,
      ));
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
