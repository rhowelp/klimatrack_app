import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';

/// This is the use case for fetching weather data by city name
class GetWeatherByCityUseCase {
  final OpenWeatherRepository repository;

  GetWeatherByCityUseCase(this.repository);

  Future<Weather> call(String city, ApiFormat format) async {
    return await repository.getWeatherByCity(city, format);
  }
}
