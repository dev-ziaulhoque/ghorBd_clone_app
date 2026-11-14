import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/pricing_plan_entity.dart';
import '../repositories/pricing_repository.dart';

/// Fetches available pricing tiers from the server.
/// Traceability: REQ-031–034, SCR-014, API-061.
class GetPricingPlansUseCase {
  final PricingRepository repository;

  GetPricingPlansUseCase(this.repository);

  Future<Either<Failure, List<PricingPlanEntity>>> call() {
    return repository.getPricingPlans();
  }
}
