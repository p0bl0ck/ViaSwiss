import 'package:flutter_test/flutter_test.dart';
import 'package:viaswiss_app/features/search/domain/models/station.dart';
import '../../helpers/mock_data.dart';

void main() {
  group('Station', () {
    test('creates station with all fields', () {
      final station = MockData.zurichHB;

      expect(station.id, '8503000');
      expect(station.name, 'Zürich HB');
      expect(station.coordinates.latitude, 47.3782);
      expect(station.coordinates.longitude, 8.5402);
    });

    test('serializes to JSON correctly', () {
      final station = MockData.zurichHB;
      final json = station.toJson();

      expect(json['id'], '8503000');
      expect(json['name'], 'Zürich HB');
      expect(json['coordinates']['latitude'], 47.3782);
      expect(json['coordinates']['longitude'], 8.5402);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': '8507000',
        'name': 'Bern',
        'coordinates': {'latitude': 46.9480, 'longitude': 7.4395},
      };

      final station = Station.fromJson(json);

      expect(station.id, '8507000');
      expect(station.name, 'Bern');
      expect(station.coordinates.latitude, 46.9480);
      expect(station.coordinates.longitude, 7.4395);
    });

    test('round-trip serialization preserves data', () {
      final original = MockData.zurichHB;
      final json = original.toJson();
      final deserialized = Station.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
      expect(deserialized.coordinates.latitude, original.coordinates.latitude);
      expect(
        deserialized.coordinates.longitude,
        original.coordinates.longitude,
      );
    });

    test('equality works correctly', () {
      final station1 = const Station(
        id: '123',
        name: 'Test',
        coordinates: Coordinates(latitude: 1.0, longitude: 2.0),
      );

      final station2 = const Station(
        id: '123',
        name: 'Test',
        coordinates: Coordinates(latitude: 1.0, longitude: 2.0),
      );

      expect(station1, equals(station2));
    });

    test('different stations are not equal', () {
      final station1 = MockData.zurichHB;
      final station2 = MockData.bern;

      expect(station1, isNot(equals(station2)));
    });
  });

  group('Coordinates', () {
    test('creates coordinates with latitude and longitude', () {
      final coords = const Coordinates(latitude: 47.3782, longitude: 8.5402);

      expect(coords.latitude, 47.3782);
      expect(coords.longitude, 8.5402);
    });

    test('serializes to JSON correctly', () {
      final coords = const Coordinates(latitude: 47.3782, longitude: 8.5402);
      final json = coords.toJson();

      expect(json['latitude'], 47.3782);
      expect(json['longitude'], 8.5402);
    });

    test('deserializes from JSON correctly', () {
      final json = {'latitude': 46.9480, 'longitude': 7.4395};
      final coords = Coordinates.fromJson(json);

      expect(coords.latitude, 46.9480);
      expect(coords.longitude, 7.4395);
    });

    test('handles negative coordinates', () {
      final coords = const Coordinates(latitude: -12.34, longitude: -56.78);

      expect(coords.latitude, -12.34);
      expect(coords.longitude, -56.78);
    });

    test('handles zero coordinates', () {
      final coords = const Coordinates(latitude: 0.0, longitude: 0.0);

      expect(coords.latitude, 0.0);
      expect(coords.longitude, 0.0);
    });
  });
}
