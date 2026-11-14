import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pricing_plan_entity.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../datasources/pricing_remote_data_source.dart';

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource remoteDataSource;

  PricingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PricingPlanEntity>>> getPricingPlans() async {
    try {
      final models = await remoteDataSource.getPricingPlans();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
