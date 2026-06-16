import 'package:equatable/equatable.dart';
import 'package:klimatrack_app/domain/value_objects/api_format.dart';

class GetWeatherByCityParams extends Equatable {
  final String city;
  final ApiFormat format;

  const GetWeatherByCityParams({
    required this.city,
    required this.format,
  });

  @override
  List<Object> get props => [city, format];
}
