import 'dart:io';

import 'package:celebray/features/contacts_import/contact_frequency_service.dart';
import 'package:celebray/features/contacts_import/domain/contact_suggestion.dart';
import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsImportService {
  ContactsImportService._();

  static const _frequentTopCount = 12;
  static const _frequentScoreThreshold = 1;

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static Future<ContactImportResult> fetchSuggestions({
    required List<EventModel> existingEvents,
  }) async {
    if (!isSupportedPlatform) {
      return const ContactImportResult(
        status: ContactImportStatus.unsupported,
        message:
            'Contacts import works on iPhone and Android. Run the app on a phone or simulator.',
      );
    }

    try {
      var permission = await FlutterContacts.permissions.check(
        PermissionType.read,
      );
      if (permission == PermissionStatus.notDetermined ||
          permission == PermissionStatus.denied) {
        permission = await FlutterContacts.permissions.request(
          PermissionType.read,
        );
      }
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.limited) {
        return const ContactImportResult(
          status: ContactImportStatus.permissionDenied,
          message:
              'Contacts access is needed to find people to celebrate. '
              'Open Settings → Celebray → Contacts and allow access.',
        );
      }

      final lastContacted = await ContactFrequencyService.lastContactedTimes();
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.event},
      );

      final existingKeys = existingEvents
          .map((e) => _dedupeKeyForEvent(e))
          .where((k) => k.isNotEmpty)
          .toSet();
      final existingNames = existingEvents
          .map((e) => e.name.toLowerCase().trim())
          .where((n) => n.isNotEmpty)
          .toSet();

      final birthdayRaw = <ContactSuggestion>[];
      final namePrefillRaw = <ContactSuggestion>[];

      for (final contact in contacts) {
        final contactId = contact.id;
        if (contactId == null || contactId.isEmpty) continue;

        final name = _displayName(contact);
        if (name.isEmpty) continue;

        final score = lastContacted[contactId] ?? 0;
        var addedBirthday = false;

        for (final event in contact.events) {
          if (!_isBirthdayEvent(event)) continue;
          if (event.month < 1 || event.month > 12) continue;
          if (event.day < 1 || event.day > 31) continue;

          final year = event.year ?? DateTime.now().year;
          final date = DateTime(year, event.month, event.day);
          final dedupeKey =
              '${name.toLowerCase().trim()}-${date.month}-${date.day}';
          if (existingKeys.contains(dedupeKey)) continue;

          birthdayRaw.add(
            ContactSuggestion(
              contactId: contactId,
              name: name,
              date: date,
              frequencyScore: score,
            ),
          );
          addedBirthday = true;
        }

        if (addedBirthday) continue;
        if (existingNames.contains(name.toLowerCase())) continue;

        namePrefillRaw.add(
          ContactSuggestion(
            contactId: contactId,
            name: name,
            frequencyScore: score,
          ),
        );
      }

      if (birthdayRaw.isEmpty && namePrefillRaw.isEmpty) {
        return const ContactImportResult(
          status: ContactImportStatus.empty,
          message:
              'No new contacts to add. Everyone here may already be in Celebray.',
        );
      }

      final birthdayLists = _partitionByFrequency(birthdayRaw);
      final nameLists = _partitionByFrequency(namePrefillRaw);

      return ContactImportResult(
        status: ContactImportStatus.ready,
        frequentSuggestions: birthdayLists.frequent,
        suggestions: birthdayLists.others,
        frequentNamePrefills: nameLists.frequent,
        namePrefills: nameLists.others,
      );
    } catch (e) {
      return ContactImportResult(
        status: ContactImportStatus.error,
        message: 'Could not read contacts: $e',
      );
    }
  }

  static _PartitionedSuggestions _partitionByFrequency(
    List<ContactSuggestion> raw,
  ) {
    raw.sort((a, b) => b.frequencyScore.compareTo(a.frequencyScore));

    final frequent = raw
        .where((s) => s.frequencyScore >= _frequentScoreThreshold)
        .take(_frequentTopCount)
        .map(
          (s) => ContactSuggestion(
            contactId: s.contactId,
            name: s.name,
            date: s.date,
            frequencyScore: s.frequencyScore,
            isFrequentlyContacted: true,
          ),
        )
        .toList();

    final frequentKeys = frequent.map((s) => s.dedupeKey).toSet();
    final others = raw
        .where((s) => !frequentKeys.contains(s.dedupeKey))
        .map(
          (s) => ContactSuggestion(
            contactId: s.contactId,
            name: s.name,
            date: s.date,
            frequencyScore: s.frequencyScore,
          ),
        )
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return _PartitionedSuggestions(frequent: frequent, others: others);
  }

  static bool _isBirthdayEvent(Event event) {
    if (event.label.label == EventLabel.birthday) return true;
    if (event.label.label == EventLabel.custom) {
      final custom = event.label.customLabel?.toLowerCase() ?? '';
      return custom.contains('birthday') || custom.contains('bday');
    }
    return false;
  }

  static String _displayName(Contact contact) {
    final display = contact.displayName?.trim() ?? '';
    if (display.isNotEmpty) {
      return EventFormOptions.normalizePersonName(display);
    }
    final name = contact.name;
    if (name != null) {
      final first = name.first?.trim() ?? '';
      final last = name.last?.trim() ?? '';
      return EventFormOptions.normalizePersonName('$first $last'.trim());
    }
    return '';
  }

  static String _dedupeKeyForEvent(EventModel event) {
    final name = event.name.trim();
    if (name.isEmpty) return '';
    return '${name.toLowerCase()}-${event.date.month}-${event.date.day}';
  }

  static Future<void> openAppSettings() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await FlutterContacts.permissions.openSettings();
      return;
    }

    final uri = Uri.parse('package:com.shegz.celebray');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _PartitionedSuggestions {
  const _PartitionedSuggestions({
    required this.frequent,
    required this.others,
  });

  final List<ContactSuggestion> frequent;
  final List<ContactSuggestion> others;
}
