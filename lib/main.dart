import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/core/injectors/dependency_injector.dart' as di;
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:klimatrack_app/features/splash/presentation/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WeatherBloc>(
      create: (context) {
        final bloc = di.dpLocator.get<WeatherBloc>();
        bloc.add(
          const FetchCurrentLocationWeather(format: ApiFormat.json),
        );
        return bloc;
      },
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
