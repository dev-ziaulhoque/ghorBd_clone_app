import 'package:equatable/equatable.dart';

/// Verification document entity.
/// Traceability: REQ-029, SCR-013, API-040, API-041.
class VerificationDocument extends Equatable {
  final String id;
  final String userId;
  final String originalName;
  final String mimeType;
  final int size;
  final DateTime? createdAt;

  const VerificationDocument({
    required this.id,
    required this.userId,
    required this.originalName,
    required this.mimeType,
    required this.size,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, originalName, mimeType, size, createdAt];
}
