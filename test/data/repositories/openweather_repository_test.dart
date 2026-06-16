import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/core/constants/constants.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../helpers/env_test_helper.dart';
import '../../helpers/test_helper.dart';
import '../../helpers/test_helper.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late OpenWeatherRepositoryImpl repository;

  setUpAll(loadTestEnv);

  setUp(() {
    mockDio = MockDio();
    repository = OpenWeatherRepositoryImpl(mockDio);
  });

  group('getWeatherByCity', () {
    test('should return weather data when API call is successful', () async {
      when(mockDio.get(
        '/weather',
        queryParameters: {
          'q': testCity,
          'units': 'metric',
          'appid': Constants.apiKey,
        },
      )).thenAnswer((_) async => Response(
            data: testWeatherResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/weather'),
          ));

      final result =
          await repository.getWeatherByCity(testCity, ApiFormat.json);

      expect(result, equals(testWeather));
      verify(mockDio.get(
        '/weather',
        queryParameters: {
          'q': testCity,
          'units': 'metric',
          'appid': Constants.apiKey,
        },
      )).called(1);
    });

    test('should throw exception when API call fails', () async {
      when(mockDio.get(
        '/weather',
        queryParameters: {
          'q': testCity,
          'units': 'metric',
          'appid': Constants.apiKey,
        },
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/weather'),
        error: 'Error',
      ));

      expect(
        () => repository.getWeatherByCity(testCity, ApiFormat.json),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getWeatherByLocation', () {
    test('should return weather data when API call is successful', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => Response(
            data: testWeatherResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/weather'),
          ));

      final result = await repository.getWeatherByLocation(
        testLat,
        testLon,
        ApiFormat.json,
      );

      expect(result, equals(testWeather));
      verify(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(1);
    });

    test('should throw exception when API call fails', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/weather'),
        error: 'Error',
      ));

      expect(
        () => repository.getWeatherByLocation(testLat, testLon, ApiFormat.json),
        throwsA(isA<Exception>()),
      );
    });
  });
}
