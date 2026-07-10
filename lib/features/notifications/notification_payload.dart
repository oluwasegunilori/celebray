import 'dart:convert';

import 'package:celebray/features/notifications/reminder_preferences.dart';

class NotificationPayload {
  const NotificationPayload({
    required this.eventId,
    this.offset,
  });

  final String eventId;
  final ReminderOffset? offset;

  String encode() => jsonEncode({
        'eventId': eventId,
        if (offset != null) 'offset': offset!.payloadKey,
      });

  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final eventId = map['eventId'] as String?;
      if (eventId == null || eventId.isEmpty) return null;
      final offsetRaw = map['offset'] as String?;
      ReminderOffset? offset;
      if (offsetRaw != null) {
        offset = ReminderOffset.values.firstWhere(
          (o) => o.payloadKey == offsetRaw,
          orElse: () => ReminderOffset.celebrationDay,
        );
      }
      return NotificationPayload(eventId: eventId, offset: offset);
    } catch (_) {
      return NotificationPayload(eventId: raw);
    }
  }
}
