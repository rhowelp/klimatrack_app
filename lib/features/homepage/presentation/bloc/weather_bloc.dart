import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/core/services/location_service.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherByCityUseCase getWeatherByCity;
  final GetWeatherByLocationUseCase getWeatherByLocation;
  final LocationService locationService;

  WeatherBloc({
    required this.getWeatherByCity,
    required this.getWeatherByLocation,
    required this.locationService,
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
    emit(WeatherLoading(
        message:
            'Fetching weather for ${event.city} in ${event.format.name.toUpperCase()} format...'));
    try {
      final weather = await getWeatherByCity(event.city, event.format);
      emit(WeatherLoaded(weather: weather));
    } catch (e) {
      emit(WeatherError(message: e.toString(), failedEvent: event));
    }
  }

  Future<void> _onFetchWeatherByLocation(
    FetchWeatherByLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading(
        message:
            'Fetching weather for location (${event.latitude}, ${event.longitude}) in ${event.format.name.toUpperCase()} format...'));
    try {
      final weather = await getWeatherByLocation(
          event.latitude, event.longitude, event.format);
      emit(WeatherLoaded(weather: weather));
    } catch (e) {
      emit(WeatherError(message: e.toString(), failedEvent: event));
    }
  }

  Future<void> _onFetchCurrentLocationWeather(
    FetchCurrentLocationWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading(
        message:
            'Fetching weather for current location in ${event.format.name.toUpperCase()} format...'));
    try {
      final isEnabled = await locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        emit(WeatherError(
            message: 'Please enable location services to get weather data',
            failedEvent: event));
        return;
      }

      final position = await locationService.getCurrentLocation();
      if (position != null) {
        add(FetchWeatherByLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            format: event.format));
      } else {
        emit(WeatherError(
            message:
                'Unable to get location. Please check your location permissions.',
            failedEvent: event));
      }
    } catch (e) {
      emit(WeatherError(
          message: 'Error getting location: ${e.toString()}',
          failedEvent: event));
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
