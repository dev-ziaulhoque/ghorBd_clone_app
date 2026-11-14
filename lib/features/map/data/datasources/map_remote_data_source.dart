import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../browse/data/models/listing_model.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../models/place_model.dart';

abstract class MapRemoteDataSource {
  Future<List<PlaceModel>> searchPlaces(String query);
  Future<PlaceModel?> reverseGeocode(double lat, double lng);
  Future<List<ListingModel>> getMapListings(ListingFilterParams params);
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final DioClient dioClient;

  MapRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<PlaceModel>> searchPlaces(String query) async {
    final response = await dioClient.get(
      ApiEndpoints.geoSearch,
      queryParameters: {'q': query},
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => PlaceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PlaceModel?> reverseGeocode(double lat, double lng) async {
    final response = await dioClient.get(
      ApiEndpoints.geoReverse,
      queryParameters: {'lat': lat, 'lng': lng},
    );
    final data = response.data['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return PlaceModel.fromJson(data);
  }

  @override
  Future<List<ListingModel>> getMapListings(ListingFilterParams params) async {
    final response = await dioClient.get(
      ApiEndpoints.listings,
      queryParameters: params.toQueryParameters(),
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
