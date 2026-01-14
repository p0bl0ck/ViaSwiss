import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/weather_repository.dart';
import '../domain/models/weather.dart';

// Weather coordinates
class WeatherCoordinates {
  final double latitude;
  final double longitude;

  const WeatherCoordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherCoordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

// Weather provider
final weatherProvider = FutureProvider.autoDispose
    .family<Weather?, WeatherCoordinates>((ref, coords) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getWeather(
    latitude: coords.latitude,
    longitude: coords.longitude,
  );
});
