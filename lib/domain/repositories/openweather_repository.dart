import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';

/// Repository interface for weather data operations
abstract class OpenWeatherRepository {
  /// Fetches weather data for a specific city with format (JSON or XML)
  Future<Weather> getWeatherByCity(String city, ApiFormat format);

  /// Fetches weather data for a specific location by latitude and longitude
  Future<Weather> getWeatherByLocation(
    double latitude,
    double longitude,
    ApiFormat format,
  );
}
