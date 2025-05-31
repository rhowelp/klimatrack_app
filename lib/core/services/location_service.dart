import 'dart:developer';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        log('Location permission denied, requesting permission');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permission denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permission permanently denied');
        return null;
      }

      log('Getting current position');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      log('Current position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      log('Error getting location', error: e);
      return null;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getLastKnownLocation() async {
    try {
      log('Getting last known position');
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        log('Last known position obtained: ${position.latitude}, ${position.longitude}');
      } else {
        log('No last known position available');
      }
      return position;
    } catch (e) {
      log('Error getting last known location', error: e);
      return null;
    }
  }
}
