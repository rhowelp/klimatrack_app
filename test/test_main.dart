import 'package:flutter_test/flutter_test.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'helpers/test_helper.dart';
import 'helpers/test_helper.mocks.dart';

@GenerateMocks([
  OpenWeatherRepositoryImpl,
])
void main() {
  late MockOpenWeatherRepositoryImpl mockRepository;
  late GetWeatherByCityUseCase getWeatherByCityUseCase;
  late GetWeatherByLocationUseCase getWeatherByLocationUseCase;

  setUp(() {
    mockRepository = MockOpenWeatherRepositoryImpl();
    getWeatherByCityUseCase = GetWeatherByCityUseCase(mockRepository);
    getWeatherByLocationUseCase = GetWeatherByLocationUseCase(mockRepository);
  });

  group('GetWeatherByCityUseCase', () {
    test('should return weather data when repository call is successful',
        () async {
      // arrange
      when(mockRepository.getWeatherByCity(any, any))
          .thenAnswer((_) async => testWeather);

      // act
      final result =
          await getWeatherByCityUseCase.call(testCity, ApiFormat.json);

      // assert
      expect(result, equals(testWeather));
      verify(mockRepository.getWeatherByCity(testCity, ApiFormat.json))
          .called(1);
    });

    test('should throw exception when repository call fails', () async {
      // arrange
      when(mockRepository.getWeatherByCity(any, any))
          .thenThrow(Exception('Error'));

      // act & assert
      expect(
        () => getWeatherByCityUseCase.call(testCity, ApiFormat.json),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('GetWeatherByLocationUseCase', () {
    test('should return weather data when repository call is successful',
        () async {
      // arrange
      when(mockRepository.getWeatherByLocation(any, any, any))
          .thenAnswer((_) async => testWeather);

      // act
      final result = await getWeatherByLocationUseCase.call(
        testLat,
        testLon,
        ApiFormat.json,
      );

      // assert
      expect(result, equals(testWeather));
      verify(mockRepository.getWeatherByLocation(
              testLat, testLon, ApiFormat.json))
          .called(1);
    });

    test('should throw exception when repository call fails', () async {
      // arrange
      when(mockRepository.getWeatherByLocation(any, any, any))
          .thenThrow(Exception('Error'));

      // act & assert
      expect(
        () =>
            getWeatherByLocationUseCase.call(testLat, testLon, ApiFormat.json),
        throwsA(isA<Exception>()),
      );
    });
  });
}
