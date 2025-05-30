import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:klimatrack_app/data/models/weather_model.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final OpenWeatherApiImpl repository;

  WeatherBloc(this.repository) : super(WeatherInitial()) {
    on<FetchWeatherByCity>((event, emit) async {
      emit(WeatherLoading());
      try {
        log('Fetching weather for city: ${event.city}');
        final weather = await repository.getWeatherByJson(event.city);
        log('Weather fetched successfully for city: ${event.city}');
        emit(WeatherLoaded(weather));
      } catch (e) {
        log('Error fetching weather for city: ${event.city}', error: e);
        emit(WeatherError("Failed to fetch weather: ${e.toString()}"));
      }
    });

    on<FetchWeatherByLocation>((event, emit) async {
      emit(WeatherLoading());
      try {
        log('Fetching weather for location: ${event.latitude}, ${event.longitude}');
        final weather = await repository.getWeatherByLocation(
          event.latitude,
          event.longitude,
        );
        log('Weather fetched successfully for location: ${event.latitude}, ${event.longitude}');
        emit(WeatherLoaded(weather));
      } catch (e) {
        log('Error fetching weather for location: ${event.latitude}, ${event.longitude}',
            error: e);
        emit(WeatherError("Failed to fetch weather: ${e.toString()}"));
      }
    });
  }
}
