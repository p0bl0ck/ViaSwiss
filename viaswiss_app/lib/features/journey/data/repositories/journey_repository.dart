import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../shared/graphql/graphql_client.dart';
import '../../domain/models/journey.dart';
import '../../domain/models/route_recommendation.dart';
import '../graphql/journey_queries.dart';

class JourneyRepository {
  final GraphQLClient _client;

  JourneyRepository(this._client);

  Future<List<Journey>> getJourneys({
    required String from,
    required String to,
    DateTime? departureTime,
    int limit = 5,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getJourneysQuery),
        variables: {
          'from': from,
          'to': to,
          'departureTime': departureTime?.toIso8601String(),
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> journeys = result.data?['journeys'] ?? [];
    return journeys.map((json) => Journey.fromJson(json)).toList();
  }

  Future<List<RouteRecommendation>> getRouteRecommendations({
    required String from,
    required String to,
    DateTime? departureTime,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getRouteRecommendationsQuery),
        variables: {
          'from': from,
          'to': to,
          'departureTime': departureTime?.toIso8601String(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> recommendations =
        result.data?['routeRecommendations'] ?? [];
    return recommendations
        .map((json) => RouteRecommendation.fromJson(json))
        .toList();
  }
}

// Provider
final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return JourneyRepository(client);
});
