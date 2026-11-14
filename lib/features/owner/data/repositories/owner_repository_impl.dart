import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/create_listing_params.dart';
import '../../domain/entities/owner_dashboard_stats.dart';
import '../../domain/entities/owner_listing_item.dart';
import '../../domain/entities/verification_document.dart';
import '../../domain/repositories/owner_repository.dart';
import '../datasources/owner_remote_data_source.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  final OwnerRemoteDataSource remoteDataSource;

  OwnerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OwnerDashboardStats>> getDashboardStats() async {
    try {
      final model = await remoteDataSource.getDashboardStats();
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OwnerListingItem>>> getMyListings({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final models = await remoteDataSource.getMyListings(
        status: status,
        page: page,
        perPage: perPage,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerListingItem>> createListing(
    CreateListingParams params,
  ) async {
    try {
      final model = await remoteDataSource.createListing(params);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerListingItem>> updateListing(
    String id,
    Map<String, dynamic> updateFields,
  ) async {
    try {
      final model = await remoteDataSource.updateListing(id, updateFields);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> transitionListingStatus({
    required String id,
    required String action,
  }) async {
    try {
      final success = await remoteDataSource.transitionListingStatus(
        id: id,
        action: action,
      );
      return Right(success);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadMedia({
    required List<String> filePaths,
  }) async {
    try {
      final urls = await remoteDataSource.uploadMedia(filePaths: filePaths);
      return Right(urls);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMedia(String url) async {
    try {
      final success = await remoteDataSource.deleteMedia(url);
      return Right(success);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VerificationDocument>>> getDocuments() async {
    try {
      final models = await remoteDataSource.getDocuments();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerificationDocument>> uploadDocument({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final model = await remoteDataSource.uploadDocument(
        filePath: filePath,
        fileName: fileName,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
