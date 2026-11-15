import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../browse/domain/entities/listing_entity.dart';

/// Predefined quick area filter for the map top carousel.
class MapAreaChip {
  final String slug;
  final String labelBn;
  final String labelEn;
  final IconData icon;
  final double lat;
  final double lng;
  final double zoom;

  const MapAreaChip({
    required this.slug,
    required this.labelBn,
    required this.labelEn,
    required this.icon,
    required this.lat,
    required this.lng,
    this.zoom = 1.35,
  });
}

/// Geographic coordinate model & spatial projection for Dhaka cartography.
class DhakaCoordinates {
  DhakaCoordinates._();

  static const double minLat = 23.6900;
  static const double maxLat = 23.9050;
  static const double minLng = 90.3200;
  static const double maxLng = 90.4650;

  static const double canvasWidth = 1600.0;
  static const double canvasHeight = 1800.0;
  static const Size canvasSize = Size(canvasWidth, canvasHeight);

  /// Real GPS centroids for Dhaka neighborhoods.
  static const Map<String, (double, double)> areaCentroids = {
    'uttara': (23.8759, 90.3795),
    'mirpur': (23.8071, 90.3686),
    'gulshan': (23.7925, 90.4078),
    'banani': (23.7937, 90.4043),
    'baridhara': (23.8010, 90.4210),
    'bashundhara': (23.8191, 90.4526),
    'dhanmondi': (23.7465, 90.3760),
    'mohammadpur': (23.7658, 90.3582),
    'badda': (23.7806, 90.4267),
    'rampura': (23.7612, 90.4208),
    'khilkhet': (23.8315, 90.4178),
    'motijheel': (23.7330, 90.4172),
    'malibagh': (23.7489, 90.4128),
    'tejgaon': (23.7639, 90.3950),
    'farmgate': (23.7561, 90.3872),
    'shahbagh': (23.7380, 90.3955),
    'lalmatia': (23.7530, 90.3700),
    'shyamoli': (23.7710, 90.3640),
    'nikunja': (23.8320, 90.4180),
    'cantonment': (23.8222, 90.3933),
    'maghbazar': (23.7500, 90.4050),
    'khilgaon': (23.7520, 90.4250),
    'jatrabari': (23.7120, 90.4350),
    'old-dhaka': (23.7150, 90.4050),
  };

  /// Quick areas presented in the horizontal filter carousel.
  static const List<MapAreaChip> popularChips = [
    MapAreaChip(
      slug: 'all',
      labelBn: 'সব এলাকা',
      labelEn: 'All Areas',
      icon: Icons.travel_explore,
      lat: 23.7800,
      lng: 90.3950,
      zoom: 0.95,
    ),
    MapAreaChip(
      slug: 'uttara',
      labelBn: 'উত্তরা',
      labelEn: 'Uttara',
      icon: Icons.apartment,
      lat: 23.8759,
      lng: 90.3795,
    ),
    MapAreaChip(
      slug: 'gulshan',
      labelBn: 'গুলশান',
      labelEn: 'Gulshan',
      icon: Icons.star_border,
      lat: 23.7925,
      lng: 90.4078,
    ),
    MapAreaChip(
      slug: 'banani',
      labelBn: 'বনানী',
      labelEn: 'Banani',
      icon: Icons.storefront,
      lat: 23.7937,
      lng: 90.4043,
    ),
    MapAreaChip(
      slug: 'dhanmondi',
      labelBn: 'ধানমন্ডি',
      labelEn: 'Dhanmondi',
      icon: Icons.park,
      lat: 23.7465,
      lng: 90.3760,
    ),
    MapAreaChip(
      slug: 'mirpur',
      labelBn: 'মিরপুর',
      labelEn: 'Mirpur',
      icon: Icons.location_city,
      lat: 23.8071,
      lng: 90.3686,
    ),
    MapAreaChip(
      slug: 'bashundhara',
      labelBn: 'বসুন্ধরা',
      labelEn: 'Bashundhara',
      icon: Icons.home_work,
      lat: 23.8191,
      lng: 90.4526,
    ),
    MapAreaChip(
      slug: 'mohammadpur',
      labelBn: 'মোহাম্মদপুর',
      labelEn: 'Mohammadpur',
      icon: Icons.cottage,
      lat: 23.7658,
      lng: 90.3582,
    ),
    MapAreaChip(
      slug: 'badda',
      labelBn: 'বাড্ডা',
      labelEn: 'Badda',
      icon: Icons.signpost,
      lat: 23.7806,
      lng: 90.4267,
    ),
    MapAreaChip(
      slug: 'baridhara',
      labelBn: 'বারিধারা',
      labelEn: 'Baridhara',
      icon: Icons.villa,
      lat: 23.8010,
      lng: 90.4210,
    ),
    MapAreaChip(
      slug: 'motijheel',
      labelBn: 'মতিঝিল',
      labelEn: 'Motijheel',
      icon: Icons.account_balance,
      lat: 23.7330,
      lng: 90.4172,
    ),
  ];

  /// Find latitude and longitude for an area slug or address.
  static (double, double) getLatLngForArea(String? areaSlug) {
    if (areaSlug != null && areaSlug.isNotEmpty) {
      final key = areaSlug.toLowerCase().trim();
      for (final entry in areaCentroids.entries) {
        if (key.contains(entry.key) || entry.key.contains(key)) {
          return entry.value;
        }
      }
    }
    // Default central Dhaka
    return (23.7800, 90.4000);
  }

  /// Project GPS (lat, lng) to canvas (x, y) coordinates.
  static Offset project(
    double lat,
    double lng, {
    Size size = canvasSize,
  }) {
    final clampedLat = lat.clamp(minLat, maxLat);
    final clampedLng = lng.clamp(minLng, maxLng);

    const padding = 120.0;
    final usableW = size.width - (padding * 2);
    final usableH = size.height - (padding * 2);

    final x = ((clampedLng - minLng) / (maxLng - minLng)) * usableW + padding;
    final y = ((maxLat - clampedLat) / (maxLat - minLat)) * usableH + padding;
    return Offset(x, y);
  }

  /// Calculate deterministic spatial coordinates for a listing with polar dispersion.
  static Offset getListingOffset(
    ListingEntity listing,
    int indexInArea,
    int totalInArea, {
    Size size = canvasSize,
  }) {
    Offset base;
    if (listing.lat != null &&
        listing.lng != null &&
        listing.lat! >= minLat &&
        listing.lat! <= maxLat &&
        listing.lng! >= minLng &&
        listing.lng! <= maxLng) {
      base = project(listing.lat!, listing.lng!, size: size);
      if (totalInArea <= 1 || indexInArea == 0) {
        return base;
      }
      // Gentle street-side offset when multiple listings share the same GPS cluster
      final angle = (indexInArea * (2 * math.pi / totalInArea)) + 0.35;
      const radius = 28.0;
      return Offset(
        base.dx + radius * math.cos(angle),
        base.dy + radius * math.sin(angle),
      );
    }

    final (lat, lng) = getLatLngForArea(listing.areaSlug);
    base = project(lat, lng, size: size);

    if (totalInArea <= 1) {
      return base;
    }

    // Natural street dispersion around area center
    final angle = (indexInArea * (2 * math.pi / totalInArea)) + 0.35;
    final radius = 36.0 + (indexInArea % 3) * 22.0;

    return Offset(
      base.dx + radius * math.cos(angle),
      base.dy + radius * math.sin(angle),
    );
  }
}
