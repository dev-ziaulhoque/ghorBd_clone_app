import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/browse_repository.dart';

class GetListingDetailUseCase {
  final BrowseRepository _repository;

  GetListingDetailUseCase(this._repository);

  Future<Either<Failure, ({ListingEntity listing, List<ListingEntity> similar})>>
      call(String idOrSlug) {
    return _repository.getListingDetail(idOrSlug);
  }
}
