import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_dotenv/flutter_dotenv.dart';

@immutable
class Constants {
  static String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
}
