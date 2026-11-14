import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_listing_params.dart';
import '../entities/owner_dashboard_stats.dart';
import '../entities/owner_listing_item.dart';
import '../entities/verification_document.dart';
import '../repositories/owner_repository.dart';

class GetOwnerDashboardStatsUseCase {
  final OwnerRepository repository;
  GetOwnerDashboardStatsUseCase(this.repository);

  Future<Either<Failure, OwnerDashboardStats>> call() {
    return repository.getDashboardStats();
  }
}

class GetMyListingsUseCase {
  final OwnerRepository repository;
  GetMyListingsUseCase(this.repository);

  Future<Either<Failure, List<OwnerListingItem>>> call({
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return repository.getMyListings(
      status: status,
      page: page,
      perPage: perPage,
    );
  }
}

class CreateListingUseCase {
  final OwnerRepository repository;
  CreateListingUseCase(this.repository);

  Future<Either<Failure, OwnerListingItem>> call(CreateListingParams params) {
    return repository.createListing(params);
  }
}

class UpdateListingUseCase {
  final OwnerRepository repository;
  UpdateListingUseCase(this.repository);

  Future<Either<Failure, OwnerListingItem>> call(
    String id,
    Map<String, dynamic> updateFields,
  ) {
    return repository.updateListing(id, updateFields);
  }
}

class TransitionListingStatusUseCase {
  final OwnerRepository repository;
  TransitionListingStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String id,
    required String action,
  }) {
    return repository.transitionListingStatus(id: id, action: action);
  }
}

class UploadMediaUseCase {
  final OwnerRepository repository;
  UploadMediaUseCase(this.repository);

  Future<Either<Failure, List<String>>> call(List<String> filePaths) {
    return repository.uploadMedia(filePaths: filePaths);
  }
}

class GetVerificationDocumentsUseCase {
  final OwnerRepository repository;
  GetVerificationDocumentsUseCase(this.repository);

  Future<Either<Failure, List<VerificationDocument>>> call() {
    return repository.getDocuments();
  }
}

class UploadVerificationDocumentUseCase {
  final OwnerRepository repository;
  UploadVerificationDocumentUseCase(this.repository);

  Future<Either<Failure, VerificationDocument>> call({
    required String filePath,
    required String fileName,
  }) {
    return repository.uploadDocument(filePath: filePath, fileName: fileName);
  }
}
