import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/create_listing_params.dart';
import '../models/owner_dashboard_stats_model.dart';
import '../models/owner_listing_item_model.dart';
import '../models/verification_document_model.dart';

abstract class OwnerRemoteDataSource {
  Future<OwnerDashboardStatsModel> getDashboardStats();

  Future<List<OwnerListingItemModel>> getMyListings({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<OwnerListingItemModel> createListing(CreateListingParams params);

  Future<OwnerListingItemModel> updateListing(
    String id,
    Map<String, dynamic> updateFields,
  );

  Future<bool> transitionListingStatus({
    required String id,
    required String action,
  });

  Future<List<String>> uploadMedia({
    required List<String> filePaths,
  });

  Future<bool> deleteMedia(String url);

  Future<List<VerificationDocumentModel>> getDocuments();

  Future<VerificationDocumentModel> uploadDocument({
    required String filePath,
    required String fileName,
  });
}

class OwnerRemoteDataSourceImpl implements OwnerRemoteDataSource {
  final DioClient dioClient;

  OwnerRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<OwnerDashboardStatsModel> getDashboardStats() async {
    final response = await dioClient.get(ApiEndpoints.ownerDashboard);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return OwnerDashboardStatsModel.fromJson(data);
  }

  @override
  Future<List<OwnerListingItemModel>> getMyListings({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'perPage': perPage,
      if (status != null && status.isNotEmpty && status != 'all') 'status': status,
    };

    final response = await dioClient.get(
      ApiEndpoints.myListings,
      queryParameters: queryParams,
    );

    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => OwnerListingItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OwnerListingItemModel> createListing(CreateListingParams params) async {
    final response = await dioClient.post(
      ApiEndpoints.listings,
      data: params.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final listingJson = data['listing'] as Map<String, dynamic>? ?? data;
    return OwnerListingItemModel.fromJson(listingJson);
  }

  @override
  Future<OwnerListingItemModel> updateListing(
    String id,
    Map<String, dynamic> updateFields,
  ) async {
    final response = await dioClient.put(
      ApiEndpoints.listingDetail(id),
      data: updateFields,
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final listingJson = data['listing'] as Map<String, dynamic>? ?? data;
    return OwnerListingItemModel.fromJson(listingJson);
  }

  @override
  Future<bool> transitionListingStatus({
    required String id,
    required String action,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.listingTransition(id),
      data: {'action': action},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<String>> uploadMedia({
    required List<String> filePaths,
  }) async {
    final formData = FormData();
    for (final path in filePaths) {
      final fileName = path.split('/').last.split('\\').last;
      formData.files.add(MapEntry(
        'files',
        MultipartFile.fromFileSync(path, filename: fileName),
      ));
    }

    final response = await dioClient.post(
      ApiEndpoints.mediaUpload,
      data: formData,
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final mediaList = data['media'] as List<dynamic>? ?? [];
    return mediaList
        .map((item) => (item as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  @override
  Future<bool> deleteMedia(String url) async {
    final response = await dioClient.delete(
      ApiEndpoints.mediaDelete,
      data: {'url': url},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<VerificationDocumentModel>> getDocuments() async {
    final response = await dioClient.get(ApiEndpoints.documents);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((item) =>
            VerificationDocumentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VerificationDocumentModel> uploadDocument({
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromFileSync(filePath, filename: fileName),
    });

    final response = await dioClient.post(
      ApiEndpoints.documents,
      data: formData,
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final docJson = data['document'] as Map<String, dynamic>? ?? data;
    return VerificationDocumentModel.fromJson(docJson);
  }
}
