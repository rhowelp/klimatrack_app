import 'package:flutter/material.dart';
import 'package:klimatrack_app/core/constants/api_format.dart';

class WeatherSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, ApiFormat) onSearch;
  final Function(ApiFormat) onLocationPressed;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onLocationPressed,
  });

  @override
  State<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends State<WeatherSearchBar> {
  ApiFormat _selectedFormat = ApiFormat.json;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () => widget.onLocationPressed(_selectedFormat),
                  tooltip: 'Get current location',
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              ),
              onSubmitted: (city) => widget.onSearch(city, _selectedFormat),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: DropdownButton<ApiFormat>(
              value: _selectedFormat,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              underline: Container(
                height: 0,
              ),
              onChanged: (ApiFormat? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFormat = newValue;
                  });
                }
              },
              items: ApiFormat.values
                  .map<DropdownMenuItem<ApiFormat>>((ApiFormat format) {
                return DropdownMenuItem<ApiFormat>(
                  value: format,
                  child: Text(format.name.toUpperCase()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
