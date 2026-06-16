import 'package:equatable/equatable.dart';
import 'package:klimatrack_app/domain/value_objects/api_format.dart';

class GetCurrentLocationWeatherParams extends Equatable {
  final ApiFormat format;

  const GetCurrentLocationWeatherParams({required this.format});

  @override
  List<Object> get props => [format];
}
