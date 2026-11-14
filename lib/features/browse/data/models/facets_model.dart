import '../../domain/entities/facets_entity.dart';

class FacetsModel {
  final List<FacetItem<String>> propertyTypes;
  final List<FacetItem<String>> divisions;
  final List<FacetItem<String>> areas;
  final List<FacetItem<int>> bedrooms;
  final List<FacetItem<bool>> verified;
  final int minPrice;
  final int maxPrice;

  const FacetsModel({
    this.propertyTypes = const [],
    this.divisions = const [],
    this.areas = const [],
    this.bedrooms = const [],
    this.verified = const [],
    this.minPrice = 0,
    this.maxPrice = 0,
  });

  factory FacetsModel.fromJson(Map<String, dynamic> json) {
    List<FacetItem<T>> parseList<T>(
      dynamic list,
      T Function(dynamic) valueParser,
    ) {
      if (list is! List) return [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return FacetItem<T>(
          value: valueParser(map['value']),
          label: map['label'] as String?,
          count: (map['count'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }

    final price = json['price'] as Map<String, dynamic>?;

    return FacetsModel(
      propertyTypes: parseList<String>(
        json['propertyType'],
        (v) => v.toString(),
      ),
      divisions: parseList<String>(
        json['division'],
        (v) => v.toString(),
      ),
      areas: parseList<String>(
        json['area'],
        (v) => v.toString(),
      ),
      bedrooms: parseList<int>(
        json['bedrooms'],
        (v) => (v as num).toInt(),
      ),
      verified: parseList<bool>(
        json['verified'],
        (v) => v == true || v.toString() == 'true',
      ),
      minPrice: (price?['min'] as num?)?.toInt() ?? 0,
      maxPrice: (price?['max'] as num?)?.toInt() ?? 0,
    );
  }

  ListingFacetsEntity toEntity() {
    return ListingFacetsEntity(
      propertyTypes: propertyTypes,
      divisions: divisions,
      areas: areas,
      bedrooms: bedrooms,
      verified: verified,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}
