import 'dart:developer' as developer;

/// Simple logger utility for debugging app state
class AppLogger {
  static const String _name = 'ViaSwiss';

  /// Log screen state information
  static void screen(String screenName, Map<String, dynamic> state) {
    final stateStr = state.entries
        .map((e) => '  ${e.key}: ${e.value}')
        .join('\n');
    developer.log(
      '[$screenName] State:\n$stateStr',
      name: _name,
    );
  }

  /// Log provider state changes
  static void provider(String providerName, dynamic state) {
    developer.log(
      '[Provider: $providerName] $state',
      name: _name,
    );
  }

  /// Log general info
  static void info(String message) {
    developer.log(
      message,
      name: _name,
    );
  }

  /// Log errors
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log navigation events
  static void navigation(String from, String to, [Map<String, dynamic>? params]) {
    final paramsStr = params != null ? ' with params: $params' : '';
    developer.log(
      '[Navigation] $from -> $to$paramsStr',
      name: _name,
    );
  }
}
