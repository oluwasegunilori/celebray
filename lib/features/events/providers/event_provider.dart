import 'package:celebray/features/events/models/event.dart';

import 'package:celebray/features/events/repositories/event_repository.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_provider.g.dart';

@riverpod
class EventNotifier extends _$EventNotifier {
  @override
  Stream<List<Event>> build() {
    return ref.watch(eventRepositoryProvider).getAllEvents();
  }

  Future<void> addEvent(Event event) async {
    await ref.read(eventRepositoryProvider).addEvent(event);
  }

  Future<void> deleteEvent(Event event) async {
    await ref.read(eventRepositoryProvider).deleteEvent(event);
  }
}
