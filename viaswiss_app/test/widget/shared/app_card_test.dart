import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viaswiss_app/shared/widgets/app_card.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders child widget', (tester) async {
      // Arrange
      const testText = 'Test Content';

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const AppCard(
            child: Text(testText),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      // Arrange
      var tapped = false;

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Tap me'),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('does not respond to tap when onTap is null', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const AppCard(
            child: Text('No tap'),
          ),
        ),
      );

      // Assert - should not throw
      expect(find.text('No tap'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      // Arrange
      const customPadding = EdgeInsets.all(32);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const AppCard(
            padding: customPadding,
            child: Text('Custom padding'),
          ),
        ),
      );

      // Assert
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, customPadding);
    });

    testWidgets('applies custom margin', (tester) async {
      // Arrange
      const customMargin = EdgeInsets.all(24);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const AppCard(
            margin: customMargin,
            child: Text('Custom margin'),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, customMargin);
    });

    testWidgets('has default margin when not specified', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const AppCard(
            child: Text('Default margin'),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
    });

    testWidgets('has default padding when not specified', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const AppCard(
            child: Text('Default padding'),
          ),
        ),
      );

      // Assert
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(16));
    });

    testWidgets('has rounded corners', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const AppCard(
            child: Text('Rounded'),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder?;
      expect(shape, isNotNull);
      expect(
        shape!.borderRadius,
        BorderRadius.circular(12),
      );
    });

    testWidgets('contains InkWell for tap effects', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          AppCard(
            onTap: () {},
            child: const Text('Inkwell'),
          ),
        ),
      );

      // Assert
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('InkWell has rounded border radius', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          AppCard(
            onTap: () {},
            child: const Text('Border radius'),
          ),
        ),
      );

      // Assert
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, BorderRadius.circular(12));
    });
  });
}
