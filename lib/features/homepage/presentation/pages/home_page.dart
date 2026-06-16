// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/error_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/loading_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/search_bar.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/weather_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          children: [
            WeatherSearchBar(
              controller: searchController,
              onSearch: (city, format) {
                context.read<WeatherBloc>().add(
                      FetchWeatherByCity(city: city, format: format),
                    );
              },
              onLocationPressed: (format) {
                context.read<WeatherBloc>().add(
                      FetchCurrentLocationWeather(format: format),
                    );
                searchController.clear();
              },
            ),
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoading) {
                    return LoadingWidget(format: state.format);
                  } else if (state is WeatherLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: WeatherCard(weather: state.weather),
                    );
                  } else if (state is WeatherError) {
                    return WeatherErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context
                            .read<WeatherBloc>()
                            .add(const RetryLastWeatherFetch());
                      },
                    );
                  }
                  return const Center(
                    child: Text('Search for a city or use your location.'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
