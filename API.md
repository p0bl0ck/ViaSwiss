# ViaSwiss API Documentation

Complete technical reference for all API endpoints used by the ViaSwiss Flutter application.

> **Note**: This documentation covers all available endpoints. See [Currently Enabled Features](#currently-enabled-features) for active functionality.

## Table of Contents

- [Currently Enabled Features](#currently-enabled-features)
- [Overview](#overview)
- [GraphQL Endpoint](#graphql-endpoint)
- [Station API](#station-api)
- [Journey API](#journey-api)
- [Weather API](#weather-api)
- [Data Models](#data-models)
- [External APIs](#external-apis)
- [Error Handling](#error-handling)

## Currently Enabled Features

**Active Features** (as of `lib/core/config/feature_flags.dart`):

- ✅ **Station Search** - `searchStations`, `getStation` queries
- ✅ **Journey Planning** - `getJourneys`, `getRouteRecommendations` queries
- ✅ **Weather Integration** (`weatherInfo = true`) - `getWeather` query
- ❌ **Map Visualization** (`mapView = false`) - MapTiler API disabled
- ❌ **Popular Routes** (`popularRoutes = false`) - Hardcoded data disabled

## Overview

ViaSwiss uses a **GraphQL-only architecture** for all backend communication. The app makes read-only queries (no mutations) to fetch:
- Swiss train station data
- Journey planning and route information
- Real-time weather forecasts (✅ **Enabled**)

### API Type
- **Protocol**: GraphQL over HTTP/HTTPS
- **Operations**: Queries only (no mutations)
- **Client**: graphql_flutter 5.1.2
- **Cache**: In-memory with configurable policies

### Base Configuration

**File**: `lib/core/config/app_config.dart`

```dart
static const String graphqlEndpoint = String.fromEnvironment(
  'GRAPHQL_ENDPOINT',
  defaultValue: 'http://10.0.2.2:4000/graphql',
);
```

**Runtime Override**:
```bash
flutter run --dart-define=GRAPHQL_ENDPOINT=https://your-backend.com/graphql
```

**GraphQL Client Setup**: `lib/shared/graphql/graphql_client.dart`
- Custom logging link for request/response tracking
- Default cache policy: `cacheFirst` for queries
- In-memory cache via `GraphQLCache`

---

## GraphQL Endpoint

### Configuration

| Environment | Endpoint URL |
|-------------|--------------|
| Android Emulator | `http://10.0.2.2:4000/graphql` |
| iOS Simulator | `http://localhost:4000/graphql` |
| Production | Configure via `--dart-define` or `app_config.dart` |

### Connection Details

- **Method**: POST
- **Content-Type**: application/json
- **Headers**: None required (can be extended in client setup)
- **Authentication**: Not implemented (public API)

---

## Station API

### searchStations

Search for train stations with autocomplete functionality.

**File**: `lib/features/search/data/graphql/station_queries.dart`
**Repository**: `lib/features/search/data/repositories/station_repository.dart`

#### Query

```graphql
query SearchStations($query: String!, $limit: Int) {
  searchStations(query: $query, limit: $limit) {
    id
    name
    coordinates {
      latitude
      longitude
    }
  }
}
```

#### Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `query` | String | Yes | - | Search term for station name |
| `limit` | Int | No | 10 | Maximum number of results to return |

#### Response

**Type**: `[Station!]!`

```json
[
  {
    "id": "8507000",
    "name": "Bern",
    "coordinates": {
      "latitude": 46.949070,
      "longitude": 7.439011
    }
  }
]
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | ID! | Unique station identifier |
| `name` | String! | Display name of the station |
| `coordinates` | Coordinates! | Geographic coordinates |
| `coordinates.latitude` | Float! | Latitude in decimal degrees |
| `coordinates.longitude` | Float! | Longitude in decimal degrees |

#### Data Model

**File**: `lib/features/search/domain/models/station.dart`

```dart
@freezed
sealed class Station with _$Station {
  const factory Station({
    required String id,
    required String name,
    required Coordinates coordinates,
  }) = _Station;

  factory Station.fromJson(Map<String, dynamic> json) => _$StationFromJson(json);
}

@freezed
sealed class Coordinates with _$Coordinates {
  const factory Coordinates({
    required double latitude,
    required double longitude,
  }) = _Coordinates;

  factory Coordinates.fromJson(Map<String, dynamic> json) => _$CoordinatesFromJson(json);
}
```

#### Cache Policy

- **Fetch Policy**: `networkOnly` (always fetch fresh results)
- **Reason**: Search results should reflect latest data

#### Usage Example

```dart
// Via Riverpod provider
final results = ref.watch(stationSearchResultsProvider);
```

---

### getStation

Fetch detailed information for a single station by ID.

#### Query

```graphql
query GetStation($id: ID!) {
  station(id: $id) {
    id
    name
    coordinates {
      latitude
      longitude
    }
  }
}
```

#### Variables

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | ID | Yes | Unique station identifier |

#### Response

**Type**: `Station`

Same structure as `searchStations` response (single object).

#### Cache Policy

- **Fetch Policy**: `cacheFirst` (use cache when available)
- **Reason**: Station data is relatively static

---

## Journey API

### getJourneys

Search for train journey options between two stations.

**File**: `lib/features/journey/data/graphql/journey_queries.dart`
**Repository**: `lib/features/journey/data/repositories/journey_repository.dart`

#### Query

```graphql
query GetJourneys($from: ID!, $to: ID!, $departureTime: String, $limit: Int) {
  journeys(from: $from, to: $to, departureTime: $departureTime, limit: $limit) {
    id
    from {
      id
      name
      coordinates { latitude longitude }
    }
    to {
      id
      name
      coordinates { latitude longitude }
    }
    departure
    arrival
    duration
    transfers
    scenicScore
    legs {
      from {
        id
        name
        coordinates { latitude longitude }
      }
      to {
        id
        name
        coordinates { latitude longitude }
      }
      departure
      arrival
      platform
      delay
      transport {
        type
        number
        operator
        line
      }
    }
  }
}
```

#### Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `from` | ID | Yes | - | Departure station ID |
| `to` | ID | Yes | - | Arrival station ID |
| `departureTime` | String | No | Now | ISO8601 departure time |
| `limit` | Int | No | 5 | Maximum number of journeys |

**Time Format**: ISO8601 (e.g., `2024-01-15T14:30:00Z`)

#### Response

**Type**: `[Journey!]!`

```json
[
  {
    "id": "journey_001",
    "from": {
      "id": "8507000",
      "name": "Bern",
      "coordinates": { "latitude": 46.949070, "longitude": 7.439011 }
    },
    "to": {
      "id": "8503000",
      "name": "Zürich HB",
      "coordinates": { "latitude": 47.378177, "longitude": 8.540192 }
    },
    "departure": "2024-01-15T14:32:00Z",
    "arrival": "2024-01-15T15:28:00Z",
    "duration": 56,
    "transfers": 0,
    "scenicScore": 75.5,
    "legs": [
      {
        "from": { "id": "8507000", "name": "Bern", "coordinates": {...} },
        "to": { "id": "8503000", "name": "Zürich HB", "coordinates": {...} },
        "departure": "2024-01-15T14:32:00Z",
        "arrival": "2024-01-15T15:28:00Z",
        "platform": "3",
        "delay": null,
        "transport": {
          "type": "IC",
          "number": "1",
          "operator": "SBB",
          "line": "IC1"
        }
      }
    ]
  }
]
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | ID! | Unique journey identifier |
| `from` | Station! | Departure station |
| `to` | Station! | Arrival station |
| `departure` | DateTime! | Departure time (ISO8601) |
| `arrival` | DateTime! | Arrival time (ISO8601) |
| `duration` | Int! | Journey duration in minutes |
| `transfers` | Int! | Number of transfers required |
| `scenicScore` | Float | Scenic rating (0-100), optional |
| `legs` | [Leg!]! | Journey segments/connections |

**Leg Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `from` | Station! | Departure station for this leg |
| `to` | Station! | Arrival station for this leg |
| `departure` | DateTime! | Departure time |
| `arrival` | DateTime! | Arrival time |
| `platform` | String | Platform number (optional) |
| `delay` | Int | Delay in minutes (null if on time) |
| `transport` | Transport! | Transport information |

**Transport Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `type` | TransportType! | Transport category (see below) |
| `number` | String! | Train/bus number |
| `operator` | String! | Operating company (e.g., "SBB") |
| `line` | String | Line designation (optional) |

#### Transport Types

| Type | Full Name | Description |
|------|-----------|-------------|
| `IC` | Intercity | Long-distance express trains |
| `IR` | Interregio | Regional express trains |
| `RE` | Regional Express | Regional trains |
| `S` | S-Bahn | Urban/suburban trains |
| `ICE` | InterCityExpress | High-speed trains |
| `EC` | EuroCity | International express trains |
| `BUS` | Bus | Bus connections |
| `TRAM` | Tram | Tram/streetcar |

#### Data Models

**File**: `lib/features/journey/domain/models/journey.dart`

```dart
@freezed
sealed class Journey with _$Journey {
  const factory Journey({
    required String id,
    required Station from,
    required Station to,
    required DateTime departure,
    required DateTime arrival,
    required int duration,
    required int transfers,
    required List<Leg> legs,
    double? scenicScore,
  }) = _Journey;

  factory Journey.fromJson(Map<String, dynamic> json) => _$JourneyFromJson(json);
}
```

**File**: `lib/features/journey/domain/models/leg.dart`

```dart
@freezed
sealed class Leg with _$Leg {
  const factory Leg({
    required Station from,
    required Station to,
    required DateTime departure,
    required DateTime arrival,
    String? platform,
    required Transport transport,
    int? delay,
  }) = _Leg;

  factory Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);
}
```

**File**: `lib/features/journey/domain/models/transport.dart`

```dart
enum TransportType {
  @JsonValue('IC') ic,
  @JsonValue('IR') ir,
  @JsonValue('RE') re,
  @JsonValue('S') s,
  @JsonValue('ICE') ice,
  @JsonValue('EC') ec,
  @JsonValue('BUS') bus,
  @JsonValue('TRAM') tram,
}

@freezed
sealed class Transport with _$Transport {
  const factory Transport({
    required TransportType type,
    required String number,
    required String operator,
    String? line,
  }) = _Transport;

  factory Transport.fromJson(Map<String, dynamic> json) => _$TransportFromJson(json);
}
```

#### Cache Policy

- **Fetch Policy**: `networkOnly` (always fetch fresh data)
- **Reason**: Journey schedules and delays change frequently

---

### getRouteRecommendations

Get journey options with integrated weather forecasts and AI-generated travel recommendations.

#### Query

```graphql
query GetRouteRecommendations($from: ID!, $to: ID!, $departureTime: String) {
  routeRecommendations(from: $from, to: $to, departureTime: $departureTime) {
    journey {
      # Full Journey fields (same as getJourneys)
      id
      from { id name coordinates { latitude longitude } }
      to { id name coordinates { latitude longitude } }
      departure
      arrival
      duration
      transfers
      scenicScore
      legs { ... }
    }
    weather {
      location { latitude longitude }
      temperature
      condition
      precipitationProbability
      windSpeed
      timestamp
      forecast {
        timestamp
        temperature
        condition
        precipitationProbability
      }
    }
    warnings
    recommendation
  }
}
```

#### Variables

Same as `getJourneys` (without `limit`).

#### Response

**Type**: `RouteRecommendation`

```json
{
  "journey": {
    "id": "journey_001",
    "from": {...},
    "to": {...},
    "departure": "2024-01-15T14:32:00Z",
    "arrival": "2024-01-15T15:28:00Z",
    "duration": 56,
    "transfers": 0,
    "scenicScore": 75.5,
    "legs": [...]
  },
  "weather": {
    "location": { "latitude": 47.378177, "longitude": 8.540192 },
    "temperature": 12.5,
    "condition": "PARTLY_CLOUDY",
    "precipitationProbability": 20,
    "windSpeed": 15.2,
    "timestamp": "2024-01-15T14:00:00Z",
    "forecast": [
      {
        "timestamp": "2024-01-15T15:00:00Z",
        "temperature": 13.0,
        "condition": "CLOUDY",
        "precipitationProbability": 30
      }
    ]
  },
  "warnings": [
    "Expected heavy snowfall in alpine regions"
  ],
  "recommendation": "Consider bringing an umbrella as precipitation probability increases throughout the journey."
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `journey` | Journey! | Complete journey information |
| `weather` | Weather! | Weather forecast for route |
| `warnings` | [String!]! | Travel warnings/advisories |
| `recommendation` | String! | AI-generated travel advice |

#### Data Model

**File**: `lib/features/journey/domain/models/route_recommendation.dart`

```dart
@freezed
sealed class RouteRecommendation with _$RouteRecommendation {
  const factory RouteRecommendation({
    required Journey journey,
    required Weather weather,
    required List<String> warnings,
    required String recommendation,
  }) = _RouteRecommendation;

  factory RouteRecommendation.fromJson(Map<String, dynamic> json) =>
      _$RouteRecommendationFromJson(json);
}
```

---

## Weather API

### getWeather

Get current weather conditions and forecast for specific geographic coordinates.

**File**: `lib/features/weather/data/graphql/weather_queries.dart`
**Repository**: `lib/features/weather/data/repositories/weather_repository.dart`

#### Query

```graphql
query GetWeather($latitude: Float!, $longitude: Float!) {
  weather(latitude: $latitude, longitude: $longitude) {
    location {
      latitude
      longitude
    }
    temperature
    condition
    precipitationProbability
    windSpeed
    timestamp
    forecast {
      timestamp
      temperature
      condition
      precipitationProbability
    }
  }
}
```

#### Variables

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `latitude` | Float | Yes | Latitude in decimal degrees |
| `longitude` | Float | Yes | Longitude in decimal degrees |

#### Response

**Type**: `Weather!`

```json
{
  "location": {
    "latitude": 47.378177,
    "longitude": 8.540192
  },
  "temperature": 12.5,
  "condition": "PARTLY_CLOUDY",
  "precipitationProbability": 20,
  "windSpeed": 15.2,
  "timestamp": "2024-01-15T14:00:00Z",
  "forecast": [
    {
      "timestamp": "2024-01-15T15:00:00Z",
      "temperature": 13.0,
      "condition": "CLOUDY",
      "precipitationProbability": 30
    },
    {
      "timestamp": "2024-01-15T16:00:00Z",
      "temperature": 12.8,
      "condition": "RAINY",
      "precipitationProbability": 65
    }
  ]
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `location` | Coordinates! | Geographic location |
| `temperature` | Float! | Temperature in Celsius |
| `condition` | WeatherCondition! | Current weather condition |
| `precipitationProbability` | Int! | Precipitation chance (0-100%) |
| `windSpeed` | Float | Wind speed in km/h (optional) |
| `timestamp` | DateTime! | Observation/forecast time |
| `forecast` | [WeatherForecast!]! | Future weather entries |

#### Weather Conditions

| Enum Value | Display | Description |
|------------|---------|-------------|
| `CLEAR` | Clear | Clear skies |
| `PARTLY_CLOUDY` | Partly Cloudy | Partial cloud cover |
| `CLOUDY` | Cloudy | Overcast conditions |
| `RAINY` | Rainy | Rain expected |
| `SNOWY` | Snowy | Snow expected |
| `STORMY` | Stormy | Thunderstorms possible |
| `FOGGY` | Foggy | Reduced visibility |

#### Data Models

**File**: `lib/features/weather/domain/models/weather.dart`

```dart
enum WeatherCondition {
  @JsonValue('CLEAR') clear,
  @JsonValue('PARTLY_CLOUDY') partlyCloudy,
  @JsonValue('CLOUDY') cloudy,
  @JsonValue('RAINY') rainy,
  @JsonValue('SNOWY') snowy,
  @JsonValue('STORMY') stormy,
  @JsonValue('FOGGY') foggy,
}

@freezed
sealed class Weather with _$Weather {
  const factory Weather({
    required Coordinates location,
    required double temperature,
    required WeatherCondition condition,
    required int precipitationProbability,
    double? windSpeed,
    required DateTime timestamp,
    required List<WeatherForecast> forecast,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);
}

@freezed
sealed class WeatherForecast with _$WeatherForecast {
  const factory WeatherForecast({
    required DateTime timestamp,
    required double temperature,
    required WeatherCondition condition,
    required int precipitationProbability,
  }) = _WeatherForecast;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
}
```

#### Cache Policy

- **Fetch Policy**: `networkOnly` (always fetch fresh data)
- **Reason**: Weather data changes frequently

---

## Data Models

### Model Generation

All data models use **Freezed** and **JSON Serializable** for:
- Immutable data classes
- Automatic JSON serialization/deserialization
- Union types and pattern matching
- Copy-with functionality

### Code Generation

After modifying models, regenerate with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Model Files

| Model | File Path |
|-------|-----------|
| Station | `lib/features/search/domain/models/station.dart` |
| Coordinates | `lib/features/search/domain/models/station.dart` |
| Journey | `lib/features/journey/domain/models/journey.dart` |
| Leg | `lib/features/journey/domain/models/leg.dart` |
| Transport | `lib/features/journey/domain/models/transport.dart` |
| Weather | `lib/features/weather/domain/models/weather.dart` |
| WeatherForecast | `lib/features/weather/domain/models/weather.dart` |
| RouteRecommendation | `lib/features/journey/domain/models/route_recommendation.dart` |

---

## External APIs

### ❌ MapTiler API (DISABLED)

**Status**: ❌ **Feature Disabled** (`mapView = false` in `feature_flags.dart`)

The MapTiler API for map visualization is configured but **not currently active**. To enable:

1. Set `mapView = true` in `lib/core/config/feature_flags.dart`
2. Get free API key from https://www.maptiler.com/
3. Update `mapStyleUrl` in `lib/core/config/app_config.dart`

**Configuration** (when enabled):

```dart
static const String mapStyleUrl =
    'https://api.maptiler.com/maps/basic-v2/style.json?key=YOUR_MAPTILER_KEY';
```

---

### Active External Services

**None** - The app currently uses **GraphQL exclusively** for all data operations. No external REST APIs are active.

---

## Error Handling

### GraphQL Errors

The app handles GraphQL errors through the `graphql_flutter` client:

```dart
// In repositories
if (result.hasException) {
  throw result.exception!;
}
```

### Error Types

| Error Type | Cause | Handling |
|------------|-------|----------|
| `NetworkException` | No internet connection | Display offline message |
| `ServerException` | GraphQL server error | Show error message to user |
| `ParsingException` | Invalid response format | Log error, fallback UI |

### Error Messages

Error handling is implemented in:
- **Repositories**: Data layer error catching
- **Providers**: State management error states
- **UI**: Error widgets and snackbars

---

## State Management

### Riverpod Providers

All API calls are managed through Riverpod providers:

**File**: `lib/features/search/providers/station_providers.dart`
```dart
@riverpod
Future<List<Station>> stationSearchResults(StationSearchResultsRef ref) async {
  final query = ref.watch(stationSearchQueryProvider);
  if (query.isEmpty) return [];

  final repository = ref.watch(stationRepositoryProvider);
  return repository.searchStations(query);
}
```

**File**: `lib/features/journey/providers/journey_providers.dart`
```dart
@riverpod
Future<List<Journey>> journeys(JourneysRef ref, JourneySearchParams params) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getJourneys(
    from: params.from,
    to: params.to,
    departureTime: params.departureTime,
  );
}
```

### Provider Types

| Provider | Type | Purpose |
|----------|------|---------|
| `stationSearchQueryProvider` | StateProvider | Current search query |
| `stationSearchResultsProvider` | FutureProvider | Search results |
| `journeysProvider` | FutureProvider | Journey search results |
| `routeRecommendationsProvider` | FutureProvider | Journey with weather |
| `weatherProvider` | FutureProvider | Weather by coordinates |

---

## Feature Flags

**File**: `lib/core/config/feature_flags.dart`

Current API-affecting flags:

```dart
class FeatureFlags {
  static const bool weatherInfo = true;     // ✅ Weather API integration (ENABLED)
  static const bool mapView = false;        // ❌ MapTiler integration (DISABLED)
  static const bool popularRoutes = false;  // ❌ Popular routes (DISABLED - hardcoded data)
}
```

**Impact on API Usage**:
- **weatherInfo = true**: Enables `getWeather` and `getRouteRecommendations` queries
- **mapView = false**: Disables MapTiler API calls (no map rendering)
- **popularRoutes = false**: No API impact (uses hardcoded data when enabled)

---

## API Summary

| Endpoint | Method | Purpose | Cache Policy | Status |
|----------|--------|---------|--------------|--------|
| `searchStations` | Query | Station autocomplete | networkOnly | ✅ Active |
| `getStation` | Query | Single station details | cacheFirst | ✅ Active |
| `getJourneys` | Query | Journey search | networkOnly | ✅ Active |
| `getRouteRecommendations` | Query | Journey + weather | networkOnly | ✅ Active |
| `getWeather` | Query | Weather forecast | networkOnly | ✅ Active |

**Active APIs**:
- **GraphQL Queries**: 5 (all active)
- **GraphQL Mutations**: 0
- **External REST APIs**: 0 (MapTiler disabled)

---

## Technical Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| GraphQL Client | graphql_flutter | 5.1.2 |
| State Management | Riverpod | 3.1.0 |
| Code Generation | Freezed | 2.5.7 |
| JSON Serialization | json_serializable | 6.8.0 |
| Build Runner | build_runner | 2.4.13 |

---

## Additional Resources

- **GraphQL Client Setup**: `lib/shared/graphql/graphql_client.dart`
- **Repository Implementations**: `lib/features/*/data/repositories/`
- **Query Definitions**: `lib/features/*/data/graphql/`
- **Data Models**: `lib/features/*/domain/models/`
- **State Providers**: `lib/features/*/providers/`

For implementation details, see the respective source files in the codebase.
