import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klimatrack_app/domain/core/result.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/domain/failures/failure.dart';
import 'package:klimatrack_app/domain/usecases/get_current_location_weather.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/domain/usecases/params/get_current_location_weather_params.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_city_params.dart';
import 'package:klimatrack_app/domain/usecases/params/get_weather_by_location_params.dart';
import 'package:klimatrack_app/domain/value_objects/api_format.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../../helpers/test_helper.dart';
import 'weather_bloc_test.mocks.dart';

@GenerateMocks([
  GetWeatherByCityUseCase,
  GetWeatherByLocationUseCase,
  GetCurrentLocationWeatherUseCase,
])
void main() {
  provideDummy<Result<Weather>>(
    const Error(UnknownFailure('dummy')),
  );

  late MockGetWeatherByCityUseCase mockGetWeatherByCityUseCase;
  late MockGetWeatherByLocationUseCase mockGetWeatherByLocationUseCase;
  late MockGetCurrentLocationWeatherUseCase mockGetCurrentLocationWeatherUseCase;
  late WeatherBloc weatherBloc;

  setUp(() {
    mockGetWeatherByCityUseCase = MockGetWeatherByCityUseCase();
    mockGetWeatherByLocationUseCase = MockGetWeatherByLocationUseCase();
    mockGetCurrentLocationWeatherUseCase = MockGetCurrentLocationWeatherUseCase();
    weatherBloc = WeatherBloc(
      getWeatherByCity: mockGetWeatherByCityUseCase,
      getWeatherByLocation: mockGetWeatherByLocationUseCase,
      getCurrentLocationWeather: mockGetCurrentLocationWeatherUseCase,
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
      when(mockGetWeatherByCityUseCase.call(any)).thenAnswer(
        (_) async => Success(testWeather),
      );
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
      verify(
        mockGetWeatherByCityUseCase.call(
          const GetWeatherByCityParams(city: testCity, format: ApiFormat.json),
        ),
      ).called(1);
    },
  );

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherError] when FetchWeatherByCity fails',
    build: () {
      when(mockGetWeatherByCityUseCase.call(any)).thenAnswer(
        (_) async => const Error(ServerFailure('Error')),
      );
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
      when(mockGetCurrentLocationWeatherUseCase.call(any)).thenAnswer(
        (_) async => Success(testWeather),
      );
      return weatherBloc;
    },
    act: (bloc) => bloc.add(
      const FetchCurrentLocationWeather(format: ApiFormat.json),
    ),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherLoaded>(),
    ],
    verify: (_) {
      verify(
        mockGetCurrentLocationWeatherUseCase.call(
          const GetCurrentLocationWeatherParams(format: ApiFormat.json),
        ),
      ).called(1);
    },
  );

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherError] when FetchCurrentLocationWeather fails',
    build: () {
      when(mockGetCurrentLocationWeatherUseCase.call(any)).thenAnswer(
        (_) async => const Error(LocationFailure('Error getting location')),
      );
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

  blocTest<WeatherBloc, WeatherState>(
    'emits [WeatherLoading, WeatherLoaded] when FetchWeatherByLocation is successful',
    build: () {
      when(mockGetWeatherByLocationUseCase.call(any)).thenAnswer(
        (_) async => Success(testWeather),
      );
      return weatherBloc;
    },
    act: (bloc) => bloc.add(
      const FetchWeatherByLocation(
        latitude: testLat,
        longitude: testLon,
        format: ApiFormat.json,
      ),
    ),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherLoaded>(),
    ],
    verify: (_) {
      verify(
        mockGetWeatherByLocationUseCase.call(
          const GetWeatherByLocationParams(
            latitude: testLat,
            longitude: testLon,
            format: ApiFormat.json,
          ),
        ),
      ).called(1);
    },
  );
}
