import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;
  const GetFavoritesUseCase(this.repository);

  Future<Either<Failure, List<ListingEntity>>> call() => repository.getFavorites();
}

class AddFavoriteUseCase {
  final FavoritesRepository repository;
  const AddFavoriteUseCase(this.repository);

  Future<Either<Failure, bool>> call(String listingId) => repository.addFavorite(listingId);
}

class RemoveFavoriteUseCase {
  final FavoritesRepository repository;
  const RemoveFavoriteUseCase(this.repository);

  Future<Either<Failure, bool>> call(String listingId) => repository.removeFavorite(listingId);
}
