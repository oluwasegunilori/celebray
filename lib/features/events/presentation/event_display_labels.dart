import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/notifications/reminder_preferences.dart';

/// Headline and metadata for event list rows, without repeating type/relationship.
class EventDisplayLabels {
  final String title;
  final bool showTypeChip;
  final bool showRelationshipChip;

  const EventDisplayLabels({
    required this.title,
    this.showTypeChip = false,
    this.showRelationshipChip = false,
  });

  static EventDisplayLabels from(EventModel event) {
    final rawName = event.name.trim();
    final type = event.type.trim();
    final relationship = event.relationship.trim();

    final name = rawName.isNotEmpty
        ? EventFormOptions.normalizePersonName(rawName, eventType: type)
        : '';

    final title = name.isNotEmpty
        ? name
        : relationship.isNotEmpty
            ? "$relationship's $type"
            : type;

    final titleLower = title.toLowerCase();
    final showType =
        type.isNotEmpty && !_alreadyMentioned(titleLower, type);
    final showRelationship = relationship.isNotEmpty &&
        !_alreadyMentioned(titleLower, relationship);

    return EventDisplayLabels(
      title: title,
      showTypeChip: showType,
      showRelationshipChip: showRelationship,
    );
  }

  static bool _alreadyMentioned(String titleLower, String value) {
    final needle = value.toLowerCase().trim();
    if (needle.isEmpty) return true;
    if (titleLower.contains(needle)) return true;
    if (titleLower.contains("$needle's")) return true;
    return false;
  }

  /// Short label for notification body copy (e.g. "David", not "David's Birthday's Birthday").
  static String recipientLabel(EventModel event) {
    final rawName = event.name.trim();
    if (rawName.isNotEmpty) {
      return EventFormOptions.normalizePersonName(
        rawName,
        eventType: event.type,
      );
    }
    final relationship = event.relationship.trim();
    final type = event.type.trim();
    if (relationship.isNotEmpty) return relationship;
    return type;
  }

  /// Celebration-day notification title without repeating the event type.
  static String notificationTitle(EventModel event) {
    return reminderTitle(event, ReminderOffset.celebrationDay);
  }

  static String reminderTitle(EventModel event, ReminderOffset offset) {
    final labels = from(event);
    final type = event.type.trim();
    final headline = labels.title;
    final typePhrase = type.isEmpty ||
            _alreadyMentioned(headline.toLowerCase(), type)
        ? headline
        : "$headline's $type";

    return switch (offset) {
      ReminderOffset.days7 => 'Coming up: $typePhrase in 7 days',
      ReminderOffset.days3 => 'Coming up: $typePhrase in 3 days',
      ReminderOffset.days1 => 'Tomorrow: $typePhrase',
      ReminderOffset.morningOf => "Today: $typePhrase",
      ReminderOffset.celebrationDay => "🎉 It's $typePhrase today!",
    };
  }

  static String reminderBody(
    EventModel event,
    ReminderOffset offset, {
    required bool hasSavedMessage,
  }) {
    final recipient = recipientLabel(event);
    if (hasSavedMessage) {
      return switch (offset) {
        ReminderOffset.celebrationDay =>
          'Your message for $recipient is ready — tap to touch up or share.',
        ReminderOffset.morningOf =>
          'Your message for $recipient is ready — share when you are.',
        _ =>
          'Your saved message for $recipient is ready. Generate ideas or share anytime.',
      };
    }

    return switch (offset) {
      ReminderOffset.celebrationDay =>
        'Tap for customizable message ideas for $recipient — pick one, refine, and share.',
      ReminderOffset.morningOf =>
        'Generate a message for $recipient before the day gets away.',
      _ =>
        'Get a head start — tap to generate message ideas for $recipient.',
    };
  }
}
