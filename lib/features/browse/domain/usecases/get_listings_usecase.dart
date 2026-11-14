import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/facets_entity.dart';
import '../entities/listing_entity.dart';
import '../repositories/browse_repository.dart';

class GetListingsUseCase {
  final BrowseRepository _repository;

  GetListingsUseCase(this._repository);

  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
            ListingFacetsEntity? facets,
          })>> call(ListingFilterParams params) {
    return _repository.getListings(params);
  }
}
