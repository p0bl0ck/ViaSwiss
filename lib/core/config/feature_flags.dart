/// Feature flags for controlling app functionality.
///
/// Usage:
/// ```dart
/// if (FeatureFlags.popularRoutes) {
///   // Show popular routes
/// }
/// ```
///
/// To add a new feature flag:
/// 1. Add a static bool field with default value
/// 2. Add corresponding entry to [_flags] map for runtime updates
/// 3. Document the flag purpose
class FeatureFlags {
  FeatureFlags._();

  // ============================================
  // FEATURE FLAGS - Add new flags here
  // ============================================

  /// Show popular routes section on home screen.
  /// Currently hardcoded data - disabled until backend support is added.
  static bool popularRoutes = false;

  /// Show weather information on journey details.
  static bool weatherInfo = true;

  /// Enable map view for journey visualization.
  static bool mapView = false;

  // ============================================
  // RUNTIME CONFIGURATION
  // ============================================

  /// Map of all feature flags for runtime inspection/updates.
  static Map<String, bool> get all => {
    'popularRoutes': popularRoutes,
    'weatherInfo': weatherInfo,
    'mapView': mapView,
  };

  /// Check if a feature is enabled by name.
  static bool isEnabled(String featureName) {
    return all[featureName] ?? false;
  }

  /// Update a feature flag at runtime (useful for remote config).
  static void setFlag(String featureName, bool value) {
    switch (featureName) {
      case 'popularRoutes':
        popularRoutes = value;
        break;
      case 'weatherInfo':
        weatherInfo = value;
        break;
      case 'mapView':
        mapView = value;
        break;
    }
  }

  /// Update multiple flags at once (e.g., from remote config).
  static void updateFlags(Map<String, bool> flags) {
    flags.forEach(setFlag);
  }
}
