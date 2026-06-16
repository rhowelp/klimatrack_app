import 'package:equatable/equatable.dart';

class GeoPosition extends Equatable {
  final double latitude;
  final double longitude;

  const GeoPosition({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}
