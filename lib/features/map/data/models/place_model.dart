import '../../domain/entities/place_entity.dart';

class PlaceModel extends PlaceEntity {
  const PlaceModel({
    required super.label,
    required super.fullLabel,
    required super.lat,
    required super.lng,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      label: json['label'] as String? ?? '',
      fullLabel: json['fullLabel'] as String? ?? json['label'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'fullLabel': fullLabel,
      'lat': lat,
      'lng': lng,
    };
  }
}
