import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:klimatrack_app/domain/entities/weather.dart';
import 'package:klimatrack_app/core/services/utils.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;

  const WeatherCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.52,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.white, Colors.green],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                weather.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${weather.main.temp.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                DateFormat('EEEE, MMM dd').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        weather.dt * 1000)),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (weather.weather.isNotEmpty) ...[
                ShakeY(
                  from: 15,
                  duration: const Duration(milliseconds: 4500),
                  infinite: true,
                  child: Image.asset(
                    'assets/weather_icons/${weather.weather.first.icon}.png',
                    height: 250,
                  ),
                ),
                Text(
                  weather.weather.first.description
                      .toCapitalizedEachWord(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildWeatherInfo(
              context,
              'Humidity',
              '${weather.main.humidity}%',
              Icons.water_drop,
            ),
            _buildWeatherInfo(
              context,
              'Wind',
              '${weather.wind.speed} m/s',
              Icons.air,
            ),
            _buildWeatherInfo(
              context,
              'Pressure',
              '${weather.main.pressure} hPa',
              Icons.speed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 25,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
