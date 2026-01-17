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
