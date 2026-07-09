import 'dart:io';

import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:celebray/features/calendar_import/calendar_import_filters.dart';
import 'package:celebray/features/calendar_import/domain/calendar_suggestion.dart';
import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarImportService {
  CalendarImportService._();

  static final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    if (!Platform.isIOS && !Platform.isAndroid) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<CalendarImportResult> fetchSuggestions({
    required List<EventModel> existingEvents,
  }) async {
    if (!isSupportedPlatform) {
      return const CalendarImportResult(
        status: CalendarImportStatus.unsupported,
        message:
            'Calendar import works on iPhone and Android. Run the app on a phone or simulator, not macOS desktop.',
      );
    }

    try {
      final granted = await _ensurePermission();
      if (!granted) {
        return const CalendarImportResult(
          status: CalendarImportStatus.permissionDenied,
          message:
              'Calendar access is needed to find birthdays and anniversaries. '
              'On iPhone, open Settings → Celebray → Calendars and choose Full Access.',
        );
      }

      final calendarsResult = await _plugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) {
        return CalendarImportResult(
          status: CalendarImportStatus.error,
          message: calendarsResult.errors.isNotEmpty
              ? calendarsResult.errors.first.errorMessage
              : 'Could not read your calendars.',
        );
      }

      final calendars = calendarsResult.data!;
      if (calendars.isEmpty) {
        return const CalendarImportResult(
          status: CalendarImportStatus.empty,
          message: 'No calendars found on this device.',
        );
      }

      final now = DateTime.now();
      final rangeStart = DateTime(now.year - 1, 1, 1);
      final rangeEnd = DateTime(now.year + 2, 12, 31, 23, 59, 59);
      final params = RetrieveEventsParams(
        startDate: rangeStart,
        endDate: rangeEnd,
      );

      final rawSuggestions = <CalendarSuggestion>[];

      for (final calendar in calendars) {
        if (_isHolidayCalendar(calendar)) continue;

        final calendarId = calendar.id;
        if (calendarId == null) continue;

        final eventsResult = await _plugin.retrieveEvents(calendarId, params);
        if (!eventsResult.isSuccess || eventsResult.data == null) continue;

        for (final event in eventsResult.data!) {
          if (!_isCelebrationCandidate(event, calendar)) continue;

          final start = event.start;
          if (start == null) continue;

          final localStart = start.toLocal();
          final name = _extractName(event.title ?? '');
          if (name.isEmpty) continue;

          rawSuggestions.add(
            CalendarSuggestion(
              calendarEventId: event.eventId ?? '$calendarId-${event.hashCode}',
              name: name,
              type: _inferType(
                event.title ?? '',
                isBirthdayCalendar: _isBirthdayCalendar(calendar),
              ),
              date: DateTime(
                localStart.year,
                localStart.month,
                localStart.day,
              ),
              sourceTitle: event.title ?? name,
            ),
          );
        }
      }

      final suggestions = _dedupeSuggestions(rawSuggestions, existingEvents);

      if (suggestions.isEmpty) {
        return const CalendarImportResult(
          status: CalendarImportStatus.empty,
          message:
              'No new birthdays or anniversaries found. Try adding them to your calendar first.',
        );
      }

      suggestions.sort((a, b) {
        final monthCompare = a.date.month.compareTo(b.date.month);
        if (monthCompare != 0) return monthCompare;
        final dayCompare = a.date.day.compareTo(b.date.day);
        if (dayCompare != 0) return dayCompare;
        return a.name.compareTo(b.name);
      });

      return CalendarImportResult(
        status: CalendarImportStatus.ready,
        suggestions: suggestions,
      );
    } on MissingPluginException {
      return const CalendarImportResult(
        status: CalendarImportStatus.error,
        message:
            'Calendar import is not loaded yet. Fully stop the app, then run it again on iPhone or Android (a hot restart is not enough).',
      );
    } on PlatformException catch (e) {
      return CalendarImportResult(
        status: CalendarImportStatus.error,
        message: e.message ??
            'Could not read your calendar. Please try again.',
      );
    } catch (e) {
      return CalendarImportResult(
        status: CalendarImportStatus.error,
        message: 'Something went wrong while reading your calendar.',
      );
    }
  }

  static Future<bool> _ensurePermission() async {
    try {
      final pluginResult = await _plugin.hasPermissions();
      if (pluginResult.isSuccess && (pluginResult.data ?? false)) {
        return true;
      }

      final requested = await _plugin.requestPermissions();
      if (requested.isSuccess && (requested.data ?? false)) {
        return true;
      }

      // Re-check after the system dialog — iOS 17+ may grant full access
      // asynchronously after requestFullAccessToEvents completes.
      final recheck = await _plugin.hasPermissions();
      return recheck.isSuccess && (recheck.data ?? false);
    } on MissingPluginException {
      rethrow;
    }
  }

  static Future<void> openAppSettings() async {
    if (Platform.isIOS) {
      final uri = Uri.parse('app-settings:');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
      return;
    }

    if (Platform.isAndroid) {
      final info = await PackageInfo.fromPlatform();
      final uri = Uri.parse(
        'intent:#Intent;action=android.settings.APPLICATION_DETAILS_SETTINGS;data=package:${info.packageName};end',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  static bool _isBirthdayCalendar(Calendar calendar) {
    final name = calendar.name?.toLowerCase() ?? '';
    return name.contains('birthday');
  }

  static bool _isHolidayCalendar(Calendar calendar) {
    return CalendarImportFilters.isHolidayCalendar(
      name: calendar.name,
      accountName: calendar.accountName,
      accountType: calendar.accountType,
    );
  }

  static bool _isCelebrationCandidate(Event event, Calendar calendar) {
    final title = event.title?.trim() ?? '';
    if (title.isEmpty) return false;

    final lowerTitle = title.toLowerCase();
    if (CalendarImportFilters.isPublicHolidayTitle(title)) return false;
    const skipWords = [
      'meeting',
      'call',
      'flight',
      'doctor',
      'dentist',
      'standup',
      'stand-up',
      'sync',
      'review',
      'deadline',
      'appointment',
      'interview',
      'conference',
      'reminder:',
    ];
    if (skipWords.any(lowerTitle.contains)) return false;

    final yearly =
        event.recurrenceRule?.recurrenceFrequency == RecurrenceFrequency.Yearly;
    const keywords = [
      'birthday',
      'bday',
      'b-day',
      'anniversary',
      'wedding',
      'graduation',
      'celebration',
      'shower',
      'reunion',
      'retirement',
      'baptism',
      'bar mitzvah',
      'bat mitzvah',
    ];
    final hasKeyword = keywords.any(lowerTitle.contains);

    if (_isBirthdayCalendar(calendar) && yearly) return true;
    if (hasKeyword) return true;
    if (yearly && event.allDay == true && _looksLikePersonName(title)) {
      return true;
    }

    return false;
  }

  static bool _looksLikePersonName(String title) {
    final words =
        title.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty || words.length > 4) return false;
    return words.every((word) => RegExp(r"^[A-Za-z'.-]+$").hasMatch(word));
  }

  static String _extractName(String title) {
    var working = title.trim();
    if (working.isEmpty) return '';

    final patterns = <RegExp>[
      RegExp(r"^(.+?)'s?\s+(birthday|b-?day|bday)", caseSensitive: false),
      RegExp(r'^(birthday|b-?day|bday)\s*[-–—:of]+\s*(.+)$', caseSensitive: false),
      RegExp(r"^(.+?)'s?\s+(anniversary|wedding)", caseSensitive: false),
      RegExp(
        r'^(anniversary|wedding)\s*[-–—:of]+\s*(.+)$',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(working);
      if (match == null) continue;
      final extracted = (match.group(1) ?? match.group(2))?.trim();
      if (extracted != null &&
          extracted.isNotEmpty &&
          !_isCelebrationWord(extracted)) {
        return extracted;
      }
    }

    working = working.replaceAll(
      RegExp(
        r"\s*('s)?\s*(birthday|b-?day|bday|anniversary|wedding|party|celebration|shower)\s*.*$",
        caseSensitive: false,
      ),
      '',
    );

    return working.trim().isEmpty ? title.trim() : working.trim();
  }

  static bool _isCelebrationWord(String value) {
    final lower = value.toLowerCase();
    return lower == 'birthday' ||
        lower == 'bday' ||
        lower == 'anniversary' ||
        lower == 'wedding';
  }

  static String _inferType(String title, {required bool isBirthdayCalendar}) {
    final lower = title.toLowerCase();
    if (lower.contains('work anniversary')) return 'Work Anniversary';
    if (lower.contains('anniversary')) return 'Anniversary';
    if (lower.contains('wedding')) return 'Wedding';
    if (lower.contains('graduation')) return 'Graduation';
    if (lower.contains('baby shower')) return 'Baby Shower';
    if (lower.contains('retirement')) return 'Retirement';
    if (lower.contains('reunion')) return 'Reunion';
    if (isBirthdayCalendar ||
        lower.contains('birthday') ||
        lower.contains('bday') ||
        lower.contains('b-day')) {
      return 'Birthday';
    }
    return 'Birthday';
  }

  static List<CalendarSuggestion> _dedupeSuggestions(
    List<CalendarSuggestion> suggestions,
    List<EventModel> existingEvents,
  ) {
    final seen = <String>{};
    final unique = <CalendarSuggestion>[];

    for (final suggestion in suggestions) {
      if (seen.contains(suggestion.dedupeKey)) continue;
      if (_alreadyExists(suggestion, existingEvents)) continue;
      seen.add(suggestion.dedupeKey);
      unique.add(suggestion);
    }

    return unique;
  }

  static bool _alreadyExists(
    CalendarSuggestion suggestion,
    List<EventModel> existingEvents,
  ) {
    final normalizedName = EventFormOptions.normalizePersonName(
      suggestion.name,
      eventType: suggestion.type,
    ).toLowerCase().trim();

    for (final event in existingEvents) {
      if (!EventDateUtils.occursOnDay(event.date, suggestion.date)) continue;

      final existingName = EventFormOptions.normalizePersonName(
        event.name,
        eventType: event.type,
      ).toLowerCase().trim();
      if (existingName == normalizedName ||
          existingName.contains(normalizedName) ||
          normalizedName.contains(existingName)) {
        return true;
      }
    }

    return false;
  }
}
