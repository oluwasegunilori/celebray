import 'package:floor/floor.dart';
import '../models/event.dart';

@dao
abstract class EventDao {
  @Query('SELECT * FROM events ORDER BY date ASC')
  Stream<List<EventEntity>> getAllEvents();

  @insert
  Future<void> insertEvent(EventEntity event);

  @update
  Future<void> updateEvent(EventEntity event);

  @delete
  Future<void> deleteEvent(EventEntity event);
}
