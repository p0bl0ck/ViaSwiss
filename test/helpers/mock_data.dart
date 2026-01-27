import 'package:viaswiss_app/features/search/domain/models/station.dart';
import 'package:viaswiss_app/features/journey/domain/models/journey.dart';
import 'package:viaswiss_app/features/journey/domain/models/leg.dart';
import 'package:viaswiss_app/features/journey/domain/models/transport.dart';
import 'package:viaswiss_app/features/weather/domain/models/weather.dart';

/// Mock data for testing
class MockData {
  // Mock Stations
  static final zurichHB = const Station(
    id: '8503000',
    name: 'Zürich HB',
    coordinates: Coordinates(latitude: 47.3782, longitude: 8.5402),
  );

  static final bern = const Station(
    id: '8507000',
    name: 'Bern',
    coordinates: Coordinates(latitude: 46.9480, longitude: 7.4395),
  );

  static final geneva = const Station(
    id: '8501008',
    name: 'Genève',
    coordinates: Coordinates(latitude: 46.2104, longitude: 6.1430),
  );

  static final interlaken = const Station(
    id: '8507492',
    name: 'Interlaken Ost',
    coordinates: Coordinates(latitude: 46.6863, longitude: 7.8632),
  );

  static List<Station> get mockStations => [zurichHB, bern, geneva, interlaken];

  // Mock Transport
  static final icTransport = const Transport(
    type: TransportType.ic,
    number: '1',
    operator: 'SBB',
    line: 'IC 1',
  );

  static final irTransport = const Transport(
    type: TransportType.ir,
    number: '15',
    operator: 'SBB',
    line: 'IR 15',
  );

  // Mock Legs
  static Leg createMockLeg({
    required Station from,
    required Station to,
    required DateTime departure,
    required DateTime arrival,
    Transport? transport,
    String? platform,
    int? delay,
  }) {
    return Leg(
      from: from,
      to: to,
      departure: departure,
      arrival: arrival,
      transport: transport ?? icTransport,
      platform: platform,
      delay: delay,
    );
  }

  // Mock Journey
  static Journey createMockJourney({
    String? id,
    Station? from,
    Station? to,
    DateTime? departure,
    DateTime? arrival,
    int? duration,
    int? transfers,
    List<Leg>? legs,
    double? scenicScore,
  }) {
    final departureTime = departure ?? DateTime(2024, 1, 15, 10, 0);
    final arrivalTime = arrival ?? DateTime(2024, 1, 15, 12, 30);

    return Journey(
      id: id ?? 'journey-1',
      from: from ?? zurichHB,
      to: to ?? bern,
      departure: departureTime,
      arrival: arrivalTime,
      duration: duration ?? 150,
      transfers: transfers ?? 0,
      legs:
          legs ??
          [
            createMockLeg(
              from: from ?? zurichHB,
              to: to ?? bern,
              departure: departureTime,
              arrival: arrivalTime,
              platform: '4',
            ),
          ],
      scenicScore: scenicScore,
    );
  }

  static List<Journey> get mockJourneys => [
    createMockJourney(
      id: 'journey-1',
      from: zurichHB,
      to: bern,
      duration: 150,
      transfers: 0,
      scenicScore: 0.75,
    ),
    createMockJourney(
      id: 'journey-2',
      from: zurichHB,
      to: bern,
      duration: 180,
      transfers: 1,
      scenicScore: 0.85,
    ),
  ];

  // Mock Weather
  static Weather createMockWeather({
    Coordinates? location,
    double? temperature,
    WeatherCondition? condition,
    int? precipitationProbability,
    double? windSpeed,
    DateTime? timestamp,
    List<WeatherForecast>? forecast,
  }) {
    return Weather(
      location:
          location ?? const Coordinates(latitude: 47.3782, longitude: 8.5402),
      temperature: temperature ?? 15.5,
      condition: condition ?? WeatherCondition.clear,
      precipitationProbability: precipitationProbability ?? 10,
      windSpeed: windSpeed ?? 5.0,
      timestamp: timestamp ?? DateTime.now(),
      forecast: forecast ?? mockWeatherForecast,
    );
  }

  static List<WeatherForecast> get mockWeatherForecast => [
    WeatherForecast(
      timestamp: DateTime.now().add(const Duration(hours: 1)),
      temperature: 16.0,
      condition: WeatherCondition.clear,
      precipitationProbability: 5,
    ),
    WeatherForecast(
      timestamp: DateTime.now().add(const Duration(hours: 2)),
      temperature: 17.0,
      condition: WeatherCondition.partlyCloudy,
      precipitationProbability: 15,
    ),
  ];

  // Mock GraphQL Responses
  static Map<String, dynamic> get mockStationSearchResponse => {
    'searchStations': [
      {
        'id': zurichHB.id,
        'name': zurichHB.name,
        'coordinates': {
          'latitude': zurichHB.coordinates.latitude,
          'longitude': zurichHB.coordinates.longitude,
        },
      },
      {
        'id': bern.id,
        'name': bern.name,
        'coordinates': {
          'latitude': bern.coordinates.latitude,
          'longitude': bern.coordinates.longitude,
        },
      },
    ],
  };

  static Map<String, dynamic> mockJourneyResponse(Journey journey) => {
    'journeys': [
      {
        'id': journey.id,
        'from': {
          'id': journey.from.id,
          'name': journey.from.name,
          'coordinates': {
            'latitude': journey.from.coordinates.latitude,
            'longitude': journey.from.coordinates.longitude,
          },
        },
        'to': {
          'id': journey.to.id,
          'name': journey.to.name,
          'coordinates': {
            'latitude': journey.to.coordinates.latitude,
            'longitude': journey.to.coordinates.longitude,
          },
        },
        'departure': journey.departure.toIso8601String(),
        'arrival': journey.arrival.toIso8601String(),
        'duration': journey.duration,
        'transfers': journey.transfers,
        'scenicScore': journey.scenicScore,
        'legs': journey.legs
            .map(
              (leg) => {
                'from': {
                  'id': leg.from.id,
                  'name': leg.from.name,
                  'coordinates': {
                    'latitude': leg.from.coordinates.latitude,
                    'longitude': leg.from.coordinates.longitude,
                  },
                },
                'to': {
                  'id': leg.to.id,
                  'name': leg.to.name,
                  'coordinates': {
                    'latitude': leg.to.coordinates.latitude,
                    'longitude': leg.to.coordinates.longitude,
                  },
                },
                'departure': leg.departure.toIso8601String(),
                'arrival': leg.arrival.toIso8601String(),
                'platform': leg.platform,
                'transport': {
                  'type': leg.transport.type.name.toUpperCase(),
                  'number': leg.transport.number,
                  'operator': leg.transport.operator,
                  'line': leg.transport.line,
                },
                'delay': leg.delay,
              },
            )
            .toList(),
      },
    ],
  };
}
