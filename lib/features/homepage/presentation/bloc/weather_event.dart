part of 'weather_bloc.dart';

abstract class WeatherEvent {}

class FetchWeatherByCity extends WeatherEvent {
  final String city;
  final ApiFormat format;
  FetchWeatherByCity(this.city, {this.format = ApiFormat.json});
}

class FetchWeatherByLocation extends WeatherEvent {
  final double latitude;
  final double longitude;
  final ApiFormat format;
  FetchWeatherByLocation({
    required this.latitude,
    required this.longitude,
    this.format = ApiFormat.json,
  });
}
