import 'package:equatable/equatable.dart';

/// Curated area entity.
/// Traceability: REQ-001, REQ-002, REQ-041, API-048.
class AreaEntity extends Equatable {
  final String id;
  final String slug;
  final String name; // বাংলা নাম (e.g. উত্তরা)
  final String nameEn; // English name (e.g. Uttara)
  final String city;
  final String division;
  final bool popular;
  final int listingCount;

  const AreaEntity({
    required this.id,
    required this.slug,
    required this.name,
    required this.nameEn,
    required this.city,
    required this.division,
    this.popular = false,
    this.listingCount = 0,
  });

  @override
  List<Object?> get props => [id, slug, name, nameEn, city, division, popular, listingCount];
}
