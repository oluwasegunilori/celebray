import 'dart:io';

import 'package:celebray/core/constants/app_constants.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static const shareActionId = 'share';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init({
    required void Function(NotificationResponse response)
        onNotificationResponse,
  }) async {
    if (_initialized) return;

    tz.initializeTimeZones();

    final shareAction = DarwinNotificationAction.plain(
      shareActionId,
      'Share',
      options: {DarwinNotificationActionOption.foreground},
    );
    final celebrationCategory = DarwinNotificationCategory(
      'celebration_day',
      actions: [shareAction],
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [celebrationCategory],
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

  static int _notificationId(String eventId) {
    return '$eventId-celebration'.hashCode.abs() % 2147483647;
  }

  static Future<void> scheduleEventReminders(EventModel event) async {
    if (!await areNotificationsEnabled()) return;

    await cancelEventReminders(event.id);

    final next = EventDateUtils.nextOccurrence(event.date);
    final when = DateTime(next.year, next.month, next.day);
    final now = DateTime.now();

    if (!when.isAfter(now)) return;

    final label = event.name.isNotEmpty ? event.name : event.type;
    final title = "🎉 It's $label's ${event.type} today!";
    final body = event.generatedMessage?.trim().isNotEmpty ?? false
        ? 'Tap to celebrate and share your message.'
        : 'Tap to open details and share your celebration.';

    await _plugin.zonedSchedule(
      _notificationId(event.id),
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
              shareActionId,
              'Share',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'celebration_day',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: event.id,
    );
  }

  static Future<void> cancelEventReminders(String eventId) async {
    await _plugin.cancel(_notificationId(eventId));
  }

  static Future<void> rescheduleAll(List<EventModel> events) async {
    if (!await areNotificationsEnabled()) return;
    await _plugin.cancelAll();
    for (final event in events) {
      await scheduleEventReminders(event);
    }
  }
}
