# ViaSwiss Flutter App

[![CI](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/ci.yml/badge.svg)](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/ci.yml)
[![Security Scan](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/security.yml/badge.svg)](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/security.yml)
[![Deploy Beta](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/deploy-beta.yml/badge.svg)](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/deploy-beta.yml)

A modern Flutter mobile application that connects to the ViaSwiss GraphQL backend to help users plan scenic Swiss train journeys with real-time weather information.

## Features

### Currently Enabled
- 🔍 **Station Search**: Search and select departure/arrival stations with autocomplete
- 🚆 **Journey Planning**: Find multiple journey options with connections and transfers
- ⏰ **Real-time Information**: View departure/arrival times, platforms, and delays
- 🌤️ **Weather Integration**: Get weather forecasts for your journey route
- 🎨 **Material Design 3**: Modern UI with Swiss railway branding colors
- 📱 **Responsive**: Works on both iOS and Android devices

### Disabled Features
- 🗺️ **Route Visualization**: Map view currently disabled (feature flag: `mapView = false`)
- 📍 **Popular Routes**: Currently disabled (feature flag: `popularRoutes = false`)

## Architecture

This app follows Clean Architecture principles with a feature-based structure:

```
lib/
├── core/              # App-wide configuration and utilities
├── features/          # Feature modules (Home, Search, Journey, Map, Weather)
│   └── [feature]/
│       ├── domain/    # Models and entities
│       ├── data/      # Repositories and data sources
│       ├── presentation/  # UI screens and widgets
│       └── providers/ # Riverpod state management
└── shared/            # Shared widgets and utilities
```

### Key Technologies

- **State Management**: Riverpod 3.1
- **Navigation**: GoRouter with typed routes
- **GraphQL Client**: graphql_flutter 5.1 (read-only queries)
- **Code Generation**: Freezed, JSON Serializable
- **Weather**: Integrated via GraphQL backend

## Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart 3.2.0 or higher
- ViaSwiss GraphQL backend running (locally or deployed)

## Setup

### 1. Install Dependencies

```bash
cd viaswiss_app
flutter pub get
```

### 2. Configure Backend URL

Edit `lib/core/config/app_config.dart` to point to your GraphQL backend:

```dart
static const String graphqlEndpoint = String.fromEnvironment(
  'GRAPHQL_ENDPOINT',
  defaultValue: 'http://localhost:4000/graphql', // Local development
  // defaultValue: 'https://your-app.railway.app/graphql', // Production
);
```

Or set it at runtime:

```bash
flutter run --dart-define=GRAPHQL_ENDPOINT=https://your-backend-url/graphql
```

### 3. Generate Code

Run code generation for Freezed models and JSON serialization:

```bash
flutter pub run build_runner build --delete-conflicting-outputs

# Or use watch mode for auto-regeneration
flutter pub run build_runner watch
```

### 4. Run the App

```bash
# Run on connected device or emulator
flutter run

# Run with specific backend URL
flutter run --dart-define=GRAPHQL_ENDPOINT=http://10.0.2.2:4000/graphql
```

**Note**: For Android emulator, use `10.0.2.2` instead of `localhost` to access your host machine.

## Configuration

### Feature Flags

Control app features via `lib/core/config/feature_flags.dart`:

```dart
class FeatureFlags {
  static bool weatherInfo = true;      // ✅ Enabled - Weather forecasts
  static bool mapView = false;         // ❌ Disabled - Map visualization
  static bool popularRoutes = false;   // ❌ Disabled - Popular routes section
}
```

## Project Structure

### Core Modules

- **config/**: App configuration (theme, API endpoints)
- **router/**: Navigation configuration with GoRouter
- **utils/**: Utility functions (date formatting, constants)

### Features

#### Home
- Main screen with station search fields
- Departure time picker

#### Search
- Station search with autocomplete
- Real-time search results from GraphQL API

#### Journey
- Journey results list with multiple options
- Detailed journey view with leg-by-leg information
- Weather information integration (✅ Enabled)
- Scenic score display
- Real-time platform and delay information

#### Weather
- Weather data models
- Weather repository for API calls
- Weather forecast integration with journeys
- Weather badge widgets

## State Management

The app uses Riverpod for state management with providers organized by feature:

- **Home Providers**: Selected stations, departure time
- **Search Providers**: Search query, search results
- **Journey Providers**: Journey search params, journey results, route recommendations
- **Weather Providers**: Weather data by coordinates

## GraphQL Integration

All GraphQL queries are defined in `data/graphql/` folders within each feature:

- **Station Queries**: Search stations, get station by ID
- **Journey Queries**: Get journeys, route recommendations
- **Weather Queries**: Get weather by coordinates

### API Endpoint Details

#### GraphQL Endpoint

**Default**: `http://10.0.2.2:4000/graphql` (Android emulator)
**Configuration**: `lib/core/config/app_config.dart`

The app uses a **read-only GraphQL API** (queries only, no mutations).

#### Station API

**Query: `searchStations`** (`lib/features/search/data/graphql/station_queries.dart`)
- **Purpose**: Autocomplete search for train stations
- **Variables**:
  - `query` (String, required) - Search term
  - `limit` (Int, optional) - Results limit (default: 10)
- **Returns**: Array of stations with `id`, `name`, `coordinates` (lat/lng)

**Query: `getStation`**
- **Purpose**: Fetch single station by ID
- **Variables**: `id` (ID, required)
- **Returns**: Single station object

#### Journey API

**Query: `getJourneys`** (`lib/features/journey/data/graphql/journey_queries.dart`)
- **Purpose**: Search train journeys between stations
- **Variables**:
  - `from` (ID, required) - Departure station ID
  - `to` (ID, required) - Arrival station ID
  - `departureTime` (String, optional) - ISO8601 timestamp
  - `limit` (Int, optional) - Max journeys (default: 5)
- **Returns**: Journey array with:
  - Basic info: `id`, `from`, `to`, `departure`, `arrival`
  - Metrics: `duration` (minutes), `transfers`, `scenicScore` (0-100)
  - Details: `legs` array with segments, platforms, delays, transport info

**Transport Types**: IC (Intercity), IR (Interregio), RE (Regional Express), S (S-Bahn), ICE (InterCityExpress), EC (EuroCity), BUS, TRAM

**Query: `getRouteRecommendations`**
- **Purpose**: Get journeys with weather forecasts and AI recommendations
- **Variables**: Same as `getJourneys`
- **Returns**: `RouteRecommendation` with:
  - `journey` - Full journey object
  - `weather` - Weather forecast for route
  - `warnings` - Array of travel warnings
  - `recommendation` - AI-generated travel advice

#### Weather API

**Query: `getWeather`** (`lib/features/weather/data/graphql/weather_queries.dart`)
- **Purpose**: Get weather data for coordinates
- **Variables**: `latitude`, `longitude` (Float, required)
- **Returns**: Weather data with:
  - Current: `temperature` (°C), `condition`, `precipitationProbability` (%), `windSpeed` (km/h)
  - Conditions: CLEAR, PARTLY_CLOUDY, CLOUDY, RAINY, SNOWY, STORMY, FOGGY
  - Forecast: Array of future weather entries

#### Data Models

All models use Freezed with JSON serialization:
- `Station` - Station info with coordinates
- `Journey` - Complete journey with legs and transfers
- `Leg` - Journey segment with transport details
- `Transport` - Train/bus info (type, number, operator)
- `Weather` - Current weather and forecast
- `RouteRecommendation` - Journey + weather + recommendations

See `lib/features/*/domain/models/` for model definitions.

#### Cache Policies

- **Search queries**: `networkOnly` (always fresh)
- **Single entities**: `cacheFirst` (cached when available)
- **Cache storage**: In-memory via graphql_flutter
- **No offline mode**: Requires active network connection

### GraphQL Backend Only

The app uses **GraphQL exclusively** for all backend communication. No external REST APIs are currently active.

**Disabled**: MapTiler API for map visualization (feature flag: `mapView = false`)

## Screens

### 1. Home Screen
Entry point with station selection fields and search button.

### 2. Station Search Screen
Autocomplete search for departure/arrival stations with real-time results.

### 3. Journey Results Screen
List of available journeys with:
- Departure/arrival times
- Duration and transfers
- Scenic score (if available)
- Weather conditions

### 4. Journey Detail Screen
Detailed view of a selected journey:
- Complete leg-by-leg timeline
- Train/transport information (IC, IR, RE, S, etc.)
- Platform numbers and delays
- Integrated weather forecast

## Customization

### Theme

Customize the app theme in `lib/core/config/theme.dart`:

- Primary color (SBB Red)
- Secondary color (SBB Blue)
- Transport type colors
- Weather condition colors

### Constants

Update app constants in `lib/core/utils/constants.dart`:

- Popular routes
- Error messages
- Default limits

## Building for Production

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Testing

The app includes a comprehensive test suite with unit tests, widget tests, and integration tests.

### Test Structure
- **Unit Tests**: Utils, models, repositories, providers
- **Widget Tests**: Shared widgets and feature widgets
- **Integration Tests**: Complete user flows

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test category
flutter test test/unit/
flutter test test/widget/

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Coverage

Current test coverage:
- Utilities: 90%+
- Models: 85%+
- Repositories: 80%+
- Widgets: 75%+

See [test/README.md](test/README.md) for detailed testing documentation.

### Test Dependencies
- **mockito**: Mocking framework for unit tests
- **mocktail**: Alternative mocking library
- **fake_async**: Async testing utilities

## Troubleshooting

### Common Issues

1. **"flutter: command not found"**
   - Ensure Flutter SDK is installed and added to PATH

2. **GraphQL connection errors**
   - Check backend URL in app_config.dart
   - For Android emulator, use `10.0.2.2` instead of `localhost`
   - Ensure backend is running and accessible

3. **Code generation fails**
   - Run `flutter clean` and `flutter pub get`
   - Delete all `*.g.dart` and `*.freezed.dart` files
   - Run build_runner again

4. **Weather not showing**
   - Verify `weatherInfo = true` in `lib/core/config/feature_flags.dart`
   - Check GraphQL backend supports weather queries

## Future Enhancements

- [ ] Offline mode with cached journeys
- [ ] Push notifications for delays
- [ ] Favorite routes
- [ ] Multi-language support
- [ ] Accessibility improvements
- [x] Unit and integration tests
- [x] CI/CD pipeline

## License

This project is part of the ViaSwiss application suite.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For issues and questions, please open an issue in the GitHub repository.
