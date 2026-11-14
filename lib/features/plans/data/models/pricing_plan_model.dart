import '../../domain/entities/pricing_plan_entity.dart';

class PricingPlanModel {
  final String id;
  final String slug;
  final String name;
  final String? nameEn;
  final String? description;
  final int priceMinor;
  final num price;
  final String currency;
  final String interval;
  final List<String> features;
  final bool popular;
  final String? ctaLabel;
  final bool published;
  final int order;
  final bool isFree;

  const PricingPlanModel({
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

  factory PricingPlanModel.fromJson(Map<String, dynamic> json) {
    return PricingPlanModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String?,
      description: json['description'] as String?,
      priceMinor: (json['priceMinor'] as num?)?.toInt() ?? 0,
      price: json['price'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'BDT',
      interval: json['interval'] as String? ?? 'monthly',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      popular: json['popular'] as bool? ?? false,
      ctaLabel: json['ctaLabel'] as String?,
      published: json['published'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isFree: json['isFree'] as bool? ?? (json['price'] == 0),
    );
  }

  PricingPlanEntity toEntity() => PricingPlanEntity(
        id: id,
        slug: slug,
        name: name,
        nameEn: nameEn,
        description: description,
        priceMinor: priceMinor,
        price: price,
        currency: currency,
        interval: interval,
        features: features,
        popular: popular,
        ctaLabel: ctaLabel,
        published: published,
        order: order,
        isFree: isFree,
      );
}
