import 'package:celebray/core/database/app_database.dart';
import 'package:celebray/core/database/app_database_provider.dart';
import 'package:celebray/features/events/data/event_entity.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_repository.g.dart';

class EventRepository {
  final AppDatabase db;

  EventRepository(this.db);

  Stream<List<EventModel>> getAllEvents() => db.watchAllEvents();

  Future<void> addEvent(EventModel event) =>
      db.insertEvent(EventEntity.fromDomain(event));

  Future<void> updateEvent(EventModel event) =>
      db.updateEvent(EventEntity.fromDomain(event));

  Future<void> deleteEvent(EventModel event) => db.deleteEvent(event.id);
}

@riverpod
EventRepository eventRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return EventRepository(db);
}
