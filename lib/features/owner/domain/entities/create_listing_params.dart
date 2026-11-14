import 'package:equatable/equatable.dart';

/// Parameters for creating or updating an ad listing.
/// Traceability: REQ-025, REQ-026, REQ-028, SCR-012, API-024, API-025.
class CreateListingParams extends Equatable {
  final String title;
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
  final List<String> images;
  final List<String> amenities;
  final String? contactPhone;
  final bool allowDirectContact;
  final String displayDuration;
  final double? lat;
  final double? lng;
  final String status;

  const CreateListingParams({
    required this.title,
    required this.description,
    required this.propertyType,
    this.purpose = 'rent',
    required this.areaSlug,
    this.city = 'dhaka',
    required this.address,
    this.floor,
    this.unitNumber,
    this.bed = 0,
    this.bath = 0,
    this.size = 0,
    required this.pricePerMonth,
    this.images = const [],
    this.amenities = const [],
    this.contactPhone,
    this.allowDirectContact = true,
    this.displayDuration = 'unlimited',
    this.lat,
    this.lng,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'propertyType': propertyType,
      'purpose': purpose,
      'areaSlug': areaSlug,
      'city': city,
      'address': address,
      'pricePerMonth': pricePerMonth,
      'images': images,
      'amenities': amenities,
      'allowDirectContact': allowDirectContact,
      'displayDuration': displayDuration,
      'status': status,
    };

    if (floor != null) map['floor'] = floor;
    if (unitNumber != null && unitNumber!.isNotEmpty) map['unitNumber'] = unitNumber;
    if (bed > 0 || bath > 0) {
      map['rooms'] = {'bed': bed, 'bath': bath};
    }
    if (size > 0) map['size'] = size;
    if (contactPhone != null && contactPhone!.isNotEmpty) {
      map['contactPhone'] = contactPhone;
    }
    if (lat != null && lng != null) {
      map['coords'] = {'lat': lat, 'lng': lng};
    }

    return map;
  }

  @override
  List<Object?> get props => [
        title,
        description,
        propertyType,
        purpose,
        areaSlug,
        city,
        address,
        floor,
        unitNumber,
        bed,
        bath,
        size,
        pricePerMonth,
        images,
        amenities,
        contactPhone,
        allowDirectContact,
        displayDuration,
        lat,
        lng,
        status,
      ];
}
