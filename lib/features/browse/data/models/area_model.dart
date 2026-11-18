import '../../domain/entities/area_entity.dart';

class AreaModel {
  final String id;
  final String slug;
  final String name;
  final String nameEn;
  final String city;
  final String division;
  final bool popular;
  final int listingCount;

  const AreaModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.nameEn,
    required this.city,
    required this.division,
    this.popular = false,
    this.listingCount = 0,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? json['name'] as String? ?? '',
      city: json['city'] as String? ?? 'dhaka',
      division: json['division'] as String? ?? 'dhaka',
      popular: json['popular'] as bool? ?? false,
      listingCount: json['listingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'nameEn': nameEn,
      'city': city,
      'division': division,
      'popular': popular,
      'listingCount': listingCount,
    };
  }

  AreaEntity toEntity() {
    return AreaEntity(
      id: id,
      slug: slug,
      name: name,
      nameEn: nameEn,
      city: city,
      division: division,
      popular: popular,
      listingCount: listingCount,
    );
  }
}
