import 'package:klimatrack_app/core/services/location_service.dart';
import 'package:klimatrack_app/domain/entities/geo_position.dart';
import 'package:klimatrack_app/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationService locationService;

  LocationRepositoryImpl(this.locationService);

  @override
  Future<bool> isLocationServiceEnabled() {
    return locationService.isLocationServiceEnabled();
  }

  @override
  Future<GeoPosition?> getCurrentPosition() async {
    final position = await locationService.getCurrentLocation();
    if (position == null) {
      return null;
    }

    return GeoPosition(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
