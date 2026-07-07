import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/events/repositories/event_repository.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_provider.g.dart';

@riverpod
class EventNotifier extends _$EventNotifier {
  @override
  Stream<List<EventModel>> build() =>
      ref.watch(eventRepositoryProvider).getAllEvents();

  Future<void> addEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).addEvent(event);
    await NotificationService.scheduleEventReminders(event);
  }

  Future<void> updateEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).updateEvent(event);
    await NotificationService.scheduleEventReminders(event);
  }

  Future<void> deleteEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).deleteEvent(event);
    await NotificationService.cancelEventReminders(event.id);
  }

  Future<void> deleteAllEvents(List<EventModel> events) async {
    for (final event in events) {
      await deleteEvent(event);
    }
  }
}
