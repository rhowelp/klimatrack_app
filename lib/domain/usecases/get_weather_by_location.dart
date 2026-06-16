import 'package:klimatrack_app/domain/core/result.dart';
import 'package:klimatrack_app/domain/core/use_case.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/failures/failure.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_location_params.dart';

class GetWeatherByLocationUseCase
    implements UseCase<Weather, GetWeatherByLocationParams> {
  final OpenWeatherRepository repository;

  GetWeatherByLocationUseCase(this.repository);

  @override
  Future<Result<Weather>> call(GetWeatherByLocationParams params) async {
    if (!_isValidLatitude(params.latitude)) {
      return const Error(
        ValidationFailure('Latitude must be between -90 and 90'),
      );
    }

    if (!_isValidLongitude(params.longitude)) {
      return const Error(
        ValidationFailure('Longitude must be between -180 and 180'),
      );
    }

    try {
      final weather = await repository.getWeatherByLocation(
        params.latitude,
        params.longitude,
        params.format,
      );
      return Success(weather);
    } on Exception catch (e) {
      return Error(ServerFailure(e.toString()));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  bool _isValidLatitude(double latitude) =>
      latitude >= -90 && latitude <= 90;

  bool _isValidLongitude(double longitude) =>
      longitude >= -180 && longitude <= 180;
}
