import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/station_repository.dart';
import '../domain/models/station.dart';

// Station search query provider using Notifier pattern
class StationSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final stationSearchQueryProvider =
    NotifierProvider<StationSearchQueryNotifier, String>(
        StationSearchQueryNotifier.new);

// Station search results provider
final stationSearchResultsProvider =
    FutureProvider.autoDispose<List<Station>>((ref) async {
  final query = ref.watch(stationSearchQueryProvider);

  if (query.isEmpty || query.length < 2) {
    return [];
  }

  final repository = ref.watch(stationRepositoryProvider);
  return repository.searchStations(query, limit: 10);
});

// Single station provider
final stationProvider =
    FutureProvider.autoDispose.family<Station?, String>((ref, id) async {
  final repository = ref.watch(stationRepositoryProvider);
  return repository.getStation(id);
});
