// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klimatrack_app/domain/constants/api_format.dart';
import 'package:klimatrack_app/domain/services/location_service.dart';
import 'package:klimatrack_app/features/homepage/presentation/bloc/weather_bloc.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/error_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/loading_widget.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/search_bar.dart';
import 'package:klimatrack_app/features/homepage/presentation/widgets/weather_card.dart';

/// HomePage widget that displays the main weather interface
/// Handles weather search, location-based weather, and format selection
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _locationService = LocationService();
  final _searchController = TextEditingController();
  ApiFormat _selectedFormat = ApiFormat.json;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Fetches weather data for the current location
  /// Handles location service checks and permission validation
  Future<void> _getCurrentLocation() async {
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

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        context.read<WeatherBloc>().add(
              FetchWeatherByLocation(
                latitude: position.latitude,
                longitude: position.longitude,
                format: _selectedFormat,
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

  /// Handles city search with the selected format
  void _searchCity(String city, ApiFormat format) {
    if (city.isNotEmpty) {
      context.read<WeatherBloc>().add(FetchWeatherByCity(city, format: format));
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fetching current location...'),
                    duration: Duration(seconds: 5),
                  ),
                );

                _searchController.clear();
                _getCurrentLocation();
              },
              onFormatChanged: (format) {
                setState(() {
                  _selectedFormat = format;
                });
              },
            ),
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoading) {
                    return LoadingWidget(format: _selectedFormat);
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
