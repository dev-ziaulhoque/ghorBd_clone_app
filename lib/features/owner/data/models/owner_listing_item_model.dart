import '../../domain/entities/owner_listing_item.dart';

class OwnerListingItemModel {
  final String id;
  final String? ownerId;
  final String title;
  final String slug;
  final String description;
  final String propertyType;
  final String purpose;
  final String areaSlug;
  final String city;
  final String address;
  final int? floor;
  final String? unitNumber;
  final int bed;
  final int bath;
  final int size;
  final int pricePerMonth;
  final String currency;
  final List<String> images;
  final List<String> amenities;
  final bool verified;
  final String status;
  final int views;
  final List<String> availableTransitions;

  const OwnerListingItemModel({
    required this.id,
    this.ownerId,
    required this.title,
    required this.slug,
    this.description = '',
    required this.propertyType,
    required this.purpose,
    required this.areaSlug,
    required this.city,
    required this.address,
    this.floor,
    this.unitNumber,
    this.bed = 0,
    this.bath = 0,
    this.size = 0,
    required this.pricePerMonth,
    this.currency = 'BDT',
    this.images = const [],
    this.amenities = const [],
    this.verified = false,
    this.status = 'pending',
    this.views = 0,
    this.availableTransitions = const [],
  });

  factory OwnerListingItemModel.fromJson(Map<String, dynamic> json) {
    final rooms = json['rooms'] as Map<String, dynamic>?;
    return OwnerListingItemModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      ownerId: json['ownerId'] as String?,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? 'apartment',
      purpose: json['purpose'] as String? ?? 'rent',
      areaSlug: json['areaSlug'] as String? ?? '',
      city: json['city'] as String? ?? 'dhaka',
      address: json['address'] as String? ?? '',
      floor: json['floor'] as int?,
      unitNumber: json['unitNumber'] as String?,
      bed: rooms?['bed'] as int? ?? (json['bedrooms'] as int? ?? 0),
      bath: rooms?['bath'] as int? ?? (json['bathrooms'] as int? ?? 0),
      size: json['size'] as int? ?? 0,
      pricePerMonth: (json['pricePerMonth'] as num? ?? json['price'] as num? ?? 0).toInt(),
      currency: json['currency'] as String? ?? 'BDT',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      verified: json['verified'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      views: json['views'] as int? ?? (json['viewCount'] as int? ?? 0),
      availableTransitions: (json['available'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  OwnerListingItem toEntity() {
    return OwnerListingItem(
      id: id,
      ownerId: ownerId,
      title: title,
      slug: slug,
      description: description,
      propertyType: propertyType,
      purpose: purpose,
      areaSlug: areaSlug,
      city: city,
      address: address,
      floor: floor,
      unitNumber: unitNumber,
      bed: bed,
      bath: bath,
      size: size,
      pricePerMonth: pricePerMonth,
      currency: currency,
      images: images,
      amenities: amenities,
      verified: verified,
      status: status,
      views: views,
      availableTransitions: availableTransitions,
    );
  }
}
