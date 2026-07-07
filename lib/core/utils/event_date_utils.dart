/// Utilities for recurring celebration dates (birthdays, anniversaries).
class EventDateUtils {
  /// Returns the next occurrence of a celebration on or after today.
  static DateTime nextOccurrence(DateTime date) {
    final now = DateTime.now();
    var next = DateTime(
      now.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
    );
    if (!next.isAfter(now)) {
      next = DateTime(
        now.year + 1,
        date.month,
        date.day,
        date.hour,
        date.minute,
      );
    }
    return next;
  }

  /// Days until the next occurrence (0 = today).
  static int daysUntilNext(DateTime date) {
    final next = nextOccurrence(date);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final nextStart = DateTime(next.year, next.month, next.day);
    return nextStart.difference(todayStart).inDays;
  }

  /// Whether two dates fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Match events to a calendar day (ignoring year for recurring events).
  static bool occursOnDay(DateTime eventDate, DateTime day) {
    return eventDate.month == day.month && eventDate.day == day.day;
  }
}
