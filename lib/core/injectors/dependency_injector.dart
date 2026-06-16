import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:klimatrack_app/core/services/dio_client.dart';
import 'package:klimatrack_app/core/services/location_service.dart';
import 'package:klimatrack_app/data/repositories/location_repository_impl.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/repositories/location_repository.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart'
    as domain;
import 'package:klimatrack_app/domain/usecases/get_current_location_weather.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';

final dpLocator = GetIt.instance;

Future<void> init() async {
  // Services
  dpLocator.registerLazySingleton<Dio>(() => DioClient.create());
  dpLocator.registerLazySingleton<LocationService>(() => LocationService());

  // Repositories
  dpLocator.registerLazySingleton<domain.OpenWeatherRepository>(
    () => OpenWeatherRepositoryImpl(dpLocator<Dio>()),
  );
  dpLocator.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(dpLocator<LocationService>()),
  );

  // Use Cases
  dpLocator.registerLazySingleton<GetWeatherByCityUseCase>(
    () => GetWeatherByCityUseCase(dpLocator<domain.OpenWeatherRepository>()),
  );
  dpLocator.registerLazySingleton<GetWeatherByLocationUseCase>(
    () => GetWeatherByLocationUseCase(dpLocator<domain.OpenWeatherRepository>()),
  );
  dpLocator.registerLazySingleton<GetCurrentLocationWeatherUseCase>(
    () => GetCurrentLocationWeatherUseCase(
      locationRepository: dpLocator<LocationRepository>(),
      getWeatherByLocation: dpLocator<GetWeatherByLocationUseCase>(),
    ),
  );

  // Bloc
  dpLocator.registerFactory<WeatherBloc>(
    () => WeatherBloc(
      getWeatherByCity: dpLocator<GetWeatherByCityUseCase>(),
      getWeatherByLocation: dpLocator<GetWeatherByLocationUseCase>(),
      getCurrentLocationWeather: dpLocator<GetCurrentLocationWeatherUseCase>(),
    ),
  );
}
