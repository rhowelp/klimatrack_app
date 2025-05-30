part of 'weather_bloc.dart';

abstract class WeatherEvent {}

class FetchWeatherByCity extends WeatherEvent {
  final String city;
  FetchWeatherByCity(this.city);
}

class FetchWeatherByLocation extends WeatherEvent {
  final double latitude;
  final double longitude;
  FetchWeatherByLocation({
    required this.latitude,
    required this.longitude,
  });
}
