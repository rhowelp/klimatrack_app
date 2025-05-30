import 'package:dio/dio.dart';
import 'package:klimatrack_app/domain/constants/constants.dart';
import 'package:klimatrack_app/data/models/weather_model.dart';
import 'package:klimatrack_app/domain/constants/api_format.dart';
import 'package:xml/xml.dart';

/// Interface for OpenWeather API operations
abstract class OpenWeatherApi {
  /// Fetches weather data for a specific city with format (JSON or XML)
  Future<WeatherModel> getWeatherByJson(
    String city,
    ApiFormat format,
  );

  /// Fetches weather data for a specific location by latitude and longitude
  Future<WeatherModel> getWeatherByLocation(
    double latitude,
    double longitude,
    ApiFormat format,
  );
}

/// Implementation of OpenWeather API operations
class OpenWeatherApiImpl implements OpenWeatherApi {
  final Dio dio;

  OpenWeatherApiImpl(this.dio);

  @override
  Future<WeatherModel> getWeatherByJson(String city, ApiFormat format) async {
    try {
      final queryParameters = _buildQueryParameters(
        city: city,
        format: format,
      );

      final response = await _makeApiRequest('/weather', queryParameters);
      return _parseResponse(response, format);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<WeatherModel> getWeatherByLocation(
      double latitude, double longitude, ApiFormat format) async {
    try {
      final queryParameters = _buildQueryParameters(
        latitude: latitude,
        longitude: longitude,
        format: format,
      );

      final response = await _makeApiRequest('/weather', queryParameters);
      return _parseResponse(response, format);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Builds query parameters for the API request
  Map<String, dynamic> _buildQueryParameters({
    String? city,
    double? latitude,
    double? longitude,
    required ApiFormat format,
  }) {
    final parameters = {
      'units': 'metric',
      'appid': Constants.apiKey,
    };

    if (city != null) {
      parameters['q'] = city;
    } else if (latitude != null && longitude != null) {
      parameters['lat'] = latitude.toString();
      parameters['lon'] = longitude.toString();
    }

    if (format == ApiFormat.xml) {
      parameters['mode'] = 'xml';
    }

    return parameters;
  }

  /// Makes an API request and returns the response
  Future<Response> _makeApiRequest(
      String endpoint, Map<String, dynamic> queryParameters) async {
    return await dio.get(endpoint, queryParameters: queryParameters);
  }

  /// Parses the API response based on the format
  WeatherModel _parseResponse(Response response, ApiFormat format) {
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }

    if (format == ApiFormat.json) {
      if (response.data['cod'] == '404') {
        throw Exception(
            'City not found. Please check the spelling and try again.');
      }
      return WeatherModel.fromJson(response.data);
    } else {
      final document = XmlDocument.parse(response.data);
      return _parseWeatherXml(document);
    }
  }

  /// Handles DioException and returns appropriate error message
  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception(
          'City not found. Please check the spelling and try again.');
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return Exception(
          'Connection timeout. Please check your internet connection.');
    }

    if (e.response?.data != null) {
      return _parseErrorResponse(e);
    }

    return Exception('Failed to fetch weather data: ${e.message}');
  }

  /// Parses error response from the API
  Exception _parseErrorResponse(DioException e) {
    try {
      final contentType = e.response?.headers.value('content-type');

      if (contentType?.contains('application/json') ?? false) {
        final errorMessage = e.response?.data['message'] ?? e.message;
        return Exception('Failed to fetch weather data: $errorMessage');
      }

      if (contentType?.contains('application/xml') ?? false) {
        final document = XmlDocument.parse(e.response?.data);
        final errorMessage =
            document.findAllElements('message').first.innerText;
        return Exception('Failed to fetch weather data: $errorMessage');
      }

      return Exception('Failed to fetch weather data: ${e.message}');
    } catch (parseError) {
      return Exception(
          'Failed to fetch weather data: ${e.message}. Could not parse error details: $parseError');
    }
  }

  /// Parses XML response into WeatherModel
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
            : '0',
      ),
      sys: Sys(
        type: 0,
        id: 0,
        country: sysElement.innerText,
        sunrise: int.parse(
          (DateTime.parse(sunElement.getAttribute('rise')!)
                      .millisecondsSinceEpoch ~/
                  1000)
              .toString(),
        ),
        sunset: int.parse(
          (DateTime.parse(sunElement.getAttribute('set')!)
                      .millisecondsSinceEpoch ~/
                  1000)
              .toString(),
        ),
      ),
      timezone:
          int.parse(cityElement.findAllElements('timezone').first.innerText),
      id: int.parse(cityElement.getAttribute('id')!),
      name: cityElement.getAttribute('name')!,
      cod: 200,
    );
  }
}
