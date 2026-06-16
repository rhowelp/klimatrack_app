import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klimatrack_app/domain/core/result.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/usecases/get_current_location_weather.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/domain/usecases/params/get_current_location_weather_params.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_city_params.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_location_params.dart';
import 'package:klimatrack_app/domain/value_objects/api_format.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherByCityUseCase getWeatherByCity;
  final GetWeatherByLocationUseCase getWeatherByLocation;
  final GetCurrentLocationWeatherUseCase getCurrentLocationWeather;

  WeatherBloc({
    required this.getWeatherByCity,
    required this.getWeatherByLocation,
    required this.getCurrentLocationWeather,
  }) : super(WeatherInitial()) {
    on<FetchWeatherByCity>(_onFetchWeatherByCity);
    on<FetchWeatherByLocation>(_onFetchWeatherByLocation);
    on<FetchCurrentLocationWeather>(_onFetchCurrentLocationWeather);
    on<RetryLastWeatherFetch>(_onRetryLastWeatherFetch);
  }

  Future<void> _onFetchWeatherByCity(
    FetchWeatherByCity event,
    Emitter<WeatherState> emit,
  ) async {
    emit(
      WeatherLoading(
        format: event.format,
        message:
            'Fetching weather for ${event.city} in ${event.format.name.toUpperCase()} format...',
      ),
    );

    final result = await getWeatherByCity(
      GetWeatherByCityParams(city: event.city, format: event.format),
    );
    _emitResult(result, event, emit);
  }

  Future<void> _onFetchWeatherByLocation(
    FetchWeatherByLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(
      WeatherLoading(
        format: event.format,
        message:
            'Fetching weather for location (${event.latitude}, ${event.longitude}) in ${event.format.name.toUpperCase()} format...',
      ),
    );

    final result = await getWeatherByLocation(
      GetWeatherByLocationParams(
        latitude: event.latitude,
        longitude: event.longitude,
        format: event.format,
      ),
    );
    _emitResult(result, event, emit);
  }

  Future<void> _onFetchCurrentLocationWeather(
    FetchCurrentLocationWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(
      WeatherLoading(
        format: event.format,
        message:
            'Fetching weather for current location in ${event.format.name.toUpperCase()} format...',
      ),
    );

    final result = await getCurrentLocationWeather(
      GetCurrentLocationWeatherParams(format: event.format),
    );
    _emitResult(result, event, emit);
  }

  void _emitResult(
    Result<Weather> result,
    WeatherEvent event,
    Emitter<WeatherState> emit,
  ) {
    switch (result) {
      case Success(:final value):
        emit(WeatherLoaded(weather: value));
      case Error(:final failure):
        emit(WeatherError(message: failure.message, failedEvent: event));
    }
  }

  Future<void> _onRetryLastWeatherFetch(
    RetryLastWeatherFetch event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is WeatherError) {
      final errorState = state as WeatherError;
      if (errorState.failedEvent != null) {
        add(errorState.failedEvent!);
      }
    }
  }
}
