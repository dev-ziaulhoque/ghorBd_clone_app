import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/facets_entity.dart';
import '../models/area_model.dart';
import '../models/facets_model.dart';
import '../models/listing_model.dart';

abstract class BrowseRemoteDataSource {
  Future<
      ({
        List<ListingModel> listings,
        int total,
        int totalPages,
        FacetsModel? facets,
      })> getListings(ListingFilterParams params);

  Future<({ListingModel listing, List<ListingModel> similar})> getListingDetail(
    String idOrSlug,
  );

  Future<
      ({
        List<ListingModel> listings,
        int total,
        int totalPages,
        FacetsModel facets,
      })> searchListings(ListingFilterParams params);

  Future<List<AreaModel>> getAreas({bool? popular});
}

class BrowseRemoteDataSourceImpl implements BrowseRemoteDataSource {
  final DioClient _dioClient;

  BrowseRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<
      ({
        List<ListingModel> listings,
        int total,
        int totalPages,
        FacetsModel? facets,
      })> getListings(ListingFilterParams params) async {
    final response = await _dioClient.get(
      ApiEndpoints.listings,
      queryParameters: params.toQueryParameters(),
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataList = responseData['data'] as List<dynamic>? ?? [];
    final meta = responseData['meta'] as Map<String, dynamic>? ?? {};

    final listings = dataList
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();

    FacetsModel? facets;
    if (meta['facets'] != null) {
      facets = FacetsModel.fromJson(meta['facets'] as Map<String, dynamic>);
    }

    return (
      listings: listings,
      total: (meta['total'] as num?)?.toInt() ?? listings.length,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      facets: facets,
    );
  }

  @override
  Future<({ListingModel listing, List<ListingModel> similar})> getListingDetail(
    String idOrSlug,
  ) async {
    final decoded = Uri.decodeComponent(idOrSlug);
    final safePath = Uri.encodeComponent(decoded);
    final response = await _dioClient.get(
      ApiEndpoints.listingDetail(safePath),
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final listingJson = (data['listing'] ?? data) as Map<String, dynamic>;
    final similarList = data['similar'] as List<dynamic>? ?? [];

    return (
      listing: ListingModel.fromJson(listingJson),
      similar: similarList
          .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<
      ({
        List<ListingModel> listings,
        int total,
        int totalPages,
        FacetsModel facets,
      })> searchListings(ListingFilterParams params) async {
    final query = params.toQueryParameters();
    query['facets'] = true;

    final response = await _dioClient.get(
      ApiEndpoints.search,
      queryParameters: query,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataList = responseData['data'] as List<dynamic>? ?? [];
    final meta = responseData['meta'] as Map<String, dynamic>? ?? {};

    final listings = dataList
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final facets = meta['facets'] != null
        ? FacetsModel.fromJson(meta['facets'] as Map<String, dynamic>)
        : const FacetsModel();

    return (
      listings: listings,
      total: (meta['total'] as num?)?.toInt() ?? listings.length,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      facets: facets,
    );
  }

  @override
  Future<List<AreaModel>> getAreas({bool? popular}) async {
    final query = <String, dynamic>{};
    if (popular != null) query['popular'] = popular;

    final response = await _dioClient.get(
      ApiEndpoints.areas,
      queryParameters: query,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataList = responseData['data'] as List<dynamic>? ?? [];

    return dataList
        .map((item) => AreaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
