import 'package:flutter_test/flutter_test.dart';
import 'package:klimatrack_app/domain/core/result.dart';
import 'package:klimatrack_app/domain/entities/geo_position.dart';
import 'package:klimatrack_app/domain/failures/failure.dart';
import 'package:klimatrack_app/domain/repositories/location_repository.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/usecases/get_current_location_weather.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/domain/usecases/params/get_current_location_weather_params.dart';
import 'package:klimatrack_app/domain/value_objects/api_format.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../helpers/test_helper.dart';
import 'get_current_location_weather_test.mocks.dart';

@GenerateMocks([
  LocationRepository,
  OpenWeatherRepository,
])
void main() {
  late MockLocationRepository mockLocationRepository;
  late MockOpenWeatherRepository mockWeatherRepository;
  late GetCurrentLocationWeatherUseCase useCase;

  setUp(() {
    mockLocationRepository = MockLocationRepository();
    mockWeatherRepository = MockOpenWeatherRepository();
    useCase = GetCurrentLocationWeatherUseCase(
      locationRepository: mockLocationRepository,
      getWeatherByLocation: GetWeatherByLocationUseCase(mockWeatherRepository),
    );
  });

  test('returns weather when location is available', () async {
    when(mockLocationRepository.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(mockLocationRepository.getCurrentPosition()).thenAnswer(
      (_) async => const GeoPosition(latitude: testLat, longitude: testLon),
    );
    when(mockWeatherRepository.getWeatherByLocation(any, any, any))
        .thenAnswer((_) async => testWeather);

    final result = await useCase.call(
      const GetCurrentLocationWeatherParams(format: ApiFormat.json),
    );

    expect(result, isA<Success<dynamic>>());
    verify(mockLocationRepository.isLocationServiceEnabled()).called(1);
    verify(mockLocationRepository.getCurrentPosition()).called(1);
    verify(
      mockWeatherRepository.getWeatherByLocation(testLat, testLon, ApiFormat.json),
    ).called(1);
  });

  test('returns LocationFailure when location services are disabled', () async {
    when(mockLocationRepository.isLocationServiceEnabled())
        .thenAnswer((_) async => false);

    final result = await useCase.call(
      const GetCurrentLocationWeatherParams(format: ApiFormat.json),
    );

    expect(result, isA<Error<dynamic>>());
    expect((result as Error).failure, isA<LocationFailure>());
    verifyNever(mockLocationRepository.getCurrentPosition());
    verifyZeroInteractions(mockWeatherRepository);
  });

  test('returns LocationFailure when position is unavailable', () async {
    when(mockLocationRepository.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(mockLocationRepository.getCurrentPosition())
        .thenAnswer((_) async => null);

    final result = await useCase.call(
      const GetCurrentLocationWeatherParams(format: ApiFormat.json),
    );

    expect(result, isA<Error<dynamic>>());
    expect((result as Error).failure, isA<LocationFailure>());
    verifyZeroInteractions(mockWeatherRepository);
  });
}
