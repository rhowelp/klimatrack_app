import 'package:dio/dio.dart';
import 'package:klimatrack_app/domain/constants/constants.dart';
import 'package:klimatrack_app/data/models/weather_model.dart';

abstract class OpenWeatherApi {
  Future<WeatherModel> getWeatherByJson(String city);
  Future<WeatherModel> getWeatherByXml(String city);
}

class OpenWeatherApiImpl implements OpenWeatherApi {
  final Dio dio;

  OpenWeatherApiImpl(this.dio);

  @override
  Future<WeatherModel> getWeatherByJson(String city) async {
    final response = await dio.get('/weather', queryParameters: {
      'q': city,
      'units': 'metric',
      'appid': Constants.apiKey,
    });

    return WeatherModel.fromJson(response.data);
  }

  @override
  Future<WeatherModel> getWeatherByXml(String city) async {
    final response = await dio.get('/weather', queryParameters: {
      'q': city,
      'units': 'metric',
      'mode': 'xml',
      'appid': Constants.apiKey,
    });

    return WeatherModel.fromJson(response.data);
  }
}
