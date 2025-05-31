import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/core/constants/constants.dart';
import 'package:klimatrack_app/domain/entities/weather.dart' as entities;
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart';

/// Implementation of the WeatherRepository interface
class OpenWeatherRepositoryImpl implements OpenWeatherRepository {
  final Dio dio;

  OpenWeatherRepositoryImpl(this.dio);

  @override
  Future<entities.Weather> getWeatherByCity(
      String city, ApiFormat format) async {
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
  Future<entities.Weather> getWeatherByLocation(
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
  entities.Weather _parseResponse(Response response, ApiFormat format) {
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }

    if (format == ApiFormat.json) {
      if (response.data['cod'] == '404') {
        throw Exception(
            'City not found. Please check the spelling and try again.');
      }
      final json = response.data;
      return entities.Weather(
        coord: entities.Coord(
          lon: json['coord']['lon']?.toDouble() ?? 0.0,
          lat: json['coord']['lat']?.toDouble() ?? 0.0,
        ),
        weather: (json['weather'] as List?)
                ?.map((w) => entities.WeatherCondition(
                      id: w['id'] ?? 0,
                      main: w['main'] ?? '',
                      description: w['description'] ?? '',
                      icon: w['icon'] ?? '',
                    ))
                .toList() ??
            [],
        base: json['base'] ?? '',
        main: entities.Main(
          temp: json['main']['temp']?.toDouble() ?? 0.0,
          feelsLike: json['main']['feels_like']?.toDouble() ?? 0.0,
          tempMin: json['main']['temp_min']?.toDouble() ?? 0.0,
          tempMax: json['main']['temp_max']?.toDouble() ?? 0.0,
          pressure: json['main']['pressure'] ?? 0,
          humidity: json['main']['humidity'] ?? 0,
          seaLevel: json['main']['sea_level'] ?? 0,
          grndLevel: json['main']['grnd_level'] ?? 0,
        ),
        visibility: json['visibility'] ?? 0,
        wind: entities.Wind(
          speed: json['wind']['speed']?.toDouble() ?? 0.0,
          deg: json['wind']['deg'] ?? 0,
        ),
        clouds: entities.Clouds(
          all: json['clouds']['all'] ?? 0,
        ),
        dt: json['dt'] ?? 0,
        sys: entities.Sys(
          type: json['sys']['type'] ?? 0,
          id: json['sys']['id'] ?? 0,
          country: json['sys']['country'] ?? '',
          sunrise: json['sys']['sunrise'] ?? 0,
          sunset: json['sys']['sunset'] ?? 0,
        ),
        timezone: json['timezone'] ?? 0,
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        cod: json['cod'] ?? 200,
      );
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

  /// Parses XML response into Weather entity
  entities.Weather _parseWeatherXml(XmlDocument document) {
    final cityElement = document.findAllElements('city').firstOrNull;
    if (cityElement == null) {
      throw Exception('XML parsing error: City element not found.');
    }

    final temperatureElement =
        document.findAllElements('temperature').firstOrNull;
    final humidityElement = document.findAllElements('humidity').firstOrNull;
    final windElement = document.findAllElements('wind').firstOrNull;
    final pressureElement = document.findAllElements('pressure').firstOrNull;
    final cloudsElement = document.findAllElements('clouds').firstOrNull;
    final weatherElement = document.findAllElements('weather').firstOrNull;
    final sysElement = document.findAllElements('country').firstOrNull;
    final coordElement = cityElement.findAllElements('coord').firstOrNull;
    final sunElement = document.findAllElements('sun').firstOrNull;
    final feelsLikeElement = document.findAllElements('feels_like').firstOrNull;
    final lastUpdateElement =
        document.findAllElements('lastupdate').firstOrNull;
    final timezoneElement = cityElement.findAllElements('timezone').firstOrNull;

    // Helper function to safely get and parse an attribute
    double? safeParseDoubleAttribute(
        XmlElement? element, String attributeName) {
      final value = element?.getAttribute(attributeName);
      return value != null ? double.tryParse(value) : null;
    }

    int? safeParseIntAttribute(XmlElement? element, String attributeName) {
      final value = element?.getAttribute(attributeName);
      return value != null ? int.tryParse(value) : null;
    }

    int? safeParseIntInnerText(XmlElement? element) {
      final value = element?.innerText;
      return value != null ? int.tryParse(value) : null;
    }

    return entities.Weather(
      coord: entities.Coord(
        lon: safeParseDoubleAttribute(coordElement, 'lon') ?? 0.0,
        lat: safeParseDoubleAttribute(coordElement, 'lat') ?? 0.0,
      ),
      weather: [
        if (weatherElement != null) // Only add if weather element exists
          entities.WeatherCondition(
            id: safeParseIntAttribute(weatherElement, 'number') ?? 0,
            main: weatherElement.getAttribute('value') ?? '',
            description: weatherElement.getAttribute('value') ?? '',
            icon: weatherElement.getAttribute('icon') ?? '',
          ),
      ],
      base: '',
      main: entities.Main(
        temp: safeParseDoubleAttribute(temperatureElement, 'value') ?? 0.0,
        feelsLike: safeParseDoubleAttribute(feelsLikeElement, 'value') ?? 0.0,
        tempMin: safeParseDoubleAttribute(temperatureElement, 'min') ?? 0.0,
        tempMax: safeParseDoubleAttribute(temperatureElement, 'max') ?? 0.0,
        pressure: safeParseIntAttribute(pressureElement, 'value') ?? 0,
        humidity: safeParseIntAttribute(humidityElement, 'value') ?? 0,
        seaLevel: 0,
        grndLevel: 0,
      ),
      visibility: safeParseIntAttribute(
              document.findAllElements('visibility').firstOrNull, 'value') ??
          0, // Use firstOrNull here too
      wind: entities.Wind(
        speed: safeParseDoubleAttribute(
                windElement?.findAllElements('speed').firstOrNull, 'value') ??
            0.0,
        deg: safeParseIntAttribute(
                windElement?.findAllElements('direction').firstOrNull,
                'value') ??
            0,
      ),
      clouds: entities.Clouds(
        all: safeParseIntAttribute(cloudsElement, 'value') ?? 0,
      ),
      dt: (() {
        final lastUpdateValue = lastUpdateElement?.getAttribute('value');
        if (lastUpdateValue != null) {
          final dateTime = DateTime.tryParse(lastUpdateValue);
          if (dateTime != null) {
            return (dateTime.millisecondsSinceEpoch ~/ 1000);
          }
        }
        return 0;
      })(),
      sys: entities.Sys(
        type: 0,
        id: 0,
        country: sysElement?.innerText ?? '',
        sunrise: (() {
          final sunriseValue = sunElement?.getAttribute('rise');
          if (sunriseValue != null) {
            final dateTime = DateTime.tryParse(sunriseValue);
            if (dateTime != null) {
              return (dateTime.millisecondsSinceEpoch ~/ 1000);
            }
          }
          return 0;
        })(),
        sunset: (() {
          final sunsetValue = sunElement?.getAttribute('set');
          if (sunsetValue != null) {
            final dateTime = DateTime.tryParse(sunsetValue);
            if (dateTime != null) {
              return (dateTime.millisecondsSinceEpoch ~/ 1000);
            }
          }
          return 0;
        })(),
      ),
      timezone: safeParseIntInnerText(timezoneElement) ?? 0,
      id: safeParseIntAttribute(cityElement, 'id') ?? 0,
      name: cityElement.getAttribute('name') ?? '',
      cod: safeParseIntAttribute(
              document.findAllElements('current').firstOrNull, 'cod') ??
          200, // Cod might be in a different element for XML
    );
  }
}
