part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeatherByCity extends WeatherEvent {
  final String city;
  final ApiFormat format;

  const FetchWeatherByCity({required this.city, required this.format});

  @override
  List<Object> get props => [city, format];
}

class FetchWeatherByLocation extends WeatherEvent {
  final double latitude;
  final double longitude;
  final ApiFormat format;

  const FetchWeatherByLocation(
      {required this.latitude, required this.longitude, required this.format});

  @override
  List<Object> get props => [latitude, longitude, format];
}

class FetchCurrentLocationWeather extends WeatherEvent {
  final ApiFormat format;

  const FetchCurrentLocationWeather({required this.format});

  @override
  List<Object> get props => [format];
}

class RetryLastWeatherFetch extends WeatherEvent {
  const RetryLastWeatherFetch();

  @override
  List<Object> get props => [];
}
