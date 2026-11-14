import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ListingEntity>>> getFavorites() async {
    try {
      final models = await remoteDataSource.getFavorites();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addFavorite(String listingId) async {
    try {
      final result = await remoteDataSource.addFavorite(listingId);
      return Right(result);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFavorite(String listingId) async {
    try {
      final result = await remoteDataSource.removeFavorite(listingId);
      return Right(result);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
