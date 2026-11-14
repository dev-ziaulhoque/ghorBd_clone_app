import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../browse/data/models/listing_model.dart';
import '../../../browse/domain/entities/facets_entity.dart';

abstract class LandRemoteDataSource {
  Future<({List<ListingModel> listings, int total, int totalPages})>
      getLandListings(ListingFilterParams params);
}

class LandRemoteDataSourceImpl implements LandRemoteDataSource {
  final DioClient dioClient;

  LandRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<({List<ListingModel> listings, int total, int totalPages})>
      getLandListings(ListingFilterParams params) async {
    final query = params.toQueryParameters();
    // Enforce propertyType=land for land marketplace
    query['propertyType'] = 'land';

    final response = await dioClient.get(
      ApiEndpoints.listings,
      queryParameters: query,
    );

    final rawData = response.data['data'] as List<dynamic>? ?? [];
    final listings = rawData
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final meta = response.data['meta'] as Map<String, dynamic>? ?? {};
    final total = meta['total'] as int? ?? listings.length;
    final totalPages = meta['totalPages'] as int? ?? 1;

    return (listings: listings, total: total, totalPages: totalPages);
  }
}
