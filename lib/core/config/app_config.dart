import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

enum Environment { development, production }

class AppConfig {
  // Environment configuration
  // Set via: --dart-define=ENVIRONMENT=production
  static const String _environmentString = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static Environment get environment =>
      _environmentString == 'production'
          ? Environment.production
          : Environment.development;

  // Production URL - must be provided via dart-define for production builds
  // Example: --dart-define=GRAPHQL_ENDPOINT=https://api.viaswiss.ch/graphql
  static const String _productionEndpoint = String.fromEnvironment(
    'GRAPHQL_ENDPOINT',
    defaultValue: '',
  );

  // Development endpoints
  static const String _localhostEndpoint = 'http://localhost:4000/graphql';
  static const String _androidEmulatorEndpoint =
      'http://10.0.2.2:4000/graphql';

  // GraphQL API Endpoint - auto-selects based on environment and platform
  static String get graphqlEndpoint {
    // If explicit endpoint is provided, use it
    if (_productionEndpoint.isNotEmpty) {
      return _productionEndpoint;
    }

    // Production requires explicit endpoint
    if (environment == Environment.production) {
      throw StateError(
        'GRAPHQL_ENDPOINT must be provided for production builds. '
        'Use: --dart-define=GRAPHQL_ENDPOINT=https://your-api.com/graphql',
      );
    }

    // Development: auto-detect platform
    return _developmentEndpoint;
  }

  static String get _developmentEndpoint {
    if (kIsWeb) {
      return _localhostEndpoint;
    }
    if (Platform.isAndroid) {
      return _androidEmulatorEndpoint;
    }
    // iOS, macOS, Linux, Windows
    return _localhostEndpoint;
  }

  static bool get isProduction => environment == Environment.production;
  static bool get isDevelopment => environment == Environment.development;

  // Map Configuration
  static const String mapStyleUrl =
      'https://api.maptiler.com/maps/basic-v2/style.json?key=YOUR_MAPTILER_KEY';
}
