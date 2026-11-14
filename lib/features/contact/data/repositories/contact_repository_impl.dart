import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_data_source.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> getContactPhone(String listingId) async {
    try {
      final phone = await remoteDataSource.getContactPhone(listingId);
      return Right(phone);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendInquiry(
    String listingId,
    String content,
  ) async {
    try {
      final result = await remoteDataSource.sendInquiry(listingId, content);
      return Right(result);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> reportListing(
    String listingId,
    String reason,
    String? details,
  ) async {
    try {
      final report = await remoteDataSource.reportListing(
        listingId,
        reason,
        details,
      );
      return Right(report);
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
