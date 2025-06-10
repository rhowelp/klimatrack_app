import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/core/services/location_service.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../../helpers/test_helper.dart';
import '../../../../helpers/test_helper.mocks.dart';

@GenerateMocks([
  GetWeatherByCityUseCase,
  GetWeatherByLocationUseCase,
  LocationService,
])
void main() {
  late MockGetWeatherByCityUseCase mockGetWeatherByCityUseCase;
  late MockGetWeatherByLocationUseCase mockGetWeatherByLocationUseCase;
  late MockLocationService mockLocationService;
  late WeatherBloc weatherBloc;

  setUp(() {
    mockGetWeatherByCityUseCase = MockGetWeatherByCityUseCase();
    mockGetWeatherByLocationUseCase = MockGetWeatherByLocationUseCase();
    mockLocationService = MockLocationService();
    weatherBloc = WeatherBloc(
      getWeatherByCity: mockGetWeatherByCityUseCase,
      getWeatherByLocation: mockGetWeatherByLocationUseCase,
      locationService: mockLocationService,
    );
  });

  tearDown(() {
    weatherBloc.close();
  });

  test('initial state should be WeatherInitial', () {
    expect(weatherBloc.state, equals(WeatherInitial()));
  });

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherLoaded] when FetchWeatherByCity is successful',
    build: () {
      when(mockGetWeatherByCityUseCase.call(any, any))
          .thenAnswer((_) async => testWeather);
      return weatherBloc;
    },
    act: (bloc) => bloc.add(
      const FetchWeatherByCity(city: testCity, format: ApiFormat.json),
    ),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherLoaded>(),
    ],
    verify: (_) {
      verify(mockGetWeatherByCityUseCase.call(testCity, ApiFormat.json))
          .called(1);
    },
  );

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherError] when FetchWeatherByCity fails',
    build: () {
      when(mockGetWeatherByCityUseCase.call(any, any))
          .thenThrow(Exception('Error'));
      return weatherBloc;
    },
    act: (bloc) => bloc.add(
      const FetchWeatherByCity(city: testCity, format: ApiFormat.json),
    ),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherError>(),
    ],
  );

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherLoaded] when FetchCurrentLocationWeather is successful',
    build: () {
      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => Position(
                latitude: testLat,
                longitude: testLon,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                altitudeAccuracy: 0,
                headingAccuracy: 0,
              ));
      when(mockGetWeatherByLocationUseCase.call(any, any, any))
          .thenAnswer((_) async => testWeather);
      return weatherBloc;
    },
    act: (bloc) => bloc.add(
      const FetchCurrentLocationWeather(format: ApiFormat.json),
    ),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherLoading>(),
      isA<WeatherLoaded>(),
    ],
    verify: (_) {
      verify(mockLocationService.isLocationServiceEnabled()).called(1);
      verify(mockLocationService.getCurrentLocation()).called(1);
      verify(mockGetWeatherByLocationUseCase.call(
              testLat, testLon, ApiFormat.json))
          .called(1);
    },
  );

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherError] when FetchCurrentLocationWeather fails',
    build: () {
      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.getCurrentLocation())
          .thenThrow(Exception('Error'));
      return weatherBloc;
    },
    act: (bloc) => bloc.add(
      const FetchCurrentLocationWeather(format: ApiFormat.json),
    ),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherError>(),
    ],
  );
}
