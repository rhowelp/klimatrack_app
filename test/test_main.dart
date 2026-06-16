import 'package:flutter_test/flutter_test.dart';
import 'package:klimatrack_app/domain/core/result.dart';
import 'package:klimatrack_app/domain/failures/failure.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_city_params.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_location_params.dart';
import 'package:klimatrack_app/domain/value_objects/api_format.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'helpers/test_helper.dart';
import 'test_main.mocks.dart';

@GenerateMocks([
  OpenWeatherRepository,
])
void main() {
  late MockOpenWeatherRepository mockRepository;
  late GetWeatherByCityUseCase getWeatherByCityUseCase;
  late GetWeatherByLocationUseCase getWeatherByLocationUseCase;

  setUp(() {
    mockRepository = MockOpenWeatherRepository();
    getWeatherByCityUseCase = GetWeatherByCityUseCase(mockRepository);
    getWeatherByLocationUseCase = GetWeatherByLocationUseCase(mockRepository);
  });

  group('GetWeatherByCityUseCase', () {
    test('should return Success when repository call is successful', () async {
      when(mockRepository.getWeatherByCity(any, any))
          .thenAnswer((_) async => testWeather);

      final result = await getWeatherByCityUseCase.call(
        const GetWeatherByCityParams(city: testCity, format: ApiFormat.json),
      );

      expect(result, isA<Success<dynamic>>());
      expect((result as Success).value, equals(testWeather));
      verify(mockRepository.getWeatherByCity(testCity, ApiFormat.json)).called(1);
    });

    test('should return ValidationFailure for empty city', () async {
      final result = await getWeatherByCityUseCase.call(
        const GetWeatherByCityParams(city: '   ', format: ApiFormat.json),
      );

      expect(result, isA<Error<dynamic>>());
      expect(
        (result as Error).failure,
        isA<ValidationFailure>(),
      );
      verifyNever(mockRepository.getWeatherByCity(any, any));
    });

    test('should return ServerFailure when repository call fails', () async {
      when(mockRepository.getWeatherByCity(any, any))
          .thenThrow(Exception('Error'));

      final result = await getWeatherByCityUseCase.call(
        const GetWeatherByCityParams(city: testCity, format: ApiFormat.json),
      );

      expect(result, isA<Error<dynamic>>());
      expect((result as Error).failure, isA<ServerFailure>());
    });
  });

  group('GetWeatherByLocationUseCase', () {
    test('should return Success when repository call is successful', () async {
      when(mockRepository.getWeatherByLocation(any, any, any))
          .thenAnswer((_) async => testWeather);

      final result = await getWeatherByLocationUseCase.call(
        const GetWeatherByLocationParams(
          latitude: testLat,
          longitude: testLon,
          format: ApiFormat.json,
        ),
      );

      expect(result, isA<Success<dynamic>>());
      expect((result as Success).value, equals(testWeather));
      verify(
        mockRepository.getWeatherByLocation(testLat, testLon, ApiFormat.json),
      ).called(1);
    });

    test('should return ValidationFailure for invalid latitude', () async {
      final result = await getWeatherByLocationUseCase.call(
        const GetWeatherByLocationParams(
          latitude: 120,
          longitude: testLon,
          format: ApiFormat.json,
        ),
      );

      expect(result, isA<Error<dynamic>>());
      expect((result as Error).failure, isA<ValidationFailure>());
      verifyNever(mockRepository.getWeatherByLocation(any, any, any));
    });

    test('should return ServerFailure when repository call fails', () async {
      when(mockRepository.getWeatherByLocation(any, any, any))
          .thenThrow(Exception('Error'));

      final result = await getWeatherByLocationUseCase.call(
        const GetWeatherByLocationParams(
          latitude: testLat,
          longitude: testLon,
          format: ApiFormat.json,
        ),
      );

      expect(result, isA<Error<dynamic>>());
      expect((result as Error).failure, isA<ServerFailure>());
    });
  });
}
