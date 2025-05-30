import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:klimatrack_app/domain/constants/constants.dart';
import 'package:klimatrack_app/data/models/weather_model.dart';
import 'package:klimatrack_app/domain/constants/api_format.dart';
import 'package:xml/xml.dart';

abstract class OpenWeatherApi {
  Future<WeatherModel> getWeatherByJson(String city, ApiFormat format);
  Future<WeatherModel> getWeatherByLocation(
      double latitude, double longitude, ApiFormat format);
}

class OpenWeatherApiImpl implements OpenWeatherApi {
  final Dio dio;

  OpenWeatherApiImpl(this.dio);

  @override
  Future<WeatherModel> getWeatherByJson(
    String city,
    ApiFormat format,
  ) async {
    format = ApiFormat.json;
    try {
      final queryParameters = {
        'q': city,
        'units': 'metric',
        'appid': Constants.apiKey,
      };

      if (format == ApiFormat.xml) {
        queryParameters['mode'] = 'xml';
      }

      log('Fetching weather for city: $city with format: ${format.name}');

      final response =
          await dio.get('/weather', queryParameters: queryParameters);

      log('API Response Status Code: ${response.statusCode}');
      log('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (format == ApiFormat.json) {
          if (response.data['cod'] == '404') {
            throw Exception(
                'City not found. Please check the spelling and try again.');
          }
          return WeatherModel.fromJson(response.data);
        } else if (format == ApiFormat.xml) {
          final document = XmlDocument.parse(response.data);
          return _parseWeatherXml(document);
        }
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('DioException: ${e.message}', error: e);
      if (e.response?.statusCode == 404) {
        throw Exception(
            'City not found. Please check the spelling and try again.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.response?.data != null) {
        try {
          if (e.response?.headers
                  .value('content-type')
                  ?.contains('application/json') ??
              false) {
            final errorMessage = e.response?.data['message'] ?? e.message;
            throw Exception('Failed to fetch weather data: $errorMessage');
          } else if (e.response?.headers
                  .value('content-type')
                  ?.contains('application/xml') ??
              false) {
            final document = XmlDocument.parse(e.response?.data);
            final errorMessage =
                document.findAllElements('message').first.innerText;
            throw Exception('Failed to fetch weather data: $errorMessage');
          } else {
            throw Exception('Failed to fetch weather data: ${e.message}');
          }
        } catch (parseError) {
          throw Exception(
              'Failed to fetch weather data: ${e.message}. Could not parse error details: $parseError');
        }
      } else {
        throw Exception('Failed to fetch weather data: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error: $e', error: e);
      throw Exception('An unexpected error occurred: $e');
    }
    return Future.error('Unhandled state');
  }

  @override
  Future<WeatherModel> getWeatherByLocation(
    double latitude,
    double longitude,
    ApiFormat format,
  ) async {
    format = ApiFormat.json;
    try {
      final queryParameters = {
        'lat': latitude,
        'lon': longitude,
        'units': 'metric',
        'appid': Constants.apiKey,
      };

      if (format == ApiFormat.xml) {
        queryParameters['mode'] = 'xml';
      }

      log('Fetching weather for location: $latitude, $longitude with format: ${format.name}');

      final response =
          await dio.get('/weather', queryParameters: queryParameters);

      log('API Response Status Code: ${response.statusCode}');
      log('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (format == ApiFormat.json) {
          return WeatherModel.fromJson(response.data);
        } else if (format == ApiFormat.xml) {
          final document = XmlDocument.parse(response.data);
          return _parseWeatherXml(document);
        }
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('DioException: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.response?.data != null) {
        try {
          if (e.response?.headers
                  .value('content-type')
                  ?.contains('application/json') ??
              false) {
            final errorMessage = e.response?.data['message'] ?? e.message;
            throw Exception('Failed to fetch weather data: $errorMessage');
          } else if (e.response?.headers
                  .value('content-type')
                  ?.contains('application/xml') ??
              false) {
            final document = XmlDocument.parse(e.response?.data);
            final errorMessage =
                document.findAllElements('message').first.innerText;
            throw Exception('Failed to fetch weather data: $errorMessage');
          } else {
            throw Exception('Failed to fetch weather data: ${e.message}');
          }
        } catch (parseError) {
          throw Exception(
              'Failed to fetch weather data: ${e.message}. Could not parse error details: $parseError');
        }
      } else {
        throw Exception('Failed to fetch weather data: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error: $e', error: e);
      throw Exception('An unexpected error occurred: $e');
    }
    return Future.error('Unhandled state');
  }

  WeatherModel _parseWeatherXml(XmlDocument document) {
    final cityElement = document.findAllElements('city').first;
    final temperatureElement = document.findAllElements('temperature').first;
    final humidityElement = document.findAllElements('humidity').first;
    final windElement = document.findAllElements('wind').first;
    final speedElement = windElement.findAllElements('speed').first;
    final pressureElement = document.findAllElements('pressure').first;
    final cloudsElement = document.findAllElements('clouds').first;
    final weatherElement = document.findAllElements('weather').first;
    final sysElement = document.findAllElements('country').first;
    final coordElement = cityElement.findAllElements('coord').first;
    final sunElement = document.findAllElements('sun').first;

    return WeatherModel(
      coord: Coord(
        lon: double.parse(coordElement.getAttribute('lon')!),
        lat: double.parse(coordElement.getAttribute('lat')!),
      ),
      weather: [
        Weather(
          id: int.parse(weatherElement.getAttribute('number')!),
          main: weatherElement.getAttribute('value')!,
          description: weatherElement.getAttribute('value')!,
          icon: weatherElement.getAttribute('icon')!,
        ),
      ],
      base: '',
      main: Main(
        temp: double.parse(temperatureElement.getAttribute('value')!),
        feelsLike: double.parse(document
            .findAllElements('feels_like')
            .first
            .getAttribute('value')!),
        tempMin: double.parse(temperatureElement.getAttribute('min')!),
        tempMax: double.parse(temperatureElement.getAttribute('max')!),
        pressure: int.parse(pressureElement.getAttribute('value')!),
        humidity: int.parse(humidityElement.getAttribute('value')!),
        seaLevel: 0,
        grndLevel: 0,
      ),
      visibility: int.parse(
          document.findAllElements('visibility').first.getAttribute('value')!),
      wind: Wind(
        speed: double.parse(speedElement.getAttribute('value')!),
        deg: int.parse(windElement
            .findAllElements('direction')
            .first
            .getAttribute('value')!),
      ),
      clouds: Clouds(
        all: int.parse(cloudsElement.getAttribute('value')!),
      ),
      dt: int.parse(
          document.findAllElements('lastupdate').first.getAttribute('value') !=
                  null
              ? (DateTime.parse(document
                              .findAllElements('lastupdate')
                              .first
                              .getAttribute('value')!)
                          .millisecondsSinceEpoch ~/
                      1000)
                  .toString()
              : '0'),
      sys: Sys(
        type: 0,
        id: 0,
        country: sysElement.innerText,
        sunrise: int.parse((DateTime.parse(sunElement.getAttribute('rise')!)
                    .millisecondsSinceEpoch ~/
                1000)
            .toString()),
        sunset: int.parse((DateTime.parse(sunElement.getAttribute('set')!)
                    .millisecondsSinceEpoch ~/
                1000)
            .toString()),
      ),
      timezone:
          int.parse(cityElement.findAllElements('timezone').first.innerText),
      id: int.parse(cityElement.getAttribute('id')!),
      name: cityElement.getAttribute('name')!,
      cod: 200,
    );
  }
}
