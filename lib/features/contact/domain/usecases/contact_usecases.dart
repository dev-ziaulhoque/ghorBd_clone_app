import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/report_entity.dart';
import '../repositories/contact_repository.dart';

class GetContactPhoneUseCase {
  final ContactRepository repository;
  const GetContactPhoneUseCase(this.repository);

  Future<Either<Failure, String>> call(String listingId) =>
      repository.getContactPhone(listingId);
}

class SendInquiryUseCase {
  final ContactRepository repository;
  const SendInquiryUseCase(this.repository);

  Future<Either<Failure, bool>> call(String listingId, String content) =>
      repository.sendInquiry(listingId, content);
}

class ReportListingUseCase {
  final ContactRepository repository;
  const ReportListingUseCase(this.repository);

  Future<Either<Failure, ReportEntity>> call({
    required String listingId,
    required String reason,
    String? details,
  }) =>
      repository.reportListing(listingId, reason, details);
}
