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
    final name = event.name.trim();
    final type = event.type.trim();
    final relationship = event.relationship.trim();

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
}
