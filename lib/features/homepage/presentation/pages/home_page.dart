import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klimatrack_app/domain/services/location_service.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/error_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/loading_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/search_bar.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/weather_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _locationService = LocationService();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    log('Starting location fetch');
    try {
      final isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please enable location services to get weather data'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        log('Location obtained, fetching weather data');
        context.read<WeatherBloc>().add(
              FetchWeatherByLocation(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Unable to get location. Please check your location permissions.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      log('Error in _getCurrentLocation', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _searchCity(String city) {
    if (city.isNotEmpty) {
      log('Searching for city: $city');
      context.read<WeatherBloc>().add(FetchWeatherByCity(city));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          children: [
            WeatherSearchBar(
              controller: _searchController,
              onSearch: _searchCity,
              onLocationPressed: () {
                _searchController.clear();
                _getCurrentLocation();
              },
            ),
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoading) {
                    return const LoadingWidget();
                  } else if (state is WeatherLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: WeatherCard(weather: state.weather),
                    );
                  } else if (state is WeatherError) {
                    return WeatherErrorWidget(
                      message: state.message,
                      onRetry: _getCurrentLocation,
                    );
                  }
                  return const LoadingWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
