class AppConfig {
  // GraphQL API Endpoint
  static const String graphqlEndpoint = String.fromEnvironment(
    'GRAPHQL_ENDPOINT',
    defaultValue: 'http://localhost:4000/graphql', // Local development
    // defaultValue: 'https://your-app.railway.app/graphql', // Production
  );

  // App Info
  static const String appName = 'ViaSwiss';
  static const String appVersion = '1.0.0';

  // Map Configuration
  static const String mapStyleUrl =
      'https://api.maptiler.com/maps/basic-v2/style.json?key=YOUR_MAPTILER_KEY';

  // Defaults
  static const int defaultSearchLimit = 10;
  static const int defaultJourneyLimit = 5;
}
