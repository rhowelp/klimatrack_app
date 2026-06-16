part of 'weather_bloc.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {
  final ApiFormat format;
  final String message;

  const WeatherLoading({
    required this.format,
    required this.message,
  });

  @override
  List<Object> get props => [format, message];
}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  const WeatherLoaded({required this.weather});

  @override
  List<Object> get props => [weather];
}

class WeatherError extends WeatherState {
  final String message;
  final WeatherEvent? failedEvent;

  const WeatherError({required this.message, this.failedEvent});

  @override
  List<Object> get props => [message, failedEvent ?? Object()];
}
