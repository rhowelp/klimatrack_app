// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';
import 'package:klimatrack_app/core/services/location_service.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/error_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/loading_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/search_bar.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/weather_card.dart';

/// HomePage widget that displays the main weather interface
/// Dispatches events to the WeatherBloc based on user interactions
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // We no longer need local state for search controller, format, or location service
    // The Bloc manages the state and logic.
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          children: [
            WeatherSearchBar(
              controller: searchController,
              onSearch: (city, format) {
                // Call FetchWeatherByCity event
                context
                    .read<WeatherBloc>()
                    .add(FetchWeatherByCity(city: city, format: format));
              },
              onLocationPressed: (format) {
                // Call an event to fetch weather for the current location
                context
                    .read<WeatherBloc>()
                    .add(FetchCurrentLocationWeather(format: format));
                searchController.clear();
              },
            ),
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoading) {
                    return LoadingWidget(
                        format: state.message.contains('XML')
                            ? ApiFormat.xml
                            : ApiFormat
                                .json); // Pass format based on loading message for now
                  } else if (state is WeatherLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: WeatherCard(weather: state.weather),
                    );
                  } else if (state is WeatherError) {
                    // We need a way to retry the correct action (city or location)
                    return WeatherErrorWidget(
                      message: state.message,
                      onRetry: () {
                        // Dispatch an event to retry the last action
                        // This requires the Bloc to remember the last action/parameters
                        context
                            .read<WeatherBloc>()
                            .add(const RetryLastWeatherFetch());
                      },
                    );
                  }
                  // Initial state or no weather data yet
                  return const Center(
                      child: Text('Search for a city or use your location.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // No dispose method needed for StatelessWidget
}
