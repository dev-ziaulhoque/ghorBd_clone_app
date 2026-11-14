import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/pricing_plan_entity.dart';

/// Contract for pricing plans repository.
/// Traceability: REQ-031–034, SCR-014, API-061.
abstract class PricingRepository {
  Future<Either<Failure, List<PricingPlanEntity>>> getPricingPlans();
}
