import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.role,
    super.listerType,
    super.listerDetail,
    super.verified = false,
    super.emailVerifiedAt,
    super.phoneVerifiedAt,
    super.profilePhotoUrl,
    super.isOwner = false,
    super.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'tenant',
      listerType: json['listerType'] as String?,
      listerDetail: json['listerDetail'] as String?,
      verified: json['verified'] as bool? ?? false,
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
      phoneVerifiedAt: json['phoneVerifiedAt'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isOwner: json['isOwner'] as bool? ?? (json['role'] == 'owner'),
      isAdmin: json['isAdmin'] as bool? ?? (json['role'] == 'admin'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'listerType': listerType,
      'listerDetail': listerDetail,
      'verified': verified,
      'emailVerifiedAt': emailVerifiedAt,
      'phoneVerifiedAt': phoneVerifiedAt,
      'profilePhotoUrl': profilePhotoUrl,
      'isOwner': isOwner,
      'isAdmin': isAdmin,
    };
  }
}
