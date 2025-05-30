import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:intl/intl.dart';
import 'package:klimatrack_app/data/models/weather_model.dart';
import 'package:klimatrack_app/utils/string_extensions.dart';

class WeatherCard extends StatefulWidget {
  final WeatherModel weather;

  const WeatherCard({
    super.key,
    required this.weather,
  });

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with TickerProviderStateMixin {
  late final GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                widget.weather.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${widget.weather.main.temp.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                DateFormat('EEEE, MMM dd').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.weather.weather.isNotEmpty) ...[
                ShakeY(
                  from: 20,
                  duration: const Duration(milliseconds: 3500),
                  infinite: true,
                  child: Image.asset(
                    'assets/weather_icons/${widget.weather.weather.first.icon}.png',
                    height: 250,
                  ),
                ),
                Text(
                  widget.weather.weather.first.description
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildWeatherInfo(
              context,
              'Humidity',
              '${widget.weather.main.humidity}%',
              Icons.water_drop,
            ),
            _buildWeatherInfo(
              context,
              'Wind',
              '${widget.weather.wind.speed} m/s',
              Icons.air,
            ),
            _buildWeatherInfo(
              context,
              'Pressure',
              '${widget.weather.main.pressure} hPa',
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
