import 'dart:convert';
import 'dart:io';

import 'package:celebray/core/constants/app_constants.dart';
import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/presentation/event_display_labels.dart';
import 'package:celebray/features/notifications/notification_payload.dart';
import 'package:celebray/features/notifications/reminder_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static const generateActionId = 'generate';
  static const shareActionId = 'share';
  static const snoozeActionId = 'snooze';
  static const reminderCategoryId = 'celebration_reminder';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init({
    required void Function(NotificationResponse response)
        onNotificationResponse,
  }) async {
    if (_initialized) return;

    tz.initializeTimeZones();

    final actions = [
      DarwinNotificationAction.plain(
        generateActionId,
        'Generate',
        options: {DarwinNotificationActionOption.foreground},
      ),
      DarwinNotificationAction.plain(
        shareActionId,
        'Share',
        options: {DarwinNotificationActionOption.foreground},
      ),
      DarwinNotificationAction.plain(
        snoozeActionId,
        'Snooze',
      ),
    ];
    final reminderCategory = DarwinNotificationCategory(
      reminderCategoryId,
      actions: actions,
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [reminderCategory],
    );

    await _plugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: onNotificationResponse,
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              AppConstants.notificationChannelId,
              AppConstants.notificationChannelName,
              description: AppConstants.notificationChannelDescription,
              importance: Importance.high,
            ),
          );
    }

    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId('group.com.shegz.celebray');
    }

    _initialized = true;
  }

  static Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    if (!enabled) {
      await _plugin.cancelAll();
    }
  }

  static Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }

    return true;
  }

  static int notificationId(String eventId, ReminderOffset offset) {
    return '$eventId-${offset.payloadKey}'.hashCode.abs() % 2147483647;
  }

  static DateTime? scheduledTimeFor({
    required DateTime nextOccurrence,
    required ReminderOffset offset,
    required ReminderPreferences prefs,
  }) {
    switch (offset) {
      case ReminderOffset.days7:
        final day = nextOccurrence.subtract(const Duration(days: 7));
        return DateTime(day.year, day.month, day.day, prefs.advanceReminderHour);
      case ReminderOffset.days3:
        final day = nextOccurrence.subtract(const Duration(days: 3));
        return DateTime(day.year, day.month, day.day, prefs.advanceReminderHour);
      case ReminderOffset.days1:
        final day = nextOccurrence.subtract(const Duration(days: 1));
        return DateTime(day.year, day.month, day.day, prefs.advanceReminderHour);
      case ReminderOffset.morningOf:
        return DateTime(
          nextOccurrence.year,
          nextOccurrence.month,
          nextOccurrence.day,
          prefs.morningOfHour,
        );
      case ReminderOffset.celebrationDay:
        return DateTime(
          nextOccurrence.year,
          nextOccurrence.month,
          nextOccurrence.day,
        );
    }
  }

  static Future<void> scheduleEventReminders(EventModel event) async {
    if (!await areNotificationsEnabled()) return;

    await cancelEventReminders(event.id);

    final prefs = await ReminderPreferences.load();
    final next = EventDateUtils.nextOccurrence(event.date);
    final now = DateTime.now();
    final hasSavedMessage = event.generatedMessage?.trim().isNotEmpty ?? false;

    for (final offset in ReminderOffset.values) {
      if (!prefs.isEnabled(offset)) continue;

      final when = scheduledTimeFor(
        nextOccurrence: next,
        offset: offset,
        prefs: prefs,
      );
      if (when == null || !when.isAfter(now)) continue;

      final title = EventDisplayLabels.reminderTitle(event, offset);
      final body = EventDisplayLabels.reminderBody(
        event,
        offset,
        hasSavedMessage: hasSavedMessage,
      );
      final payload = NotificationPayload(
        eventId: event.id,
        offset: offset,
      ).encode();

      await _plugin.zonedSchedule(
        notificationId(event.id, offset),
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            actions: const [
              AndroidNotificationAction(
                generateActionId,
                'Generate',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                shareActionId,
                'Share',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                snoozeActionId,
                'Snooze',
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            categoryIdentifier: reminderCategoryId,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  static Future<void> snoozeReminder({
    required EventModel event,
    ReminderOffset? offset,
  }) async {
    if (!await areNotificationsEnabled()) return;

    final prefs = await ReminderPreferences.load();
    final snoozeAt = DateTime.now().add(const Duration(days: 1));
    final when = DateTime(
      snoozeAt.year,
      snoozeAt.month,
      snoozeAt.day,
      prefs.morningOfHour,
    );
    if (!when.isAfter(DateTime.now())) return;

    final kind = offset ?? ReminderOffset.morningOf;
    final hasSavedMessage = event.generatedMessage?.trim().isNotEmpty ?? false;
    final payload = NotificationPayload(eventId: event.id, offset: kind).encode();
    final snoozeId = notificationId('${event.id}-snooze-${when.millisecondsSinceEpoch}', kind);

    await _plugin.zonedSchedule(
      snoozeId,
      EventDisplayLabels.reminderTitle(event, kind),
      EventDisplayLabels.reminderBody(
        event,
        kind,
        hasSavedMessage: hasSavedMessage,
      ),
      tz.TZDateTime.from(when, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          actions: const [
            AndroidNotificationAction(
              generateActionId,
              'Generate',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              shareActionId,
              'Share',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: reminderCategoryId,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  static Future<void> cancelEventReminders(String eventId) async {
    for (final offset in ReminderOffset.values) {
      await _plugin.cancel(notificationId(eventId, offset));
    }
  }

  static Future<void> rescheduleAll(List<EventModel> events) async {
    if (!await areNotificationsEnabled()) return;
    await _plugin.cancelAll();
    for (final event in events) {
      await scheduleEventReminders(event);
    }
  }
}

/// Syncs upcoming celebrations to the home screen widget.
class UpcomingWidgetService {
  UpcomingWidgetService._();

  static const androidProviderName = 'CelebrayWidgetProvider';

  static Future<void> syncEvents(List<EventModel> events) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final sorted = [...events]
      ..sort(
        (a, b) => EventDateUtils.daysUntilNext(a.date)
            .compareTo(EventDateUtils.daysUntilNext(b.date)),
      );

    final upcoming = sorted.take(3).map((event) {
      final labels = EventDisplayLabels.from(event);
      final days = EventDateUtils.daysUntilNext(event.date);
      return {
        'title': labels.title,
        'type': event.type,
        'daysUntil': days,
        'daysLabel': days == 0
            ? 'Today'
            : days == 1
                ? 'Tomorrow'
                : 'In $days days',
      };
    }).toList();

    await HomeWidget.saveWidgetData('upcoming_json', jsonEncode(upcoming));
    await HomeWidget.saveWidgetData(
      'widget_title',
      upcoming.isEmpty ? 'No upcoming celebrations' : 'Next up',
    );

    try {
      await HomeWidget.updateWidget(
        androidName: androidProviderName,
        iOSName: 'CelebrayWidget',
      );
    } catch (_) {
      // Widget extension may not be installed yet on iOS.
    }
  }
}
