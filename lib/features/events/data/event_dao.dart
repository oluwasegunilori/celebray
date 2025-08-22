import 'package:floor/floor.dart';
import '../models/event.dart';

@dao
abstract class EventDao {
  @Query('SELECT * FROM events ORDER BY date ASC')
  Stream<List<Event>> getAllEvents();

  @insert
  Future<void> insertEvent(Event event);

  @update
  Future<void> updateEvent(Event event);

  @delete
  Future<void> deleteEvent(Event event);
}
