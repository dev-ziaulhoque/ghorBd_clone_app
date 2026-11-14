import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../repositories/land_repository.dart';

class GetLandListingsUseCase {
  final LandRepository repository;
  const GetLandListingsUseCase(this.repository);

  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
          })>> call(ListingFilterParams params) {
    return repository.getLandListings(params);
  }
}
