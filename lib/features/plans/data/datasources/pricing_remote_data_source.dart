import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/pricing_plan_model.dart';

abstract class PricingRemoteDataSource {
  Future<List<PricingPlanModel>> getPricingPlans();
}

class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final DioClient dioClient;

  PricingRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<PricingPlanModel>> getPricingPlans() async {
    final response = await dioClient.get(ApiEndpoints.pricing);
    final responseData = response.data;
    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      final list = responseData['data'] as List<dynamic>;
      return list
          .map((item) => PricingPlanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
