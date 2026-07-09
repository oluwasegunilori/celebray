import 'package:celebray/features/calendar_import/calendar_import_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarImportFilters.isHolidayCalendar', () {
    test('detects subscribed holiday calendars', () {
      expect(
        CalendarImportFilters.isHolidayCalendar(
          name: 'US Holidays',
          accountName: 'Subscribed Calendars',
        ),
        isTrue,
      );
    });

    test('does not flag birthday calendars', () {
      expect(
        CalendarImportFilters.isHolidayCalendar(name: 'Birthdays'),
        isFalse,
      );
    });
  });

  group('CalendarImportFilters.isPublicHolidayTitle', () {
    test('flags common civic holidays', () {
      expect(
        CalendarImportFilters.isPublicHolidayTitle('Christmas Day'),
        isTrue,
      );
      expect(
        CalendarImportFilters.isPublicHolidayTitle('Thanksgiving'),
        isTrue,
      );
      expect(
        CalendarImportFilters.isPublicHolidayTitle('Independence Day'),
        isTrue,
      );
    });

    test('keeps personal celebrations', () {
      expect(
        CalendarImportFilters.isPublicHolidayTitle("David's Birthday"),
        isFalse,
      );
      expect(
        CalendarImportFilters.isPublicHolidayTitle('David & Jessica Anniversary'),
        isFalse,
      );
    });
  });
}
