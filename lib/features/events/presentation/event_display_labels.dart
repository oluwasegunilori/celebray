import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';

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
    final labels = from(event);
    final type = event.type.trim();
    final headline = labels.title;

    if (type.isEmpty || _alreadyMentioned(headline.toLowerCase(), type)) {
      return "🎉 It's $headline today!";
    }

    return "🎉 It's $headline's $type today!";
  }
}
