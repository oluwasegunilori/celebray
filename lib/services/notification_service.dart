import 'dart:io';

import 'package:celebray/constants/app_constants.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/utils/event_date_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
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

    _initialized = true;
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

  static Future<int> getReminderDaysBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('reminder_days_before') ??
        AppConstants.defaultReminderDaysBefore;
  }

  static Future<void> setReminderDaysBefore(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_days_before', days);
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

  static int _notificationId(String eventId, String suffix) {
    return '$eventId-$suffix'.hashCode.abs() % 2147483647;
  }

  static Future<void> scheduleEventReminders(EventModel event) async {
    if (!await areNotificationsEnabled()) return;

    await cancelEventReminders(event.id);

    final daysBefore = await getReminderDaysBefore();
    final next = EventDateUtils.nextOccurrence(event.date);
    final now = DateTime.now();

    final schedules = <({DateTime when, String title, String body, String suffix})>[
      (
        when: next.subtract(Duration(days: daysBefore)),
        title: 'Coming up in $daysBefore days',
        body: "${event.name}'s ${event.type} is on ${_formatDate(next)}.",
        suffix: 'advance',
      ),
      (
        when: DateTime(next.year, next.month, next.day, 9),
        title: "Today's the day! 🎉",
        body: "It's ${event.name}'s ${event.type}! Don't forget to celebrate.",
        suffix: 'dayof',
      ),
    ];

    for (final schedule in schedules) {
      if (!schedule.when.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        id: _notificationId(event.id, schedule.suffix),
        scheduledDate: tz.TZDateTime.from(schedule.when, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: schedule.title,
        body: schedule.body,
      );
    }
  }

  static Future<void> cancelEventReminders(String eventId) async {
    await _plugin.cancel(id: _notificationId(eventId, 'advance'));
    await _plugin.cancel(id: _notificationId(eventId, 'dayof'));
  }

  static Future<void> rescheduleAll(List<EventModel> events) async {
    if (!await areNotificationsEnabled()) return;
    await _plugin.cancelAll();
    for (final event in events) {
      await scheduleEventReminders(event);
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
