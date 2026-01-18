import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging app state
class AppLogger {
  static const String _tag = '[ViaSwiss]';

  /// Log screen state information
  static void screen(String screenName, Map<String, dynamic> state) {
    final stateStr = state.entries
        .map((e) => '  ${e.key}: ${e.value}')
        .join('\n');
    debugPrint('$_tag [$screenName] State:\n$stateStr');
  }

  /// Log provider state changes
  static void provider(String providerName, dynamic state) {
    debugPrint('$_tag [Provider: $providerName] $state');
  }

  /// Log general info
  static void info(String message) {
    debugPrint('$_tag $message');
  }

  /// Log errors
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('$_tag [ERROR] $message');
    if (error != null) {
      debugPrint('$_tag [ERROR] $error');
    }
    if (stackTrace != null) {
      debugPrint('$_tag [ERROR] $stackTrace');
    }
  }

  /// Log navigation events
  static void navigation(String from, String to, [Map<String, dynamic>? params]) {
    final paramsStr = params != null ? ' with params: $params' : '';
    debugPrint('$_tag [Navigation] $from -> $to$paramsStr');
  }
}
