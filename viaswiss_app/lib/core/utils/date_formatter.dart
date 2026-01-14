import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d').format(dateTime);
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) {
      return '${mins}min';
    } else if (mins == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${mins}min';
    }
  }

  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatDateTime(start)} - ${formatDateTime(end)}';
  }

  static DateTime parseIso8601(String isoString) {
    return DateTime.parse(isoString);
  }
}
