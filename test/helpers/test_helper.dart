import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:klimatrack_app/core/services/location_service.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/repositories/location_repository.dart';
import 'package:klimatrack_app/domain/repositories/openweather_repository.dart'
    as domain;
import 'package:klimatrack_app/domain/usecases/get_current_location_weather.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_city.dart';
import 'package:klimatrack_app/domain/usecases/get_weather_by_location.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';

@GenerateMocks([
  Dio,
  LocationService,
  OpenWeatherRepositoryImpl,
  domain.OpenWeatherRepository,
  LocationRepository,
  GetWeatherByCityUseCase,
  GetWeatherByLocationUseCase,
  GetCurrentLocationWeatherUseCase,
])
void main() {}

// Test data
const testCity = 'Taguig City';
const testLat = 14.5243;
const testLon = 121.0792;

final testWeatherResponse = {
  'weather': [
    {
      'id': 800,
      'main': 'Clear',
      'description': 'clear sky',
      'icon': '01d',
    }
  ],
  'main': {
    'temp': 293.15,
    'feels_like': 293.15,
    'temp_min': 293.15,
    'temp_max': 293.15,
    'pressure': 1013,
    'humidity': 64,
    'sea_level': 1013,
    'grnd_level': 1013,
  },
  'wind': {
    'speed': 4.12,
    'deg': 280,
  },
  'clouds': {
    'all': 0,
  },
  'dt': 1709123456,
  'sys': {
    'type': 1,
    'id': 8160,
    'country': 'PH',
    'sunrise': 1749504371,
    'sunset': 1749551052,
  },
  'coord': {
    'lon': 121.0792,
    'lat': 14.5243,
  },
  'base': 'stations',
  'visibility': 10000,
  'timezone': 0,
  'id': 2643743,
  'name': 'Taguig City',
  'cod': 200,
};

final testWeather = Weather(
  name: 'Taguig City',
  weather: const [
    WeatherCondition(
      id: 800,
      main: 'Clear',
      description: 'clear sky',
      icon: '01d',
    ),
  ],
  main: const Main(
    temp: 293.15,
    feelsLike: 293.15,
    tempMin: 293.15,
    tempMax: 293.15,
    pressure: 1013,
    humidity: 64,
    seaLevel: 1013,
    grndLevel: 1013,
  ),
  wind: const Wind(speed: 4.12, deg: 280),
  clouds: const Clouds(all: 0),
  dt: 1709123456,
  sys: const Sys(
    type: 1,
    id: 8160,
    country: 'PH',
    sunrise: 1749504371,
    sunset: 1749551052,
  ),
  coord: const Coord(lon: 121.0792, lat: 14.5243),
  base: 'stations',
  visibility: 10000,
  timezone: 0,
  id: 2643743,
  cod: 200,
);
