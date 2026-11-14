import 'package:equatable/equatable.dart';

/// User entity representing an authenticated or registered user in GhorBD.
/// Traceability: REQ-023, REQ-024 | SCR-010, SCR-011 | API-005, API-006, API-010, API-013
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // "tenant" | "owner" | "editor" | "admin"
  final String? listerType; // "owner" | "agent" | "builder" | null
  final String? listerDetail;
  final bool verified;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final String? profilePhotoUrl;
  final bool isOwner;
  final bool isAdmin;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.listerType,
    this.listerDetail,
    this.verified = false,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.profilePhotoUrl,
    this.isOwner = false,
    this.isAdmin = false,
  });

  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        listerType,
        listerDetail,
        verified,
        emailVerifiedAt,
        phoneVerifiedAt,
        profilePhotoUrl,
        isOwner,
        isAdmin,
      ];
}
