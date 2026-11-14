import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';

abstract class LandRepository {
  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
          })>> getLandListings(ListingFilterParams params);
}
