# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ViaSwiss is a Flutter mobile app for planning scenic Swiss train journeys with real-time weather integration. It connects to a GraphQL backend for station search, journey planning, and weather data.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (required after modifying Freezed models)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app (with optional GraphQL endpoint)
flutter run
flutter run --dart-define=GRAPHQL_ENDPOINT=http://10.0.2.2:4000/graphql  # Android emulator

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/utils/date_formatter_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code (strict mode)
flutter analyze --fatal-infos --fatal-warnings

# Format code
dart format lib test

# Production builds
flutter build apk --release
flutter build appbundle --release  # Android Play Store
flutter build ios --release
```

## Architecture

Clean Architecture with feature-based modules. Each feature follows this structure:
- `domain/models/` - Freezed data models with JSON serialization
- `data/repositories/` - GraphQL data sources
- `data/graphql/` - GraphQL query strings
- `presentation/` - Screens and widgets
- `providers/` - Riverpod state providers

```
lib/
├── core/
│   ├── config/app_config.dart    # API endpoints, map keys
│   ├── config/theme.dart         # Material 3 theme (SBB colors)
│   ├── router/app_router.dart    # GoRouter routes
│   └── utils/                    # Date formatter, constants
├── features/
│   ├── home/                     # Station selection entry point
│   ├── search/                   # Station autocomplete search
│   ├── journey/                  # Journey search & detail views
│   ├── map/                      # MapLibre route visualization
│   └── weather/                  # Weather data integration
└── shared/
    ├── widgets/                  # AppCard, AppButton, etc.
    ├── extensions/
    └── graphql/graphql_client.dart
```

## Key Technologies

- **State Management**: Riverpod 3.x with code generation (`@riverpod` annotations)
- **Navigation**: GoRouter with typed routes
- **GraphQL**: graphql_flutter 5.x
- **Maps**: MapLibre GL (requires MapTiler API key in app_config.dart)
- **Code Generation**: Freezed + JSON Serializable (`.freezed.dart`, `.g.dart` files)

## Code Generation

Generated files (`.freezed.dart`, `.g.dart`) are not committed. After modifying Freezed models or providers, regenerate with:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Use watch mode during development:
```bash
flutter pub run build_runner watch
```

## Configuration

- **GraphQL endpoint**: Set via `--dart-define=GRAPHQL_ENDPOINT=...` or edit `lib/core/config/app_config.dart`
- **Map tiles**: Add MapTiler API key to `mapStyleUrl` in `lib/core/config/app_config.dart`
- **Android emulator**: Use `10.0.2.2` instead of `localhost` to access host machine

## Linting

Uses `flutter_lints` with additional rules:
- `prefer_const_constructors`
- `prefer_single_quotes`
- `avoid_print`
- `always_declare_return_types`

## Testing

Test helpers in `test/helpers/`:
- `mock_data.dart` - Mock stations, journeys, weather data
- `test_helpers.dart` - `wrapWithProviders()`, `wrapWithMaterialApp()`

Test structure mirrors `lib/` structure under `test/unit/`, `test/widget/`, and `test/integration/`.

## GraphQL API Endpoints

The app uses a GraphQL backend exclusively for all data operations (read-only, no mutations).

### Endpoint Configuration

**File**: `lib/core/config/app_config.dart`

```dart
static const String graphqlEndpoint = String.fromEnvironment(
  'GRAPHQL_ENDPOINT',
  defaultValue: 'http://10.0.2.2:4000/graphql',  // Android emulator
);
```

**Runtime override**:
```bash
flutter run --dart-define=GRAPHQL_ENDPOINT=https://your-backend.com/graphql
```

### Station Queries

**File**: `lib/features/search/data/graphql/station_queries.dart`

#### searchStations
Search for train stations with autocomplete.

**Variables**:
- `query` (String, required): Search term
- `limit` (Int, optional): Number of results (default: 10)

**Returns**: Array of `Station` with `id`, `name`, `coordinates` (latitude, longitude)

#### getStation
Fetch a single station by ID.

**Variables**:
- `id` (ID, required): Station ID

**Returns**: Single `Station` object

### Journey Queries

**File**: `lib/features/journey/data/graphql/journey_queries.dart`

#### getJourneys
Search for train journeys between two stations.

**Variables**:
- `from` (ID, required): Departure station ID
- `to` (ID, required): Arrival station ID
- `departureTime` (String, optional): ISO8601 departure time
- `limit` (Int, optional): Max journeys (default: 5)

**Returns**: Array of `Journey` with:
- `id`, `from`, `to` (Station objects)
- `departure`, `arrival` (DateTime)
- `duration` (minutes), `transfers` (count)
- `scenicScore` (0-100, optional)
- `legs` (Array of journey segments with `platform`, `delay`, `transport`)

**Transport types**: IC, IR, RE, S, ICE, EC, BUS, TRAM

#### getRouteRecommendations
Get journeys with weather forecasts and travel recommendations.

**Variables**:
- `from` (ID, required): Departure station ID
- `to` (ID, required): Arrival station ID
- `departureTime` (String, optional): ISO8601 departure time

**Returns**: `RouteRecommendation` with:
- `journey` (Journey object)
- `weather` (Weather forecast)
- `warnings` (Array of strings)
- `recommendation` (String, AI-generated advice)

### Weather Queries

**File**: `lib/features/weather/data/graphql/weather_queries.dart`

#### getWeather
Get weather data for specific coordinates.

**Variables**:
- `latitude` (Float, required)
- `longitude` (Float, required)

**Returns**: `Weather` with:
- `location` (Coordinates)
- `temperature` (Celsius)
- `condition` (Enum: CLEAR, PARTLY_CLOUDY, CLOUDY, RAINY, SNOWY, STORMY, FOGGY)
- `precipitationProbability` (0-100%)
- `windSpeed` (km/h, optional)
- `timestamp` (DateTime)
- `forecast` (Array of future weather entries)

### Data Models

All models use Freezed with JSON serialization:
- `Station` - `lib/features/search/domain/models/station.dart`
- `Journey`, `Leg`, `Transport` - `lib/features/journey/domain/models/`
- `Weather`, `WeatherForecast` - `lib/features/weather/domain/models/weather.dart`
- `RouteRecommendation` - `lib/features/journey/domain/models/route_recommendation.dart`

### State Management

Riverpod providers handle GraphQL queries:
- `stationSearchResultsProvider` - Executes searchStations
- `journeysProvider` - Executes getJourneys
- `routeRecommendationsProvider` - Executes getRouteRecommendations
- `weatherProvider` - Executes getWeather

### Cache Policies

- **Queries**: `cacheFirst` for single entities, `networkOnly` for search/lists
- **No mutations**: App is read-only
- **In-memory cache**: Managed by graphql_flutter

## External APIs

### MapTiler API

**Type**: REST API (static style URL)
**Purpose**: Map tiles and styling for MapLibre GL
**Configuration**: `lib/core/config/app_config.dart`

```dart
static const String mapStyleUrl =
    'https://api.maptiler.com/maps/basic-v2/style.json?key=YOUR_KEY';
```

**Setup**:
1. Get free API key from https://www.maptiler.com/
2. Replace `YOUR_KEY` in `mapStyleUrl`

**Status**: Currently disabled via feature flag (`mapView = false`)

## Feature Flags

**File**: `lib/core/config/feature_flags.dart`

- `mapView = false` - Map visualization disabled
- `popularRoutes = false` - Popular routes section disabled
- `weatherInfo = true` - Weather integration enabled

## Key Files Reference

| Purpose | File Path |
|---------|-----------|
| GraphQL Client | `lib/shared/graphql/graphql_client.dart` |
| API Config | `lib/core/config/app_config.dart` |
| Station Queries | `lib/features/search/data/graphql/station_queries.dart` |
| Journey Queries | `lib/features/journey/data/graphql/journey_queries.dart` |
| Weather Queries | `lib/features/weather/data/graphql/weather_queries.dart` |
| Station Repository | `lib/features/search/data/repositories/station_repository.dart` |
| Journey Repository | `lib/features/journey/data/repositories/journey_repository.dart` |
| Weather Repository | `lib/features/weather/data/repositories/weather_repository.dart` |
