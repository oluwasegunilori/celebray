import 'package:celebray/features/core/db/app_database_provider.dart';
import 'package:celebray/features/events/models/event.dart';
import 'package:celebray/features/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_repository.g.dart';

class EventRepository {
  final AppDatabase db; // Floor database instance

  EventRepository(this.db);

  Stream<List<Event>> getAllEvents() => db.eventDao.getAllEvents();

  Future<void> addEvent(Event event) => db.eventDao.insertEvent(event);

  Future<void> deleteEvent(Event event) => db.eventDao.deleteEvent(event);
}

@riverpod
EventRepository eventRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return EventRepository(db);
}
