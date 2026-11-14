import 'package:equatable/equatable.dart';

/// Owner listing item entity with lifecycle status and transition actions.
/// Traceability: REQ-025–029, SCR-012, SCR-013, API-024, API-025, API-027, API-035.
class OwnerListingItem extends Equatable {
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
  final String status; // active, pending, draft, archived, withdrawn
  final int views;
  final List<String> availableTransitions;

  const OwnerListingItem({
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

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        slug,
        propertyType,
        purpose,
        pricePerMonth,
        status,
        verified,
        views,
        availableTransitions,
      ];
}
