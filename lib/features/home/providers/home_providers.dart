import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/models/station.dart';

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

// Selected stations provider using Notifier (Riverpod 3.x pattern)
class SelectedStationsNotifier extends Notifier<SelectedStations> {
  @override
  SelectedStations build() {
    return const SelectedStations(from: null, to: null);
  }

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

final selectedStationsProvider =
    NotifierProvider<SelectedStationsNotifier, SelectedStations>(
        SelectedStationsNotifier.new);

// Departure time provider using Notifier pattern
class DepartureTimeNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setDepartureTime(DateTime? time) {
    state = time;
  }
}

final departureTimeProvider =
    NotifierProvider<DepartureTimeNotifier, DateTime?>(DepartureTimeNotifier.new);
