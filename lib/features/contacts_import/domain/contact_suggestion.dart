import 'package:celebray/core/utils/unique_id.dart';
import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:equatable/equatable.dart';

class ContactSuggestion extends Equatable {
  const ContactSuggestion({
    required this.contactId,
    required this.name,
    required this.date,
    required this.frequencyScore,
    this.isFrequentlyContacted = false,
  });

  final String contactId;
  final String name;
  final DateTime date;
  final int frequencyScore;
  final bool isFrequentlyContacted;

  String get dedupeKey =>
      '${name.toLowerCase().trim()}-${date.month}-${date.day}';

  EventModel toDraftEvent() {
    final relationship = EventFormOptions.relationships.first;
    return EventModel(
      id: uniqueId(),
      name: name,
      type: 'Birthday',
      date: DateTime(date.year, date.month, date.day),
      relationship: relationship,
      sex: EventFormOptions.suggestedSexForRelationship(relationship) ?? 'Other',
      closeness: isFrequentlyContacted ? 7 : 5,
    );
  }

  @override
  List<Object?> get props => [
        contactId,
        name,
        date,
        frequencyScore,
        isFrequentlyContacted,
      ];
}

enum ContactImportStatus {
  loading,
  permissionDenied,
  unsupported,
  empty,
  ready,
  error,
}

class ContactImportResult {
  const ContactImportResult({
    required this.status,
    this.suggestions = const [],
    this.frequentSuggestions = const [],
    this.message,
  });

  final ContactImportStatus status;
  final List<ContactSuggestion> suggestions;
  final List<ContactSuggestion> frequentSuggestions;
  final String? message;

  List<ContactSuggestion> get allSuggestions => [
        ...frequentSuggestions,
        ...suggestions.where(
          (s) => !frequentSuggestions.any((f) => f.dedupeKey == s.dedupeKey),
        ),
      ];
}
