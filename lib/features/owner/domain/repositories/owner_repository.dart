import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_listing_params.dart';
import '../entities/owner_dashboard_stats.dart';
import '../entities/owner_listing_item.dart';
import '../entities/verification_document.dart';

/// Contract for Owner domain repository.
/// Traceability: REQ-025–029, SCR-012, SCR-013, API-024, API-025, API-027, API-035–043.
abstract class OwnerRepository {
  Future<Either<Failure, OwnerDashboardStats>> getDashboardStats();

  Future<Either<Failure, List<OwnerListingItem>>> getMyListings({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, OwnerListingItem>> createListing(CreateListingParams params);

  Future<Either<Failure, OwnerListingItem>> updateListing(
    String id,
    Map<String, dynamic> updateFields,
  );

  Future<Either<Failure, bool>> transitionListingStatus({
    required String id,
    required String action,
  });

  Future<Either<Failure, List<String>>> uploadMedia({
    required List<String> filePaths,
  });

  Future<Either<Failure, bool>> deleteMedia(String url);

  Future<Either<Failure, List<VerificationDocument>>> getDocuments();

  Future<Either<Failure, VerificationDocument>> uploadDocument({
    required String filePath,
    required String fileName,
  });
}
