import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/listing_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<ListingEntity>>> getFavorites();
  Future<Either<Failure, bool>> addFavorite(String listingId);
  Future<Either<Failure, bool>> removeFavorite(String listingId);
}
