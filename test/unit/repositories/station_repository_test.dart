import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viaswiss_app/features/search/data/repositories/station_repository.dart';
import 'package:viaswiss_app/features/search/domain/models/station.dart';
import '../../helpers/mock_data.dart';

// Mock GraphQL Client
class MockGraphQLClient extends Mock implements GraphQLClient {}

// Fake QueryOptions for mocktail
class FakeQueryOptions extends Fake implements QueryOptions<Object?> {}

void main() {
  late MockGraphQLClient mockClient;
  late StationRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeQueryOptions());
  });

  setUp(() {
    mockClient = MockGraphQLClient();
    repository = StationRepository(mockClient);
  });

  group('StationRepository', () {
    group('searchStations', () {
      test('returns list of stations on successful query', () async {
        // Arrange
        final mockResponse = QueryResult(
          data: MockData.mockStationSearchResponse,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('query { __typename }')),
        );

        when(() => mockClient.query(any())).thenAnswer(
          (_) async => mockResponse,
        );

        // Act
        final result = await repository.searchStations('Zürich');

        // Assert
        expect(result, isA<List<Station>>());
        expect(result.length, 2);
        expect(result.first.name, 'Zürich HB');
        verify(() => mockClient.query(any())).called(1);
      });

      test('returns empty list when no stations found', () async {
        // Arrange
        final mockResponse = QueryResult(
          data: {'searchStations': []},
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('query { __typename }')),
        );

        when(() => mockClient.query(any())).thenAnswer(
          (_) async => mockResponse,
        );

        // Act
        final result = await repository.searchStations('NonExistent');

        // Assert
        expect(result, isEmpty);
      });

      test('passes correct limit parameter', () async {
        // Arrange
        final mockResponse = QueryResult(
          data: MockData.mockStationSearchResponse,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('query { __typename }')),
        );

        when(() => mockClient.query(any())).thenAnswer(
          (_) async => mockResponse,
        );

        // Act
        await repository.searchStations('Zürich', limit: 5);

        // Assert
        final captured = verify(() => mockClient.query(captureAny())).captured;
        final queryOptions = captured.first as QueryOptions;
        expect(queryOptions.variables['limit'], 5);
      });

      test('uses default limit when not specified', () async {
        // Arrange
        final mockResponse = QueryResult(
          data: MockData.mockStationSearchResponse,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('query { __typename }')),
        );

        when(() => mockClient.query(any())).thenAnswer(
          (_) async => mockResponse,
        );

        // Act
        await repository.searchStations('Zürich');

        // Assert
        final captured = verify(() => mockClient.query(captureAny())).captured;
        final queryOptions = captured.first as QueryOptions;
        expect(queryOptions.variables['limit'], 10);
      });

      test('throws exception on GraphQL error', () async {
        // Arrange
        final mockResponse = QueryResult(
          data: null,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('query { __typename }')),
          exception: OperationException(
            graphqlErrors: [
              const GraphQLError(message: 'Network error'),
            ],
          ),
        );

        when(() => mockClient.query(any())).thenAnswer(
          (_) async => mockResponse,
        );

        // Act & Assert
        expect(
          () => repository.searchStations('Zürich'),
          throwsA(isA<OperationException>()),
        );
      });

      test('uses network-only fetch policy', () async {
        // Arrange
        final mockResponse = QueryResult(
          data: MockData.mockStationSearchResponse,
          source: QueryResultSource.network,
          options: QueryOptions(document: gql('query { __typename }')),
        );

        when(() => mockClient.query(any())).thenAnswer(
          (_) async => mockResponse,
        );

        // Act
        await repository.searchStations('Zürich');

        // Assert
        final captured = verify(() => mockClient.query(captureAny())).captured;
        final queryOptions = captured.first as QueryOptions;
        expect(queryOptions.fetchPolicy, FetchPolicy.networkOnly);
      });
    });
  });
}
