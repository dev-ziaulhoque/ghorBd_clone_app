import 'package:equatable/equatable.dart';

class FacetItem<T> extends Equatable {
  final T value;
  final String? label;
  final int count;

  const FacetItem({
    required this.value,
    this.label,
    required this.count,
  });

  @override
  List<Object?> get props => [value, label, count];
}

class ListingFacetsEntity extends Equatable {
  final List<FacetItem<String>> propertyTypes;
  final List<FacetItem<String>> divisions;
  final List<FacetItem<String>> areas;
  final List<FacetItem<int>> bedrooms;
  final List<FacetItem<bool>> verified;
  final int minPrice;
  final int maxPrice;

  const ListingFacetsEntity({
    this.propertyTypes = const [],
    this.divisions = const [],
    this.areas = const [],
    this.bedrooms = const [],
    this.verified = const [],
    this.minPrice = 0,
    this.maxPrice = 0,
  });

  @override
  List<Object?> get props => [
        propertyTypes,
        divisions,
        areas,
        bedrooms,
        verified,
        minPrice,
        maxPrice,
      ];
}

class ListingFilterParams extends Equatable {
  final int page;
  final int perPage;
  final String sort; // newest, price_asc, price_desc, popular
  final String? purpose; // rent, sale
  final String? propertyType; // backend enum: apartment, room, house, hotel, shop, office, land
  final String? division;
  final String? district;
  final String? areaSlug;
  final int? minPrice;
  final int? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final bool? verified;
  final bool? featured;
  final String? search;

  const ListingFilterParams({
    this.page = 1,
    this.perPage = 12,
    this.sort = 'newest',
    this.purpose,
    this.propertyType,
    this.division,
    this.district,
    this.areaSlug,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    this.verified,
    this.featured,
    this.search,
  });

  ListingFilterParams copyWith({
    int? page,
    int? perPage,
    String? sort,
    String? purpose,
    String? propertyType,
    String? division,
    String? district,
    String? areaSlug,
    int? minPrice,
    int? maxPrice,
    int? bedrooms,
    int? bathrooms,
    bool? verified,
    bool? featured,
    String? search,
    bool clearPurpose = false,
    bool clearPropertyType = false,
    bool clearDivision = false,
    bool clearAreaSlug = false,
    bool clearBedrooms = false,
    bool clearVerified = false,
    bool clearSearch = false,
    bool clearPrice = false,
  }) {
    return ListingFilterParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      sort: sort ?? this.sort,
      purpose: clearPurpose ? null : (purpose ?? this.purpose),
      propertyType: clearPropertyType ? null : (propertyType ?? this.propertyType),
      division: clearDivision ? null : (division ?? this.division),
      district: district ?? this.district,
      areaSlug: clearAreaSlug ? null : (areaSlug ?? this.areaSlug),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
      bathrooms: bathrooms ?? this.bathrooms,
      verified: clearVerified ? null : (verified ?? this.verified),
      featured: featured ?? this.featured,
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'perPage': perPage,
      'sort': sort,
    };
    if (purpose != null && purpose!.isNotEmpty) params['purpose'] = purpose;
    if (propertyType != null && propertyType!.isNotEmpty) {
      // The backend filters on `type` (verified live in Round 3 against
      // /listings and /search): a `propertyType` query key is silently
      // ignored and returns unfiltered results. Valid values are the
      // backend enum: apartment, room, house, hotel, shop, office, land
      // (anything else is a 422 — e.g. there is NO 'sublet' type yet).
      params['type'] = propertyType;
    }
    if (division != null && division!.isNotEmpty) params['division'] = division;
    if (district != null && district!.isNotEmpty) params['district'] = district;
    if (areaSlug != null && areaSlug!.isNotEmpty) params['areaSlug'] = areaSlug;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (bedrooms != null) params['bedrooms'] = bedrooms;
    if (bathrooms != null) params['bathrooms'] = bathrooms;
    if (verified != null) params['verified'] = verified;
    if (featured != null) params['featured'] = featured;
    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }
    return params;
  }

  @override
  List<Object?> get props => [
        page,
        perPage,
        sort,
        purpose,
        propertyType,
        division,
        district,
        areaSlug,
        minPrice,
        maxPrice,
        bedrooms,
        bathrooms,
        verified,
        featured,
        search,
      ];
}
