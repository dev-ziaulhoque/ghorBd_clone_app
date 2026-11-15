import '../../domain/entities/listing_entity.dart';

class ListingModel {
  final String id;
  final String? ownerId;
  final String? listerType;
  final String title;
  final String slug;
  final String description;
  final String propertyType;
  final String purpose;
  final String areaSlug;
  final String city;
  final String division;
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
  final DateTime? verifiedAt;
  final bool featured;
  final bool hasContactPhone;
  final int viewCount;

  // Land specific
  final String? landType;
  final double? landAreaValue;
  final String? landAreaUnit;
  final String? landFacing;
  final double? landRoadWidthFt;
  final double? lat;
  final double? lng;

  const ListingModel({
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

  static String _normalizeImageUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://localhost:5000') ||
        url.startsWith('http://10.0.2.2:5000')) {
      return url.replaceFirst(
        RegExp(r'http://(localhost|10\.0\.2\.2):5000'),
        'https://ghorbd.com',
      );
    }
    if (url.startsWith('/')) {
      return 'https://ghorbd.com$url';
    }
    return url;
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final rooms = json['rooms'] as Map<String, dynamic>?;
    final land = json['land'] as Map<String, dynamic>?;
    final coords = json['coords'] as Map<String, dynamic>?;

    final latVal = (coords?['lat'] as num?)?.toDouble() ??
        (json['lat'] as num?)?.toDouble();
    final lngVal = (coords?['lng'] as num?)?.toDouble() ??
        (json['lng'] as num?)?.toDouble();

    DateTime? parsedVerifiedAt;
    if (json['verifiedAt'] != null) {
      parsedVerifiedAt = DateTime.tryParse(json['verifiedAt'].toString());
    }

    return ListingModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      ownerId: json['ownerId'] as String?,
      listerType: json['listerType'] as String?,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? 'apartment',
      purpose: json['purpose'] as String? ?? 'rent',
      areaSlug: json['areaSlug'] as String? ?? '',
      city: json['city'] as String? ?? 'dhaka',
      division: json['division'] as String? ?? 'dhaka',
      address: json['address'] as String? ?? '',
      floor: json['floor'] as int?,
      unitNumber: json['unitNumber'] as String?,
      bed: rooms?['bed'] as int? ?? (json['bedrooms'] as int? ?? 0),
      bath: rooms?['bath'] as int? ?? (json['bathrooms'] as int? ?? 0),
      size: json['size'] as int? ?? (json['areaSqft'] as int? ?? 0),
      pricePerMonth: (json['pricePerMonth'] as num? ??
              json['price'] as num? ??
              0)
          .toInt(),
      currency: json['currency'] as String? ?? 'BDT',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => _normalizeImageUrl(e.toString()))
              .toList() ??
          const [],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      verified: json['verified'] as bool? ?? false,
      verifiedAt: parsedVerifiedAt,
      featured: json['featured'] as bool? ?? false,
      hasContactPhone: json['hasContactPhone'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      landType: land?['landType'] as String?,
      landAreaValue: (land?['areaValue'] as num?)?.toDouble(),
      landAreaUnit: land?['areaUnit'] as String?,
      landFacing: land?['facing'] as String?,
      landRoadWidthFt: (land?['roadWidthFt'] as num?)?.toDouble(),
      lat: latVal,
      lng: lngVal,
    );
  }

  ListingEntity toEntity() {
    return ListingEntity(
      id: id,
      ownerId: ownerId,
      listerType: listerType,
      title: title,
      slug: slug,
      description: description,
      propertyType: propertyType,
      purpose: purpose,
      areaSlug: areaSlug,
      city: city,
      division: division,
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
      verifiedAt: verifiedAt,
      featured: featured,
      hasContactPhone: hasContactPhone,
      viewCount: viewCount,
      landType: landType,
      landAreaValue: landAreaValue,
      landAreaUnit: landAreaUnit,
      landFacing: landFacing,
      landRoadWidthFt: landRoadWidthFt,
      lat: lat,
      lng: lng,
    );
  }
}
