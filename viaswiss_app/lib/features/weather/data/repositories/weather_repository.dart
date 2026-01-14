import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../shared/graphql/graphql_client.dart';
import '../../domain/models/weather.dart';
import '../graphql/weather_queries.dart';

class WeatherRepository {
  final GraphQLClient _client;

  WeatherRepository(this._client);

  Future<Weather?> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getWeatherQuery),
        variables: {
          'latitude': latitude,
          'longitude': longitude,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final weatherJson = result.data?['weather'];
    if (weatherJson == null) return null;

    return Weather.fromJson(weatherJson);
  }
}

// Provider
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return WeatherRepository(client);
});
