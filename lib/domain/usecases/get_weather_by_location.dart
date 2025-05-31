import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';

/// This is use case for fetching weather data by location coordinates
class GetWeatherByLocationUseCase {
  final OpenWeatherRepository repository;

  GetWeatherByLocationUseCase(this.repository);

  Future<Weather> call(
      double latitude, double longitude, ApiFormat format) async {
    return await repository.getWeatherByLocation(latitude, longitude, format);
  }
}
