import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klimatrack_app/data/repositories/openweather_repository.dart';
import 'package:klimatrack_app/domain/services/dio_client.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:klimatrack_app/features/splash/presentation/splash_page.dart';

void main() {
  final dio = DioClient.create();
  final weatherRepository = OpenWeatherApiImpl(dio);
  
  runApp(MyApp(openWeatherApiImpl: weatherRepository));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.openWeatherApiImpl});

  final OpenWeatherApiImpl openWeatherApiImpl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(openWeatherApiImpl),
      child: MaterialApp(
        title: 'Klimatrack',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
