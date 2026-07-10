import 'package:shared_preferences/shared_preferences.dart';

/// When to fire a celebration reminder relative to the event date.
enum ReminderOffset {
  days7,
  days3,
  days1,
  morningOf,
  celebrationDay,
}

extension ReminderOffsetX on ReminderOffset {
  String get settingsLabel => switch (this) {
        ReminderOffset.days7 => '7 days before',
        ReminderOffset.days3 => '3 days before',
        ReminderOffset.days1 => '1 day before',
        ReminderOffset.morningOf => 'Morning of',
        ReminderOffset.celebrationDay => 'Celebration day (midnight)',
      };

  String get payloadKey => name;
}

/// User-configurable reminder schedule (global for all events).
class ReminderPreferences {
  const ReminderPreferences({
    this.enabledOffsets = const {
      ReminderOffset.days7,
      ReminderOffset.days3,
      ReminderOffset.days1,
      ReminderOffset.morningOf,
      ReminderOffset.celebrationDay,
    },
    this.advanceReminderHour = 9,
    this.morningOfHour = 8,
  });

  final Set<ReminderOffset> enabledOffsets;
  final int advanceReminderHour;
  final int morningOfHour;

  bool isEnabled(ReminderOffset offset) => enabledOffsets.contains(offset);

  ReminderPreferences copyWith({
    Set<ReminderOffset>? enabledOffsets,
    int? advanceReminderHour,
    int? morningOfHour,
  }) {
    return ReminderPreferences(
      enabledOffsets: enabledOffsets ?? this.enabledOffsets,
      advanceReminderHour: advanceReminderHour ?? this.advanceReminderHour,
      morningOfHour: morningOfHour ?? this.morningOfHour,
    );
  }

  static const _prefix = 'reminder_offset_';
  static const _advanceHourKey = 'reminder_advance_hour';
  static const _morningHourKey = 'reminder_morning_hour';

  static Future<ReminderPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = <ReminderOffset>{};
    for (final offset in ReminderOffset.values) {
      final defaultOn = true;
      if (prefs.getBool('$_prefix${offset.name}') ?? defaultOn) {
        enabled.add(offset);
      }
    }
    return ReminderPreferences(
      enabledOffsets: enabled,
      advanceReminderHour: prefs.getInt(_advanceHourKey) ?? 9,
      morningOfHour: prefs.getInt(_morningHourKey) ?? 8,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    for (final offset in ReminderOffset.values) {
      await prefs.setBool(
        '$_prefix${offset.name}',
        enabledOffsets.contains(offset),
      );
    }
    await prefs.setInt(_advanceHourKey, advanceReminderHour);
    await prefs.setInt(_morningHourKey, morningOfHour);
  }
}
