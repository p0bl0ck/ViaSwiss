import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/config/app_config.dart';

class GraphQLService {
  static GraphQLClient? _client;

  static GraphQLClient getClient() {
    if (_client != null) return _client!;

    final HttpLink httpLink = HttpLink(
      AppConfig.graphqlEndpoint,
    );

    final Link link = httpLink;

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.cacheFirst,
        ),
        mutate: Policies(
          fetch: FetchPolicy.networkOnly,
        ),
      ),
    );

    return _client!;
  }

  static void resetClient() {
    _client = null;
  }
}

// Provider for GraphQL client
final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  return GraphQLService.getClient();
});
