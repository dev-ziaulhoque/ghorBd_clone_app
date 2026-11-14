import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/area_entity.dart';
import '../entities/facets_entity.dart';
import '../entities/listing_entity.dart';

abstract class BrowseRepository {
  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
            ListingFacetsEntity? facets,
          })>> getListings(ListingFilterParams params);

  Future<Either<Failure, ({ListingEntity listing, List<ListingEntity> similar})>>
      getListingDetail(String idOrSlug);

  Future<
      Either<
          Failure,
          ({
            List<ListingEntity> listings,
            int total,
            int totalPages,
            ListingFacetsEntity facets,
          })>> searchListings(ListingFilterParams params);

  Future<Either<Failure, List<AreaEntity>>> getAreas({bool? popular});
}
