import 'package:celebray/features/core/db/app_database_provider.dart';
import 'package:celebray/features/events/models/event.dart';
import 'package:celebray/features/core/db/app_database.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_repository.g.dart';

class EventRepository {
  final AppDatabase db; // Floor database instance

  EventRepository(this.db);

  Stream<List<EventModel>> getAllEvents() => db.eventDao.getAllEvents().map(
        (entities) => entities.map((e) => e.toDomain()).toList(),
      );

  Future<void> addEvent(EventModel event) => db.eventDao.insertEvent(EventEntity.fromDomain(event));

  Future<void> deleteEvent(EventModel event) => db.eventDao.deleteEvent(EventEntity.fromDomain(event));
}

@riverpod
EventRepository eventRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return EventRepository(db);
}
