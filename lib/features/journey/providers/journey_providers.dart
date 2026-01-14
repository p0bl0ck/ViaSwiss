import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/journey_repository.dart';
import '../domain/models/journey.dart';
import '../domain/models/route_recommendation.dart';

// Journey search parameters
class JourneySearchParams {
  final String fromId;
  final String toId;
  final DateTime? departureTime;
  final int limit;

  const JourneySearchParams({
    required this.fromId,
    required this.toId,
    this.departureTime,
    this.limit = 5,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneySearchParams &&
          runtimeType == other.runtimeType &&
          fromId == other.fromId &&
          toId == other.toId &&
          departureTime == other.departureTime &&
          limit == other.limit;

  @override
  int get hashCode =>
      fromId.hashCode ^
      toId.hashCode ^
      departureTime.hashCode ^
      limit.hashCode;
}

// Journeys provider
final journeysProvider = FutureProvider.autoDispose
    .family<List<Journey>, JourneySearchParams>((ref, params) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getJourneys(
    from: params.fromId,
    to: params.toId,
    departureTime: params.departureTime,
    limit: params.limit,
  );
});

// Route recommendations provider
final routeRecommendationsProvider = FutureProvider.autoDispose
    .family<List<RouteRecommendation>, JourneySearchParams>((ref, params) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getRouteRecommendations(
    from: params.fromId,
    to: params.toId,
    departureTime: params.departureTime,
  );
});
