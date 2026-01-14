import 'package:flutter_test/flutter_test.dart';
import 'package:viaswiss_app/features/journey/domain/models/journey.dart';
import 'package:viaswiss_app/features/journey/domain/models/transport.dart';
import '../../helpers/mock_data.dart';

void main() {
  group('Journey', () {
    test('creates journey with all fields', () {
      final journey = MockData.mockJourneys.first;

      expect(journey.id, isNotEmpty);
      expect(journey.from, isNotNull);
      expect(journey.to, isNotNull);
      expect(journey.departure, isA<DateTime>());
      expect(journey.arrival, isA<DateTime>());
      expect(journey.duration, greaterThan(0));
      expect(journey.transfers, greaterThanOrEqualTo(0));
      expect(journey.legs, isNotEmpty);
    });

    test('creates journey without scenic score', () {
      final journey = MockData.createMockJourney(scenicScore: null);

      expect(journey.scenicScore, isNull);
    });

    test('creates journey with scenic score', () {
      final journey = MockData.createMockJourney(scenicScore: 0.85);

      expect(journey.scenicScore, 0.85);
    });

    test('duration is calculated correctly', () {
      final departure = DateTime(2024, 1, 15, 10, 0);
      final arrival = DateTime(2024, 1, 15, 12, 30);
      final journey = MockData.createMockJourney(
        departure: departure,
        arrival: arrival,
        duration: 150, // 2.5 hours = 150 minutes
      );

      expect(journey.duration, 150);
      expect(journey.arrival.difference(journey.departure).inMinutes, 150);
    });

    test('handles direct journey (no transfers)', () {
      final journey = MockData.createMockJourney(transfers: 0);

      expect(journey.transfers, 0);
    });

    test('handles journey with multiple transfers', () {
      final journey = MockData.createMockJourney(transfers: 3);

      expect(journey.transfers, 3);
    });

    test('serializes to JSON correctly', () {
      final journey = MockData.mockJourneys.first;
      final json = journey.toJson();

      expect(json['id'], journey.id);
      expect(json['from']['id'], journey.from.id);
      expect(json['to']['id'], journey.to.id);
      expect(json['duration'], journey.duration);
      expect(json['transfers'], journey.transfers);
      expect(json['legs'], isA<List>());
    });

    test('round-trip serialization preserves data', () {
      final original = MockData.mockJourneys.first;
      final json = original.toJson();
      final deserialized = Journey.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.from.id, original.from.id);
      expect(deserialized.to.id, original.to.id);
      expect(deserialized.duration, original.duration);
      expect(deserialized.transfers, original.transfers);
      expect(deserialized.legs.length, original.legs.length);
    });
  });

  group('Transport', () {
    test('creates IC transport', () {
      final transport = MockData.icTransport;

      expect(transport.type, TransportType.ic);
      expect(transport.number, '1');
      expect(transport.operator, 'SBB');
      expect(transport.line, 'IC 1');
    });

    test('creates IR transport', () {
      final transport = MockData.irTransport;

      expect(transport.type, TransportType.ir);
      expect(transport.number, '15');
    });

    test('serializes to JSON correctly', () {
      final transport = MockData.icTransport;
      final json = transport.toJson();

      expect(json['type'], 'IC');
      expect(json['number'], '1');
      expect(json['operator'], 'SBB');
      expect(json['line'], 'IC 1');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'type': 'IC',
        'number': '5',
        'operator': 'SBB',
        'line': 'IC 5',
      };

      final transport = Transport.fromJson(json);

      expect(transport.type, TransportType.ic);
      expect(transport.number, '5');
      expect(transport.operator, 'SBB');
      expect(transport.line, 'IC 5');
    });

    test('handles all transport types', () {
      final types = [
        TransportType.ic,
        TransportType.ir,
        TransportType.re,
        TransportType.s,
        TransportType.ice,
        TransportType.ec,
        TransportType.bus,
        TransportType.tram,
      ];

      for (final type in types) {
        final transport = Transport(
          type: type,
          number: '1',
          operator: 'Test',
        );

        expect(transport.type, type);
      }
    });
  });

  group('Leg', () {
    test('creates leg with all required fields', () {
      final leg = MockData.createMockLeg(
        from: MockData.zurichHB,
        to: MockData.bern,
        departure: DateTime(2024, 1, 15, 10, 0),
        arrival: DateTime(2024, 1, 15, 12, 0),
      );

      expect(leg.from, MockData.zurichHB);
      expect(leg.to, MockData.bern);
      expect(leg.departure, isA<DateTime>());
      expect(leg.arrival, isA<DateTime>());
      expect(leg.transport, isNotNull);
    });

    test('creates leg with platform', () {
      final leg = MockData.createMockLeg(
        from: MockData.zurichHB,
        to: MockData.bern,
        departure: DateTime.now(),
        arrival: DateTime.now().add(Duration(hours: 1)),
        platform: '7',
      );

      expect(leg.platform, '7');
    });

    test('creates leg with delay', () {
      final leg = MockData.createMockLeg(
        from: MockData.zurichHB,
        to: MockData.bern,
        departure: DateTime.now(),
        arrival: DateTime.now().add(Duration(hours: 1)),
        delay: 5,
      );

      expect(leg.delay, 5);
    });

    test('creates leg without delay (on time)', () {
      final leg = MockData.createMockLeg(
        from: MockData.zurichHB,
        to: MockData.bern,
        departure: DateTime.now(),
        arrival: DateTime.now().add(Duration(hours: 1)),
        delay: null,
      );

      expect(leg.delay, isNull);
    });

    test('serializes to JSON correctly', () {
      final leg = MockData.createMockLeg(
        from: MockData.zurichHB,
        to: MockData.bern,
        departure: DateTime(2024, 1, 15, 10, 0),
        arrival: DateTime(2024, 1, 15, 12, 0),
        platform: '4',
        delay: 3,
      );

      final json = leg.toJson();

      expect(json['from']['id'], MockData.zurichHB.id);
      expect(json['to']['id'], MockData.bern.id);
      expect(json['platform'], '4');
      expect(json['delay'], 3);
      expect(json['transport'], isA<Map>());
    });
  });
}
