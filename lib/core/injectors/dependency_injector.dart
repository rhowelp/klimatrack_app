import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:klimatrack_app/core/services/dio_client.dart';
import 'package:klimatrack_app/core/services/location_service.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';

final dpLocator = GetIt.instance;

Future<void> init() async {
  // Services
  dpLocator.registerLazySingleton<Dio>(() => DioClient.create());
  dpLocator.registerLazySingleton<LocationService>(() => LocationService());

  // Repositories
  dpLocator.registerLazySingleton<OpenWeatherRepositoryImpl>(
    () => OpenWeatherRepositoryImpl(dpLocator<Dio>()),
  );

  // Use Cases
  dpLocator.registerLazySingleton<GetWeatherByCityUseCase>(
    () => GetWeatherByCityUseCase(dpLocator<OpenWeatherRepositoryImpl>()),
  );
  dpLocator.registerLazySingleton<GetWeatherByLocationUseCase>(
    () => GetWeatherByLocationUseCase(dpLocator<OpenWeatherRepositoryImpl>()),
  );

  // Bloc
  dpLocator.registerFactory<WeatherBloc>(
    () => WeatherBloc(
      getWeatherByCity: dpLocator<GetWeatherByCityUseCase>(),
      getWeatherByLocation: dpLocator<GetWeatherByLocationUseCase>(),
      locationService: dpLocator<LocationService>(),
    ),
  );
}
