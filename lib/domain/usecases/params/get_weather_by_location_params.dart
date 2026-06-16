import 'package:equatable/equatable.dart';
import 'package:klimatrack_app/domain/value_objects/api_format.dart';

class GetWeatherByLocationParams extends Equatable {
  final double latitude;
  final double longitude;
  final ApiFormat format;

  const GetWeatherByLocationParams({
    required this.latitude,
    required this.longitude,
    required this.format,
  });

  @override
  List<Object> get props => [latitude, longitude, format];
}
