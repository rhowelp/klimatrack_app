import 'package:klimatrack_app/domain/core/result.dart';
import 'package:klimatrack_app/domain/core/use_case.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/failures/failure.dart';
import 'package:klimatrack_app/domain/repositories/location_repository.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/domain/usecases/params/get_current_location_weather_params.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_location_params.dart';

class GetCurrentLocationWeatherUseCase
    implements UseCase<Weather, GetCurrentLocationWeatherParams> {
  final LocationRepository locationRepository;
  final GetWeatherByLocationUseCase getWeatherByLocation;

  GetCurrentLocationWeatherUseCase({
    required this.locationRepository,
    required this.getWeatherByLocation,
  });

  @override
  Future<Result<Weather>> call(
    GetCurrentLocationWeatherParams params,
  ) async {
    try {
      final isEnabled = await locationRepository.isLocationServiceEnabled();
      if (!isEnabled) {
        return const Error(
          LocationFailure(
            'Please enable location services to get weather data',
          ),
        );
      }

      final position = await locationRepository.getCurrentPosition();
      if (position == null) {
        return const Error(
          LocationFailure(
            'Unable to get location. Please check your location permissions.',
          ),
        );
      }

      return getWeatherByLocation(
        GetWeatherByLocationParams(
          latitude: position.latitude,
          longitude: position.longitude,
          format: params.format,
        ),
      );
    } on Exception catch (e) {
      return Error(LocationFailure('Error getting location: ${e.toString()}'));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
}
