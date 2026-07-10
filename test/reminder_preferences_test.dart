import 'package:celebray/features/notifications/notification_payload.dart';
import 'package:celebray/features/notifications/reminder_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderPreferences', () {
    test('defaults enable all reminder offsets', () {
      const prefs = ReminderPreferences();
      expect(prefs.enabledOffsets.length, ReminderOffset.values.length);
      expect(prefs.advanceReminderHour, 9);
      expect(prefs.morningOfHour, 8);
    });

    test('copyWith toggles offsets', () {
      const prefs = ReminderPreferences();
      final updated = prefs.copyWith(
        enabledOffsets: {ReminderOffset.celebrationDay},
      );
      expect(updated.isEnabled(ReminderOffset.celebrationDay), isTrue);
      expect(updated.isEnabled(ReminderOffset.days7), isFalse);
    });
  });

  group('NotificationPayload', () {
    test('round-trips JSON payload', () {
      const payload = NotificationPayload(
        eventId: 'abc-123',
        offset: ReminderOffset.days3,
      );
      final decoded = NotificationPayload.decode(payload.encode());
      expect(decoded?.eventId, 'abc-123');
      expect(decoded?.offset, ReminderOffset.days3);
    });

    test('supports legacy plain event id', () {
      final decoded = NotificationPayload.decode('legacy-id');
      expect(decoded?.eventId, 'legacy-id');
      expect(decoded?.offset, isNull);
    });
  });
}
