import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../entities/place_entity.dart';
import '../repositories/map_repository.dart';

class SearchPlacesUseCase {
  final MapRepository repository;
  const SearchPlacesUseCase(this.repository);

  Future<Either<Failure, List<PlaceEntity>>> call(String query) =>
      repository.searchPlaces(query);
}

class ReverseGeocodeUseCase {
  final MapRepository repository;
  const ReverseGeocodeUseCase(this.repository);

  Future<Either<Failure, PlaceEntity?>> call(double lat, double lng) =>
      repository.reverseGeocode(lat, lng);
}

class GetMapListingsUseCase {
  final MapRepository repository;
  const GetMapListingsUseCase(this.repository);

  Future<Either<Failure, List<ListingEntity>>> call(ListingFilterParams params) =>
      repository.getMapListings(params);
}
