import 'package:klimatrack_app/domain/core/result.dart';
import 'package:klimatrack_app/domain/core/use_case.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/failures/failure.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_city_params.dart';

class GetWeatherByCityUseCase
    implements UseCase<Weather, GetWeatherByCityParams> {
  final OpenWeatherRepository repository;

  GetWeatherByCityUseCase(this.repository);

  @override
  Future<Result<Weather>> call(GetWeatherByCityParams params) async {
    final city = params.city.trim();
    if (city.isEmpty) {
      return const Error(ValidationFailure('City name cannot be empty'));
    }

    try {
      final weather = await repository.getWeatherByCity(city, params.format);
      return Success(weather);
    } on Exception catch (e) {
      return Error(ServerFailure(e.toString()));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
}
