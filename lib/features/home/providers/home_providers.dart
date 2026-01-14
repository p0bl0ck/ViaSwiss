import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/models/station.dart';

// Selected stations provider
class SelectedStationsNotifier extends StateNotifier<SelectedStations> {
  SelectedStationsNotifier()
      : super(const SelectedStations(from: null, to: null));

  void setFromStation(Station station) {
    state = state.copyWith(from: station);
  }

  void setToStation(Station station) {
    state = state.copyWith(to: station);
  }

  void swapStations() {
    state = SelectedStations(from: state.to, to: state.from);
  }

  void clearStations() {
    state = const SelectedStations(from: null, to: null);
  }
}

class SelectedStations {
  final Station? from;
  final Station? to;

  const SelectedStations({
    required this.from,
    required this.to,
  });

  SelectedStations copyWith({
    Station? from,
    Station? to,
  }) {
    return SelectedStations(
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

final selectedStationsProvider =
    StateNotifierProvider<SelectedStationsNotifier, SelectedStations>((ref) {
  return SelectedStationsNotifier();
});

// Departure time provider
final departureTimeProvider = StateProvider<DateTime?>((ref) => null);
