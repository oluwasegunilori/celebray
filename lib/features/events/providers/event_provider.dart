import 'package:celebray/features/events/data/event_repository.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/notifications/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_provider.g.dart';

@riverpod
class EventNotifier extends _$EventNotifier {
  @override
  Stream<List<EventModel>> build() =>
      ref.watch(eventRepositoryProvider).getAllEvents();

  Future<void> _syncSideEffects(EventModel? event, List<EventModel> all) async {
    if (event != null) {
      await NotificationService.scheduleEventReminders(event);
    }
    await UpcomingWidgetService.syncEvents(all);
  }

  Future<List<EventModel>> _currentEvents() async {
    return ref.read(eventRepositoryProvider).getAllEvents().first;
  }

  Future<void> addEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).addEvent(event);
    final all = await _currentEvents();
    await _syncSideEffects(event, all);
  }

  Future<void> updateEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).updateEvent(event);
    final all = await _currentEvents();
    await _syncSideEffects(event, all);
  }

  Future<void> deleteEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).deleteEvent(event);
    await NotificationService.cancelEventReminders(event.id);
    final all = await _currentEvents();
    await UpcomingWidgetService.syncEvents(all);
  }

  Future<void> deleteAllEvents(List<EventModel> events) async {
    for (final event in events) {
      await deleteEvent(event);
    }
  }
}
