import 'package:equatable/equatable.dart';

/// Core listing entity representing a property ad.
/// Traceability: REQ-001, REQ-007, REQ-014–017, API-022, API-023.
class ListingEntity extends Equatable {
  final String id;
  final String? ownerId;
  final String? listerType;
  final String title;
  final String slug;
  final String description;
  final String propertyType; // apartment, room, house, building, shop, office, land, hostel
  final String purpose; // rent, sale
  final String areaSlug;
  final String city;
  final String division;
  final String address;
  final int? floor;
  final String? unitNumber;
  final int bed;
  final int bath;
  final int size; // sqft
  final int pricePerMonth;
  final String currency;
  final List<String> images;
  final List<String> amenities;
  final bool verified;
  final DateTime? verifiedAt;
  final bool featured;
  final bool hasContactPhone;
  final int viewCount;

  // Land specific attributes
  final String? landType; // residential, commercial, agricultural, industrial
  final double? landAreaValue;
  final String? landAreaUnit; // katha, bigha, decimal, acre, sqft
  final String? landFacing;
  final double? landRoadWidthFt;

  // Geo coordinates
  final double? lat;
  final double? lng;

  const ListingEntity({
    required this.id,
    this.ownerId,
    this.listerType,
    required this.title,
    required this.slug,
    required this.description,
    required this.propertyType,
    required this.purpose,
    required this.areaSlug,
    required this.city,
    required this.division,
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
    this.verifiedAt,
    this.featured = false,
    this.hasContactPhone = false,
    this.viewCount = 0,
    this.landType,
    this.landAreaValue,
    this.landAreaUnit,
    this.landFacing,
    this.landRoadWidthFt,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        slug,
        propertyType,
        purpose,
        areaSlug,
        city,
        division,
        floor,
        bed,
        bath,
        size,
        pricePerMonth,
        currency,
        images,
        verified,
        featured,
        viewCount,
        lat,
        lng,
      ];
}
