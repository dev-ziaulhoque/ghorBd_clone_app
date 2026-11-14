import 'package:equatable/equatable.dart';

/// Pricing plan entity.
/// Traceability: REQ-031, REQ-032, REQ-033, REQ-034, SCR-014, API-061.
class PricingPlanEntity extends Equatable {
  final String id;
  final String slug;
  final String name;
  final String? nameEn;
  final String? description;
  final int priceMinor;
  final num price;
  final String currency;
  final String interval; // 'one_time', 'monthly', 'yearly'
  final List<String> features;
  final bool popular;
  final String? ctaLabel;
  final bool published;
  final int order;
  final bool isFree;

  const PricingPlanEntity({
    required this.id,
    required this.slug,
    required this.name,
    this.nameEn,
    this.description,
    this.priceMinor = 0,
    required this.price,
    this.currency = 'BDT',
    this.interval = 'monthly',
    this.features = const [],
    this.popular = false,
    this.ctaLabel,
    this.published = true,
    this.order = 0,
    this.isFree = false,
  });

  @override
  List<Object?> get props => [
        id,
        slug,
        name,
        nameEn,
        description,
        priceMinor,
        price,
        currency,
        interval,
        features,
        popular,
        ctaLabel,
        published,
        order,
        isFree,
      ];
}
