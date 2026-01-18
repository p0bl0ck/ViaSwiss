import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/ast.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';

/// Custom logging link that logs all GraphQL requests and responses
class LoggingLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final operationName = request.operation.operationName ?? 'unnamed';
    final operationType = _getOperationType(request.operation.document);
    final variables = request.variables;

    // Log request
    AppLogger.apiRequest(
      operationType: operationType,
      operationName: operationName,
      variables: variables,
    );

    final stopwatch = Stopwatch()..start();

    return forward!(request).transform(
      StreamTransformer<Response, Response>.fromHandlers(
        handleData: (response, sink) {
          stopwatch.stop();

          // Log response
          AppLogger.apiResponse(
            operationName: operationName,
            data: response.data,
            errors: response.errors,
            duration: stopwatch.elapsed,
          );

          sink.add(response);
        },
        handleError: (error, stackTrace, sink) {
          stopwatch.stop();

          // Log error
          AppLogger.apiError(
            operationName: operationName,
            error: error,
            duration: stopwatch.elapsed,
          );

          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  String _getOperationType(DocumentNode document) {
    for (final definition in document.definitions) {
      if (definition is OperationDefinitionNode) {
        switch (definition.type) {
          case OperationType.query:
            return 'Query';
          case OperationType.mutation:
            return 'Mutation';
          case OperationType.subscription:
            return 'Subscription';
        }
      }
    }
    return 'Unknown';
  }
}

class GraphQLService {
  static GraphQLClient? _client;

  static GraphQLClient getClient() {
    if (_client != null) return _client!;

    final HttpLink httpLink = HttpLink(
      AppConfig.graphqlEndpoint,
    );

    // Chain logging link with HTTP link
    final Link link = Link.from([
      LoggingLink(),
      httpLink,
    ]);

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
