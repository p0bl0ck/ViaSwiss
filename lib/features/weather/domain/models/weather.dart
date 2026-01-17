import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../search/domain/models/station.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

enum WeatherCondition {
  @JsonValue('CLEAR')
  clear,
  @JsonValue('PARTLY_CLOUDY')
  partlyCloudy,
  @JsonValue('CLOUDY')
  cloudy,
  @JsonValue('RAINY')
  rainy,
  @JsonValue('SNOWY')
  snowy,
  @JsonValue('STORMY')
  stormy,
  @JsonValue('FOGGY')
  foggy,
}

@freezed
sealed class Weather with _$Weather {
  const factory Weather({
    required Coordinates location,
    required double temperature,
    required WeatherCondition condition,
    required int precipitationProbability,
    double? windSpeed,
    required DateTime timestamp,
    required List<WeatherForecast> forecast,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

@freezed
sealed class WeatherForecast with _$WeatherForecast {
  const factory WeatherForecast({
    required DateTime timestamp,
    required double temperature,
    required WeatherCondition condition,
    required int precipitationProbability,
  }) = _WeatherForecast;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
}
