import 'package:get_it/get_it.dart';
import 'package:klimatrack_app/core/services/dio_client.dart';
import 'package:klimatrack_app/core/services/location_service.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';

final dpLocator = GetIt.instance;

Future<void> init() async {
  // Services
  dpLocator.registerLazySingleton(() => DioClient.create());
  dpLocator.registerLazySingleton(() => LocationService());

  // Repositories
  dpLocator.registerLazySingleton(() => OpenWeatherRepositoryImpl(dpLocator()));

  // Use Cases
  dpLocator.registerLazySingleton(() => GetWeatherByCityUseCase(dpLocator()));
  dpLocator.registerLazySingleton(() => GetWeatherByLocationUseCase(dpLocator()));

  // Bloc
  dpLocator.registerFactory(
    () => WeatherBloc(
      getWeatherByCity: dpLocator(),
      getWeatherByLocation: dpLocator(),
      locationService: dpLocator(),
    ),
  );
}
