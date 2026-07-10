import 'package:celebray/core/database/app_database.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/generator/presentation/edit_message_screen.dart';
import 'package:celebray/features/generator/presentation/generator_screen.dart';
import 'package:celebray/features/notifications/notification_payload.dart';
import 'package:celebray/features/notifications/notification_service.dart';
import 'package:celebray/features/notifications/reminder_preferences.dart';
import 'package:celebray/features/sharing/widgets/share_event_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Routes notification taps and actions to generator, share, and snooze flows.
class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static AppDatabase? _database;
  static String? _pendingEventId;
  static ReminderOffset? _pendingOffset;
  static bool _pendingOpenShare = false;
  static bool _pendingOpenGenerate = false;

  static void bindDatabase(AppDatabase database) {
    _database = database;
  }

  static Future<void> captureColdStartLaunch() async {
    final details = await NotificationService.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return;

    final response = details!.notificationResponse;
    if (response == null) return;

    await _handleResponse(response, navigate: false);
  }

  static void handleNotificationResponse(NotificationResponse response) {
    _handleResponse(response, navigate: true);
  }

  static Future<void> _handleResponse(
    NotificationResponse response, {
    required bool navigate,
  }) async {
    final payload = NotificationPayload.decode(response.payload);
    if (payload == null) return;

    if (response.actionId == NotificationService.snoozeActionId) {
      final event = await _database?.getEventById(payload.eventId);
      if (event != null) {
        await NotificationService.snoozeReminder(
          event: event,
          offset: payload.offset,
        );
      }
      return;
    }

    _pendingEventId = payload.eventId;
    _pendingOffset = payload.offset;
    _pendingOpenShare = response.actionId == NotificationService.shareActionId;
    _pendingOpenGenerate =
        response.actionId == NotificationService.generateActionId;

    if (navigate) {
      await consumePendingNavigation();
    }
  }

  static Future<void> consumePendingNavigation() async {
    final eventId = _pendingEventId;
    if (eventId == null || _database == null) return;

    _pendingEventId = null;
    final offset = _pendingOffset;
    final openShare = _pendingOpenShare;
    final openGenerate = _pendingOpenGenerate;
    _pendingOffset = null;
    _pendingOpenShare = false;
    _pendingOpenGenerate = false;

    final event = await _database!.getEventById(eventId);
    if (event == null) return;

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _pendingEventId = eventId;
      _pendingOffset = offset;
      _pendingOpenShare = openShare;
      _pendingOpenGenerate = openGenerate;
      return;
    }

    await _openCelebration(
      context,
      event,
      offset: offset,
      openShare: openShare,
      openGenerate: openGenerate,
    );
  }

  static Future<void> _openCelebration(
    BuildContext context,
    EventModel event, {
    ReminderOffset? offset,
    required bool openShare,
    required bool openGenerate,
  }) async {
    if (openShare) {
      if (event.hasGeneratedMessage) {
        ShareEventSheet.show(context, event: event);
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GeneratorScreen(initialEvent: event),
          ),
        );
      }
      return;
    }

    if (openGenerate) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GeneratorScreen(initialEvent: event),
        ),
      );
      return;
    }

    final isCelebrationDay =
        offset == null || offset == ReminderOffset.celebrationDay;
    if (isCelebrationDay && event.hasGeneratedMessage) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditMessageScreen(event: event),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GeneratorScreen(initialEvent: event),
      ),
    );
  }
}
