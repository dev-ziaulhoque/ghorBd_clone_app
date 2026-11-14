import '../../domain/entities/verification_document.dart';

class VerificationDocumentModel {
  final String id;
  final String userId;
  final String originalName;
  final String mimeType;
  final int size;
  final DateTime? createdAt;

  const VerificationDocumentModel({
    required this.id,
    required this.userId,
    required this.originalName,
    required this.mimeType,
    required this.size,
    this.createdAt,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'].toString());
    }
    return VerificationDocumentModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      createdAt: parsedCreatedAt,
    );
  }

  VerificationDocument toEntity() {
    return VerificationDocument(
      id: id,
      userId: userId,
      originalName: originalName,
      mimeType: mimeType,
      size: size,
      createdAt: createdAt,
    );
  }
}
