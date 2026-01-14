import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper to wrap a widget with providers for testing
Widget wrapWithProviders(
  Widget child, {
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

/// Helper to wrap a widget with MaterialApp for testing
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

/// Helper to pump a widget with providers
Future<void> pumpWithProviders(
  WidgetTester tester,
  Widget child, {
  List<Override>? overrides,
}) async {
  await tester.pumpWidget(
    wrapWithProviders(child, overrides: overrides),
  );
}

/// Helper to find widgets by text
Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        widget.data!.contains(text),
  );
}

/// Matcher for checking if a DateTime is close to another
Matcher isCloseTo(DateTime expected, {Duration tolerance = const Duration(seconds: 1)}) {
  return predicate<DateTime>(
    (actual) {
      final difference = actual.difference(expected).abs();
      return difference <= tolerance;
    },
    'is close to $expected within $tolerance',
  );
}
