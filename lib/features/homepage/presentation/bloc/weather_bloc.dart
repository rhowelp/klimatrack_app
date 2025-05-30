import 'package:bloc/bloc.dart';
import 'package:klimatrack_app/data/models/weather_model.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/constants/api_format.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final OpenWeatherApiImpl repository;

  WeatherBloc(this.repository) : super(WeatherInitial()) {
    on<FetchWeatherByCity>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather =
            await repository.getWeatherByJson(event.city, event.format);
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError("Failed to fetch weather: ${e.toString()}"));
      }
    });

    on<FetchWeatherByLocation>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather = await repository.getWeatherByLocation(
          event.latitude,
          event.longitude,
          event.format,
        );
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError("Failed to fetch weather: ${e.toString()}"));
      }
    });
  }
}
