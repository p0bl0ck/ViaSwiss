import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../shared/graphql/graphql_client.dart';
import '../../domain/models/station.dart';
import '../graphql/station_queries.dart';

class StationRepository {
  final GraphQLClient _client;

  StationRepository(this._client);

  Future<List<Station>> searchStations(String query, {int limit = 10}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(searchStationsQuery),
        variables: {
          'query': query,
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly, // Always fresh for search
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> stations = result.data?['searchStations'] ?? [];
    return stations.map((json) => Station.fromJson(json)).toList();
  }

  Future<Station?> getStation(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getStationQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final stationJson = result.data?['station'];
    if (stationJson == null) return null;

    return Station.fromJson(stationJson);
  }
}

// Provider
final stationRepositoryProvider = Provider<StationRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return StationRepository(client);
});
