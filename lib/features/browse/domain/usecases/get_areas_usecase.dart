import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/area_entity.dart';
import '../repositories/browse_repository.dart';

class GetAreasUseCase {
  final BrowseRepository _repository;

  GetAreasUseCase(this._repository);

  Future<Either<Failure, List<AreaEntity>>> call({bool? popular}) {
    return _repository.getAreas(popular: popular);
  }
}
