import 'package:klimatrack_app/domain/entities/geo_position.dart';

abstract class LocationRepository {
  Future<bool> isLocationServiceEnabled();

  Future<GeoPosition?> getCurrentPosition();
}
