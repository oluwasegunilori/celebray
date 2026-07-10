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
      final granted = await FlutterContacts.requestPermission(readonly: true);
      if (!granted) {
        return const ContactImportResult(
          status: ContactImportStatus.permissionDenied,
          message:
              'Contacts access is needed to find birthdays. '
              'Open Settings → Celebray → Contacts and allow access.',
        );
      }

      final lastContacted = await ContactFrequencyService.lastContactedTimes();
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      final existingKeys = existingEvents
          .map((e) => _dedupeKeyForEvent(e))
          .where((k) => k.isNotEmpty)
          .toSet();

      final raw = <ContactSuggestion>[];

      for (final contact in contacts) {
        final name = _displayName(contact);
        if (name.isEmpty) continue;

        for (final event in contact.events) {
          if (!_isBirthdayEvent(event)) continue;
          if (event.month < 1 || event.month > 12) continue;
          if (event.day < 1 || event.day > 31) continue;

          final year = event.year ?? DateTime.now().year;
          final date = DateTime(year, event.month, event.day);
          final dedupeKey =
              '${name.toLowerCase().trim()}-${date.month}-${date.day}';
          if (existingKeys.contains(dedupeKey)) continue;

          final score = lastContacted[contact.id] ?? 0;
          raw.add(
            ContactSuggestion(
              contactId: contact.id,
              name: name,
              date: date,
              frequencyScore: score,
              isFrequentlyContacted: false,
            ),
          );
        }
      }

      if (raw.isEmpty) {
        return const ContactImportResult(
          status: ContactImportStatus.empty,
          message:
              'No birthdays found in your contacts. Add birthdays in the Contacts app first.',
        );
      }

      raw.sort((a, b) => b.frequencyScore.compareTo(a.frequencyScore));

      final frequentCutoff = _frequentScoreThreshold;
      final frequentCandidates = raw
          .where((s) => s.frequencyScore >= frequentCutoff)
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

      final frequentKeys = frequentCandidates.map((s) => s.dedupeKey).toSet();
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

      return ContactImportResult(
        status: ContactImportStatus.ready,
        frequentSuggestions: frequentCandidates,
        suggestions: others,
      );
    } catch (e) {
      return ContactImportResult(
        status: ContactImportStatus.error,
        message: 'Could not read contacts: $e',
      );
    }
  }

  static bool _isBirthdayEvent(Event event) {
    if (event.label == EventLabel.birthday) return true;
    if (event.label == EventLabel.custom) {
      final custom = event.customLabel.toLowerCase();
      return custom.contains('birthday') || custom.contains('bday');
    }
    return false;
  }

  static String _displayName(Contact contact) {
    final display = contact.displayName.trim();
    if (display.isNotEmpty) {
      return EventFormOptions.normalizePersonName(display);
    }
    final first = contact.name.first.trim();
    final last = contact.name.last.trim();
    return EventFormOptions.normalizePersonName('$first $last'.trim());
  }

  static String _dedupeKeyForEvent(EventModel event) {
    final name = event.name.trim();
    if (name.isEmpty) return '';
    return '${name.toLowerCase()}-${event.date.month}-${event.date.day}';
  }

  static Future<void> openAppSettings() async {
    final uri = Uri.parse(
      Platform.isIOS ? 'app-settings:' : 'package:com.shegz.celebray',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
