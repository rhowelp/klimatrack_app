import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads environment variables from the project `.env` file for tests.
void loadTestEnv() {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    throw StateError(
      'Missing .env file. Copy .env.example to .env and set OPENWEATHER_API_KEY.',
    );
  }

  dotenv.testLoad(fileInput: envFile.readAsStringSync());
}
