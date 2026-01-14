import 'package:flutter_test/flutter_test.dart';
import 'package:viaswiss_app/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('formatDateTime', () {
      test('formats time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        expect(DateFormatter.formatDateTime(dateTime), '14:30');
      });

      test('formats time with leading zeros', () {
        final dateTime = DateTime(2024, 1, 15, 9, 5);
        expect(DateFormatter.formatDateTime(dateTime), '09:05');
      });

      test('formats midnight correctly', () {
        final dateTime = DateTime(2024, 1, 15, 0, 0);
        expect(DateFormatter.formatDateTime(dateTime), '00:00');
      });

      test('formats noon correctly', () {
        final dateTime = DateTime(2024, 1, 15, 12, 0);
        expect(DateFormatter.formatDateTime(dateTime), '12:00');
      });
    });

    group('formatDate', () {
      test('formats date correctly', () {
        final dateTime = DateTime(2024, 1, 15);
        final result = DateFormatter.formatDate(dateTime);
        expect(result, contains('Jan'));
        expect(result, contains('15'));
      });

      test('includes day of week', () {
        final dateTime = DateTime(2024, 1, 15); // Monday
        final result = DateFormatter.formatDate(dateTime);
        expect(result, contains('Mon'));
      });
    });

    group('formatDuration', () {
      test('formats minutes only', () {
        expect(DateFormatter.formatDuration(45), '45min');
        expect(DateFormatter.formatDuration(1), '1min');
        expect(DateFormatter.formatDuration(59), '59min');
      });

      test('formats hours only', () {
        expect(DateFormatter.formatDuration(60), '1h');
        expect(DateFormatter.formatDuration(120), '2h');
        expect(DateFormatter.formatDuration(180), '3h');
      });

      test('formats hours and minutes', () {
        expect(DateFormatter.formatDuration(90), '1h 30min');
        expect(DateFormatter.formatDuration(150), '2h 30min');
        expect(DateFormatter.formatDuration(65), '1h 5min');
      });

      test('handles zero duration', () {
        expect(DateFormatter.formatDuration(0), '0min');
      });

      test('handles large durations', () {
        expect(DateFormatter.formatDuration(1440), '24h');
        expect(DateFormatter.formatDuration(1500), '25h');
      });
    });

    group('formatTimeRange', () {
      test('formats time range correctly', () {
        final start = DateTime(2024, 1, 15, 10, 30);
        final end = DateTime(2024, 1, 15, 14, 45);
        expect(DateFormatter.formatTimeRange(start, end), '10:30 - 14:45');
      });

      test('handles same day times', () {
        final start = DateTime(2024, 1, 15, 9, 0);
        final end = DateTime(2024, 1, 15, 9, 30);
        expect(DateFormatter.formatTimeRange(start, end), '09:00 - 09:30');
      });

      test('handles overnight times', () {
        final start = DateTime(2024, 1, 15, 23, 30);
        final end = DateTime(2024, 1, 16, 1, 15);
        expect(DateFormatter.formatTimeRange(start, end), '23:30 - 01:15');
      });
    });

    group('parseIso8601', () {
      test('parses ISO 8601 string correctly', () {
        final isoString = '2024-01-15T14:30:00.000Z';
        final result = DateFormatter.parseIso8601(isoString);
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
      });

      test('parses ISO 8601 with timezone', () {
        final isoString = '2024-01-15T14:30:00+01:00';
        final result = DateFormatter.parseIso8601(isoString);
        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
      });

      test('throws on invalid format', () {
        expect(
          () => DateFormatter.parseIso8601('invalid'),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
