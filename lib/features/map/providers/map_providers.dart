import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_providers.g.dart';

class MapCenter {
  final double latitude;
  final double longitude;

  const MapCenter(this.latitude, this.longitude);
}

// Map zoom level provider
@riverpod
class MapZoomLevel extends _$MapZoomLevel {
  @override
  double build() => 8.0;

  void setZoom(double zoom) => state = zoom;
}

// Map center provider (latitude, longitude)
@riverpod
class MapCenterNotifier extends _$MapCenterNotifier {
  @override
  MapCenter build() => const MapCenter(46.8182, 8.2275);

  void setCenter(MapCenter center) => state = center;
}
