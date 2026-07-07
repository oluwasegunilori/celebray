import 'package:celebray/core/database/app_database.dart';
import 'package:celebray/features/events/domain/event_actions.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/generator/presentation/edit_message_screen.dart';
import 'package:celebray/features/generator/presentation/generator_screen.dart';
import 'package:celebray/features/notifications/notification_service.dart';
import 'package:celebray/features/reminders/presentation/add_event_sheet.dart';
import 'package:celebray/features/reminders/presentation/event_detail_sheet.dart';
import 'package:celebray/features/sharing/widgets/share_event_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Routes notification taps to event details and share flows.
class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static AppDatabase? _database;
  static String? _pendingEventId;
  static bool _pendingOpenShare = false;

  static void bindDatabase(AppDatabase database) {
    _database = database;
  }

  static Future<void> captureColdStartLaunch() async {
    final details = await NotificationService.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return;

    final response = details!.notificationResponse;
    if (response == null) return;

    _queueFromResponse(response);
  }

  static void handleNotificationResponse(NotificationResponse response) {
    _queueFromResponse(response);
    consumePendingNavigation();
  }

  static void _queueFromResponse(NotificationResponse response) {
    final eventId = response.payload;
    if (eventId == null || eventId.isEmpty) return;

    _pendingEventId = eventId;
    _pendingOpenShare = response.actionId == NotificationService.shareActionId;
  }

  static Future<void> consumePendingNavigation() async {
    final eventId = _pendingEventId;
    if (eventId == null || _database == null) return;

    _pendingEventId = null;
    final openShare = _pendingOpenShare;
    _pendingOpenShare = false;

    final event = await _database!.getEventById(eventId);
    if (event == null) return;

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _pendingEventId = eventId;
      _pendingOpenShare = openShare;
      return;
    }

    await _openCelebration(context, event, openShare: openShare);
  }

  static Future<void> _openCelebration(
    BuildContext context,
    EventModel event, {
    required bool openShare,
  }) async {
    EventDetailSheet.show(
      context,
      event: event,
      openShareOnOpen: openShare,
      onAction: (action) => _handleAction(context, action, event),
    );
  }

  static void _handleAction(
    BuildContext context,
    EventAction action,
    EventModel event,
  ) {
    switch (action) {
      case ShareEvent():
        ShareEventSheet.show(context, event: event);
      case EditEvent(:var event):
        showAddEventSheet(context, event: event);
      case GenerateMessage():
        final hasMessage = event.generatedMessage?.trim().isNotEmpty ?? false;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => hasMessage
                ? EditMessageScreen(event: event)
                : GeneratorScreen(initialEvent: event),
          ),
        );
      case ViewEvent():
      case DeleteEvent():
        break;
    }
  }
}
