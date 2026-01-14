import 'package:flutter_riverpod/flutter_riverpod.dart';

// Map zoom level provider
final mapZoomLevelProvider = StateProvider<double>((ref) => 8.0);

// Map center provider (latitude, longitude)
final mapCenterProvider =
    StateProvider<MapCenter>((ref) => const MapCenter(46.8182, 8.2275));

class MapCenter {
  final double latitude;
  final double longitude;

  const MapCenter(this.latitude, this.longitude);
}
