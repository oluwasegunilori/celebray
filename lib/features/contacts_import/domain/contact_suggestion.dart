import 'package:celebray/core/utils/unique_id.dart';
import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:equatable/equatable.dart';

class ContactSuggestion extends Equatable {
  const ContactSuggestion({
    required this.contactId,
    required this.name,
    required this.frequencyScore,
    this.date,
    this.isFrequentlyContacted = false,
  });

  final String contactId;
  final String name;
  final DateTime? date;
  final int frequencyScore;
  final bool isFrequentlyContacted;

  bool get hasBirthday => date != null;

  String get dedupeKey => hasBirthday
      ? '${name.toLowerCase().trim()}-${date!.month}-${date!.day}'
      : 'contact-$contactId';

  EventModel toDraftEvent() {
    assert(hasBirthday, 'Use toNamePrefillDraft for contacts without birthdays');
    return _baseDraft(date: date!);
  }

  /// Name and defaults only — user picks the celebration date in Add Event.
  EventModel toNamePrefillDraft() {
    return _baseDraft(date: DateTime.now());
  }

  EventModel _baseDraft({required DateTime date}) {
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
    this.namePrefills = const [],
    this.frequentNamePrefills = const [],
    this.message,
  });

  final ContactImportStatus status;
  final List<ContactSuggestion> suggestions;
  final List<ContactSuggestion> frequentSuggestions;
  final List<ContactSuggestion> namePrefills;
  final List<ContactSuggestion> frequentNamePrefills;
  final String? message;

  bool get hasBirthdays =>
      frequentSuggestions.isNotEmpty || suggestions.isNotEmpty;

  bool get hasNamePrefills =>
      frequentNamePrefills.isNotEmpty || namePrefills.isNotEmpty;

  List<ContactSuggestion> get allBirthdaySuggestions => [
        ...frequentSuggestions,
        ...suggestions.where(
          (s) => !frequentSuggestions.any((f) => f.dedupeKey == s.dedupeKey),
        ),
      ];

  List<ContactSuggestion> get allNamePrefills => [
        ...frequentNamePrefills,
        ...namePrefills.where(
          (s) => !frequentNamePrefills.any((f) => f.dedupeKey == s.dedupeKey),
        ),
      ];
}
