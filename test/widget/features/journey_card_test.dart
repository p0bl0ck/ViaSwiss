import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viaswiss_app/features/journey/presentation/widgets/journey_card.dart';
import '../../helpers/mock_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('JourneyCard', () {
    testWidgets('displays journey information', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(
        from: MockData.zurichHB,
        to: MockData.bern,
        duration: 150,
        transfers: 0,
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Zürich HB'), findsOneWidget);
      expect(find.text('Bern'), findsOneWidget);
      expect(find.text('2h 30min'), findsOneWidget);
    });

    testWidgets('displays departure and arrival times', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(
        departure: DateTime(2024, 1, 15, 10, 30),
        arrival: DateTime(2024, 1, 15, 14, 45),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('14:45'), findsOneWidget);
    });

    testWidgets('shows "Direct" for zero transfers', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(transfers: 0);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Direct'), findsOneWidget);
    });

    testWidgets('shows transfer count for single transfer', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(transfers: 1);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('1 transfer'), findsOneWidget);
    });

    testWidgets('shows plural transfers for multiple transfers', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(transfers: 3);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('3 transfers'), findsOneWidget);
    });

    testWidgets('displays scenic score when available', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(scenicScore: 0.85);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Scenic 85%'), findsOneWidget);
    });

    testWidgets('does not display scenic score when null', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(scenicScore: null);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Scenic'), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      // Arrange
      var tapped = false;
      final journey = MockData.createMockJourney();

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(JourneyCard));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('displays duration icon', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney();

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(
        find.descendant(
          of: find.byType(JourneyCard),
          matching: find.byIcon(Icons.arrow_forward),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays transfer icon', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(transfers: 1);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(
        find.descendant(
          of: find.byType(JourneyCard),
          matching: find.byIcon(Icons.swap_horiz),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays landscape icon for scenic journeys', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(scenicScore: 0.75);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(
        find.descendant(
          of: find.byType(JourneyCard),
          matching: find.byIcon(Icons.landscape),
        ),
        findsOneWidget,
      );
    });

    testWidgets('formats short durations correctly', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(duration: 45);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('45min'), findsOneWidget);
    });

    testWidgets('formats hour-only durations correctly', (tester) async {
      // Arrange
      final journey = MockData.createMockJourney(duration: 120);

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          JourneyCard(
            journey: journey,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('2h'), findsOneWidget);
    });
  });
}
