import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

  /// Log API request
  static void apiRequest({
    required String operationType,
    required String operationName,
    required Map<String, dynamic> variables,
  }) {
    debugPrint('$_tag [API Request] $operationType: $operationName');
    if (variables.isNotEmpty) {
      debugPrint('$_tag [API Request] Variables: ${_formatJson(variables)}');
    }
  }

  /// Log API response
  static void apiResponse({
    required String operationName,
    required Map<String, dynamic>? data,
    required List<GraphQLError>? errors,
    required Duration duration,
  }) {
    final durationMs = duration.inMilliseconds;

    if (errors != null && errors.isNotEmpty) {
      debugPrint('$_tag [API Response] $operationName FAILED (${durationMs}ms)');
      for (final error in errors) {
        debugPrint('$_tag [API Response] Error: ${error.message}');
      }
    } else {
      debugPrint('$_tag [API Response] $operationName OK (${durationMs}ms)');
      if (data != null) {
        final preview = _getDataPreview(data);
        debugPrint('$_tag [API Response] Data: $preview');
      }
    }
  }

  /// Log API error (network/transport level)
  static void apiError({
    required String operationName,
    required Object error,
    required Duration duration,
  }) {
    final durationMs = duration.inMilliseconds;
    debugPrint('$_tag [API Error] $operationName FAILED (${durationMs}ms)');
    debugPrint('$_tag [API Error] $error');
  }

  /// Format JSON for logging
  static String _formatJson(Map<String, dynamic> json) {
    try {
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (_) {
      return json.toString();
    }
  }

  /// Get a preview of the response data (truncated for readability)
  static String _getDataPreview(Map<String, dynamic> data) {
    final keys = data.keys.toList();
    final previews = <String>[];

    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        previews.add('$key: [${value.length} items]');
      } else if (value is Map) {
        previews.add('$key: {${value.keys.length} fields}');
      } else {
        final str = value.toString();
        if (str.length > 50) {
          previews.add('$key: ${str.substring(0, 50)}...');
        } else {
          previews.add('$key: $str');
        }
      }
    }

    return '{${previews.join(', ')}}';
  }
}
