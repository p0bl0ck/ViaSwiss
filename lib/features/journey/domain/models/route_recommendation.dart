import 'package:freezed_annotation/freezed_annotation.dart';
import 'journey.dart';
import '../../../weather/domain/models/weather.dart';

part 'route_recommendation.freezed.dart';
part 'route_recommendation.g.dart';

@freezed
sealed class RouteRecommendation with _$RouteRecommendation {
  const factory RouteRecommendation({
    required Journey journey,
    required Weather weather,
    required List<String> warnings,
    required String recommendation,
  }) = _RouteRecommendation;

  factory RouteRecommendation.fromJson(Map<String, dynamic> json) =>
      _$RouteRecommendationFromJson(json);
}
