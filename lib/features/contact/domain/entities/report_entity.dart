import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String id;
  final String listingId;
  final String reason;
  final String? details;
  final String status;
  final DateTime? createdAt;

  const ReportEntity({
    required this.id,
    required this.listingId,
    required this.reason,
    this.details,
    required this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, listingId, reason, details, status, createdAt];
}
