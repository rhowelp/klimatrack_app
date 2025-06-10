import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../helpers/test_helper.dart';
import '../../helpers/test_helper.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late OpenWeatherRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = OpenWeatherRepositoryImpl(mockDio);
  });

  group('getWeatherByCity', () {
    test('should return weather data when API call is successful', () async {
      // arrange
      when(mockDio.get(
        '/weather',
        queryParameters: {
          'q': testCity,
          'units': 'metric',
          'appid': 'b34c5c6eb380b8b70cb1c9cf6f04f5ec',
        },
      )).thenAnswer((_) async => Response(
            data: testWeatherResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/weather'),
          ));

      // act
      final result =
          await repository.getWeatherByCity(testCity, ApiFormat.json);

      // assert
      expect(result, equals(testWeather));
      verify(mockDio.get(
        '/weather',
        queryParameters: {
          'q': testCity,
          'units': 'metric',
          'appid': 'b34c5c6eb380b8b70cb1c9cf6f04f5ec',
        },
      )).called(1);
    });

    test('should throw exception when API call fails', () async {
      // arrange
      when(mockDio.get(
        '/weather',
        queryParameters: {
          'q': testCity,
          'units': 'metric',
          'appid': 'b34c5c6eb380b8b70cb1c9cf6f04f5ec',
        },
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/weather'),
        error: 'Error',
      ));

      // act & assert
      expect(
        () => repository.getWeatherByCity(testCity, ApiFormat.json),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getWeatherByLocation', () {
    test('should return weather data when API call is successful', () async {
      // arrange
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

      // act
      final result = await repository.getWeatherByLocation(
        testLat,
        testLon,
        ApiFormat.json,
      );

      // assert
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
      // arrange
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

      // act & assert
      expect(
        () => repository.getWeatherByLocation(testLat, testLon, ApiFormat.json),
        throwsA(isA<Exception>()),
      );
    });
  });
}
