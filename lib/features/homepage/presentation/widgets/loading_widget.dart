import 'package:flutter/material.dart';
import 'package:klimatrack_app/domain/constants/api_format.dart';

class LoadingWidget extends StatelessWidget {
  final ApiFormat format;

  const LoadingWidget({
    super.key,
    this.format = ApiFormat.json,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${format.name.toUpperCase()} Format: Fetching Weather...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
