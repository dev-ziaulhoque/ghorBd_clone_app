import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/report_entity.dart';

abstract class ContactRepository {
  Future<Either<Failure, String>> getContactPhone(String listingId);
  Future<Either<Failure, bool>> sendInquiry(String listingId, String content);
  Future<Either<Failure, ReportEntity>> reportListing(
    String listingId,
    String reason,
    String? details,
  );
}
