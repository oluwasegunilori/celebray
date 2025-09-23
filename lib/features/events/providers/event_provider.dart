
import 'package:celebray/features/events/repositories/event_repository.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_provider.g.dart';

@riverpod
class EventNotifier extends _$EventNotifier {
  @override
  Stream<List<EventModel>> build() {
    return ref.watch(eventRepositoryProvider).getAllEvents();
  }

  Future<void> addEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).addEvent(event);
  }

  Future<void> deleteEvent(EventModel event) async {
    await ref.read(eventRepositoryProvider).deleteEvent(event);
  }
}
