import 'package:celebray/core/utils/unique_id.dart';
import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:equatable/equatable.dart';

class CalendarSuggestion extends Equatable {
  final String calendarEventId;
  final String name;
  final String type;
  final DateTime date;
  final String sourceTitle;

  const CalendarSuggestion({
    required this.calendarEventId,
    required this.name,
    required this.type,
    required this.date,
    required this.sourceTitle,
  });

  String get dedupeKey =>
      '${name.toLowerCase().trim()}-${date.month}-${date.day}';

  EventModel toDraftEvent() {
    final relationship = EventFormOptions.relationships.first;
    return EventModel(
      id: uniqueId(),
      name: name,
      type: type,
      date: DateTime(date.year, date.month, date.day),
      relationship: relationship,
      sex: EventFormOptions.suggestedSexForRelationship(relationship) ?? 'Other',
      closeness: 5,
    );
  }

  @override
  List<Object?> get props => [calendarEventId, name, type, date, sourceTitle];
}

enum CalendarImportStatus {
  loading,
  permissionDenied,
  unsupported,
  empty,
  ready,
  error,
}

class CalendarImportResult {
  final CalendarImportStatus status;
  final List<CalendarSuggestion> suggestions;
  final String? message;

  const CalendarImportResult({
    required this.status,
    this.suggestions = const [],
    this.message,
  });
}
