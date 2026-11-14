import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../browse/data/models/listing_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<ListingModel>> getFavorites();
  Future<bool> addFavorite(String listingId);
  Future<bool> removeFavorite(String listingId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final DioClient dioClient;
  FavoritesRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ListingModel>> getFavorites() async {
    final response = await dioClient.get(ApiEndpoints.favorites);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> addFavorite(String listingId) async {
    final response = await dioClient.post(ApiEndpoints.listingFavorite(listingId));
    final data = response.data['data'] as Map<String, dynamic>?;
    return data?['favorited'] as bool? ?? true;
  }

  @override
  Future<bool> removeFavorite(String listingId) async {
    final response = await dioClient.delete(ApiEndpoints.listingFavorite(listingId));
    final data = response.data['data'] as Map<String, dynamic>?;
    return (data?['favorited'] as bool?) == false;
  }
}
