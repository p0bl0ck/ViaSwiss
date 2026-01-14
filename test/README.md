# ViaSwiss App - Test Suite

Comprehensive test suite for the ViaSwiss Flutter application with unit tests, widget tests, and integration tests.

## Test Structure

```
test/
├── helpers/              # Test utilities and mock data
│   ├── mock_data.dart    # Mock data for all tests
│   └── test_helpers.dart # Helper functions for testing
│
├── unit/                 # Unit tests
│   ├── utils/           # Utility function tests
│   ├── models/          # Domain model tests
│   ├── repositories/    # Repository tests
│   └── providers/       # Provider tests
│
├── widget/              # Widget tests
│   ├── shared/         # Shared widget tests
│   └── features/       # Feature widget tests
│
└── integration/         # Integration tests
    └── screens/        # Screen flow tests
```

## Test Categories

### 1. Unit Tests

Unit tests verify individual components in isolation.

#### Utilities Tests (`test/unit/utils/`)
- **date_formatter_test.dart**: Tests date and time formatting functions
  - Time formatting (HH:mm)
  - Date formatting
  - Duration formatting
  - Time range formatting
  - ISO 8601 parsing

#### Model Tests (`test/unit/models/`)
- **station_test.dart**: Tests Station and Coordinates models
  - JSON serialization/deserialization
  - Equality comparison
  - Round-trip data preservation

- **journey_test.dart**: Tests Journey, Leg, and Transport models
  - All transport types
  - Journey with/without transfers
  - Scenic score handling
  - Platform and delay information

#### Repository Tests (`test/unit/repositories/`)
- **station_repository_test.dart**: Tests StationRepository
  - Station search with query
  - Get station by ID
  - Error handling
  - Cache policies
  - Query parameters

### 2. Widget Tests

Widget tests verify UI components render correctly and respond to interactions.

#### Shared Widget Tests (`test/widget/shared/`)
- **app_card_test.dart**: Tests AppCard widget
  - Child rendering
  - Tap interactions
  - Custom padding/margin
  - Default styling
  - InkWell effects

#### Feature Widget Tests (`test/widget/features/`)
- **journey_card_test.dart**: Tests JourneyCard widget
  - Journey information display
  - Time formatting
  - Transfer count display
  - Scenic score display
  - Duration formatting
  - Icon display
  - Tap callbacks

### 3. Test Helpers

#### Mock Data (`test/helpers/mock_data.dart`)
Provides mock data for all tests:
- Mock stations (Zürich HB, Bern, Geneva, Interlaken)
- Mock transport types (IC, IR, etc.)
- Mock journeys with various configurations
- Mock weather data
- Mock GraphQL responses

#### Test Helpers (`test/helpers/test_helpers.dart`)
Utility functions for testing:
- `wrapWithProviders()`: Wrap widgets with ProviderScope
- `wrapWithMaterialApp()`: Wrap widgets with MaterialApp
- `pumpWithProviders()`: Pump widget with providers
- `findTextContaining()`: Find text by partial match
- `isCloseTo()`: DateTime matcher with tolerance

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/utils/date_formatter_test.dart
```

### Run Tests by Category
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests only
flutter test test/integration/
```

### Run Tests with Coverage
```bash
# Generate coverage report
flutter test --coverage

# View coverage in HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Tests in Watch Mode
```bash
# Auto-run tests on file changes
flutter test --watch
```

## Test Dependencies

The following packages are used for testing:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4        # Mocking framework
  mocktail: ^1.0.3       # Alternative mocking (simpler)
  fake_async: ^1.3.1     # Async testing utilities
```

## Writing New Tests

### Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyClass', () {
    late MyClass myClass;

    setUp(() {
      myClass = MyClass();
    });

    test('does something', () {
      // Arrange
      final input = 'test';

      // Act
      final result = myClass.doSomething(input);

      // Assert
      expect(result, 'expected');
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MyWidget', () {
    testWidgets('renders correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          MyWidget(),
        ),
      );

      // Assert
      expect(find.byType(MyWidget), findsOneWidget);
    });
  });
}
```

### Repository Test with Mocks

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements GraphQLClient {}

void main() {
  late MockClient mockClient;
  late MyRepository repository;

  setUp(() {
    mockClient = MockClient();
    repository = MyRepository(mockClient);
  });

  test('fetches data successfully', () async {
    // Arrange
    when(() => mockClient.query(any())).thenAnswer(
      (_) async => mockResponse,
    );

    // Act
    final result = await repository.getData();

    // Assert
    expect(result, isNotNull);
    verify(() => mockClient.query(any())).called(1);
  });
}
```

## Best Practices

### 1. Test Organization
- One test file per source file
- Group related tests together
- Use descriptive test names
- Follow Arrange-Act-Assert pattern

### 2. Test Naming
```dart
// Good
test('returns list of stations on successful query', () {});

// Bad
test('test1', () {});
```

### 3. Use Mock Data
```dart
// Use shared mock data
final station = MockData.zurichHB;

// Instead of creating inline
final station = Station(id: '123', name: 'Test', ...);
```

### 4. Test Edge Cases
- Empty data
- Null values
- Error conditions
- Boundary values

### 5. Keep Tests Independent
- Each test should run independently
- Use `setUp()` and `tearDown()` for initialization
- Don't rely on test execution order

### 6. Test User Interactions
```dart
await tester.tap(find.byType(MyButton));
await tester.pumpAndSettle();
```

## Coverage Goals

Target coverage levels:
- **Overall**: 80%+
- **Utils**: 90%+
- **Models**: 85%+
- **Repositories**: 80%+
- **Widgets**: 75%+

## Continuous Integration

Tests are run automatically on:
- Every commit
- Pull requests
- Before deployment

## Troubleshooting

### Common Issues

**Issue**: Tests fail with "No Material widget found"
```dart
// Solution: Wrap with MaterialApp
await tester.pumpWidget(
  wrapWithMaterialApp(MyWidget()),
);
```

**Issue**: Async tests timeout
```dart
// Solution: Use pumpAndSettle or increase timeout
await tester.pumpAndSettle();
// or
test('my test', () async {
  // test code
}, timeout: Timeout(Duration(seconds: 30)));
```

**Issue**: Mock not working
```dart
// Solution: Register fallback values for mocktail
setUpAll(() {
  registerFallbackValue(MyClass());
});
```

**Issue**: Widget not found
```dart
// Solution: Use pump after interactions
await tester.tap(find.byType(MyButton));
await tester.pump(); // or pumpAndSettle()
expect(find.text('Result'), findsOneWidget);
```

## Test Metrics

View test metrics:
```bash
# Run with verbose output
flutter test --reporter expanded

# Generate JSON report
flutter test --reporter json > test_results.json
```

## Future Enhancements

- [ ] Add integration tests for complete user flows
- [ ] Add golden tests for pixel-perfect UI verification
- [ ] Add performance tests for heavy operations
- [ ] Add accessibility tests
- [ ] Increase coverage to 90%+
- [ ] Add automated visual regression testing

## Contributing

When adding new features:
1. Write tests first (TDD)
2. Ensure all tests pass
3. Maintain coverage above 80%
4. Update this documentation

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Widget Testing](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)
