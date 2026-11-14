import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../entities/place_entity.dart';

abstract class MapRepository {
  Future<Either<Failure, List<PlaceEntity>>> searchPlaces(String query);
  Future<Either<Failure, PlaceEntity?>> reverseGeocode(double lat, double lng);
  Future<Either<Failure, List<ListingEntity>>> getMapListings(
    ListingFilterParams params,
  );
}
