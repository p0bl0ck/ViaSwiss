# ViaSwiss Flutter App

[![CI](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/ci.yml/badge.svg)](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/ci.yml)
[![Security Scan](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/security.yml/badge.svg)](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/security.yml)
[![Deploy Beta](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/deploy-beta.yml/badge.svg)](https://github.com/p0bl0ck/ViaSwiss/actions/workflows/deploy-beta.yml)

A modern Flutter mobile application that connects to the ViaSwiss GraphQL backend to help users plan scenic Swiss train journeys with real-time weather information.

## Features

- 🔍 **Station Search**: Search and select departure/arrival stations with autocomplete
- 🚆 **Journey Planning**: Find multiple journey options with connections and transfers
- ⏰ **Real-time Information**: View departure/arrival times, platforms, and delays
- 🌤️ **Weather Integration**: Get weather forecasts for your journey
- 🗺️ **Route Visualization**: View journey routes on an interactive map
- 🎨 **Material Design 3**: Modern UI with Swiss railway branding colors
- 📱 **Responsive**: Works on both iOS and Android devices

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

- **State Management**: Riverpod 2.4
- **Navigation**: GoRouter 13.0
- **GraphQL Client**: graphql_flutter 5.1
- **Code Generation**: Freezed, JSON Serializable
- **Maps**: MapLibre GL 0.18

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

### Map Integration

To enable map functionality:

1. Sign up for a free MapTiler account at https://www.maptiler.com/
2. Get your API key
3. Update `lib/core/config/app_config.dart`:

```dart
static const String mapStyleUrl =
  'https://api.maptiler.com/maps/basic-v2/style.json?key=YOUR_API_KEY';
```

## Project Structure

### Core Modules

- **config/**: App configuration (theme, API endpoints)
- **router/**: Navigation configuration with GoRouter
- **utils/**: Utility functions (date formatting, constants)

### Features

#### Home
- Main screen with station search fields
- Popular routes section
- Departure time picker

#### Search
- Station search with autocomplete
- Real-time search results from GraphQL API

#### Journey
- Journey results list with multiple options
- Detailed journey view with leg-by-leg information
- Weather information integration
- Scenic score display

#### Map
- Route visualization on interactive map
- Station markers
- Journey path display

#### Weather
- Weather data models
- Weather repository for API calls
- Weather badge widgets

## State Management

The app uses Riverpod for state management with providers organized by feature:

- **Home Providers**: Selected stations, departure time
- **Search Providers**: Search query, search results
- **Journey Providers**: Journey search params, journey results
- **Weather Providers**: Weather data by coordinates
- **Map Providers**: Map state (zoom, center)

## GraphQL Integration

All GraphQL queries are defined in `data/graphql/` folders within each feature:

- **Station Queries**: Search stations, get station by ID
- **Journey Queries**: Get journeys, route recommendations
- **Weather Queries**: Get weather by coordinates

## Screens

### 1. Home Screen
Entry point with station selection and search button.

### 2. Station Search Screen
Autocomplete search for departure/arrival stations.

### 3. Journey Results Screen
List of available journeys with:
- Departure/arrival times
- Duration and transfers
- Scenic score (if available)

### 4. Journey Detail Screen
Detailed view of a selected journey:
- Complete leg-by-leg timeline
- Train/transport information
- Platform numbers and delays
- Weather information

### 5. Map Screen
Visual representation of the journey route on a map.

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
   - Ensure backend is running

3. **Code generation fails**
   - Run `flutter clean` and `flutter pub get`
   - Delete all `*.g.dart` and `*.freezed.dart` files
   - Run build_runner again

4. **Map not showing**
   - Add your MapTiler API key to app_config.dart
   - MapLibre GL requires additional native setup

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
