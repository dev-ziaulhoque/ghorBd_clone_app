import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/report_model.dart';

abstract class ContactRemoteDataSource {
  Future<String> getContactPhone(String listingId);
  Future<bool> sendInquiry(String listingId, String content);
  Future<ReportModel> reportListing(
    String listingId,
    String reason,
    String? details,
  );
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final DioClient dioClient;

  ContactRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<String> getContactPhone(String listingId) async {
    final response = await dioClient.get(ApiEndpoints.listingContact(listingId));
    final data = response.data['data'] as Map<String, dynamic>?;
    return data?['phone'] as String? ?? '';
  }

  @override
  Future<bool> sendInquiry(String listingId, String content) async {
    final response = await dioClient.post(
      ApiEndpoints.listingContact(listingId),
      data: {'content': content},
    );
    final data = response.data['data'] as Map<String, dynamic>?;
    return data?['sent'] as bool? ?? true;
  }

  @override
  Future<ReportModel> reportListing(
    String listingId,
    String reason,
    String? details,
  ) async {
    final payload = <String, dynamic>{
      'reason': reason,
      if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
    };
    final response = await dioClient.post(
      ApiEndpoints.listingReport(listingId),
      data: payload,
    );
    final data = response.data['data'] as Map<String, dynamic>?;
    final reportJson = data?['report'] as Map<String, dynamic>? ?? {};
    return ReportModel.fromJson(reportJson);
  }
}
