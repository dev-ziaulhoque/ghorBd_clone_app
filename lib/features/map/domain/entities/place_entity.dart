import 'package:equatable/equatable.dart';

class PlaceEntity extends Equatable {
  final String label;
  final String fullLabel;
  final double lat;
  final double lng;

  const PlaceEntity({
    required this.label,
    required this.fullLabel,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [label, fullLabel, lat, lng];
}
