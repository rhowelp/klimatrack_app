import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:klimatrack_app/domain/constants/constants.dart';
import 'package:klimatrack_app/data/models/weather_model.dart';

abstract class OpenWeatherApi {
  Future<WeatherModel> getWeatherByJson(String city);
  Future<WeatherModel> getWeatherByLocation(double latitude, double longitude);
}

class OpenWeatherApiImpl implements OpenWeatherApi {
  final Dio dio;

  OpenWeatherApiImpl(this.dio);

  @override
  Future<WeatherModel> getWeatherByJson(String city) async {
    try {
      log('Searching for city with query: $city');

      final response = await dio.get('/weather', queryParameters: {
        'q': city,
        'units': 'metric',
        'appid': Constants.apiKey,
      });

      log('API Response: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['cod'] == '404') {
          throw Exception(
              'City not found. Please check the spelling and try again.');
        }
        return WeatherModel.fromJson(response.data);
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
        final errorMessage = e.response?.data['message'] ?? e.message;
        throw Exception('Failed to fetch weather data: $errorMessage');
      } else {
        throw Exception('Failed to fetch weather data: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error: $e', error: e);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<WeatherModel> getWeatherByLocation(
      double latitude, double longitude) async {
    try {
      log('Fetching weather for coordinates: $latitude, $longitude');
      final response = await dio.get('/weather', queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'units': 'metric',
        'appid': Constants.apiKey,
      });

      log('API Response: ${response.data}');

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('DioException: ${e.message}', error: e);
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.response?.data != null) {
        final errorMessage = e.response?.data['message'] ?? e.message;
        throw Exception('Failed to fetch weather data: $errorMessage');
      } else {
        throw Exception('Failed to fetch weather data: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error: $e', error: e);
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
