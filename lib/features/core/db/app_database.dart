import 'dart:async';
import 'dart:convert';

import 'package:celebray/features/events/models/event.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase(this._db);

  final Database _db;
  final _eventsController = StreamController<List<EventModel>>.broadcast();

  static const _tableName = 'events';

  static Future<AppDatabase> open({String fileName = 'app_database.db'}) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            date INTEGER NOT NULL,
            relationship TEXT NOT NULL,
            sex TEXT NOT NULL,
            closeness INTEGER NOT NULL,
            memories TEXT NOT NULL,
            imagePath TEXT,
            generatedMessage TEXT
          )
        ''');
      },
    );

    return AppDatabase(database);
  }

  Stream<List<EventModel>> watchAllEvents() async* {
    yield await _readAllEvents();
    await for (final _ in _eventsController.stream) {
      yield await _readAllEvents();
    }
  }

  Future<List<EventModel>> _readAllEvents() async {
    final rows = await _db.query(
      _tableName,
      orderBy: 'date ASC',
    );

    return rows.map(_rowToEntity).map((event) => event.toDomain()).toList();
  }

  Future<void> _notifyListeners() async {
    if (!_eventsController.isClosed) {
      _eventsController.add(await _readAllEvents());
    }
  }

  Future<void> insertEvent(EventEntity event) async {
    await _db.insert(
      _tableName,
      _entityToRow(event),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notifyListeners();
  }

  Future<void> updateEvent(EventEntity event) async {
    await _db.update(
      _tableName,
      _entityToRow(event),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    await _notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _notifyListeners();
  }

  EventEntity _rowToEntity(Map<String, Object?> row) {
    final memoriesRaw = row['memories'] as String? ?? '[]';
    final memories = List<String>.from(json.decode(memoriesRaw) as List);

    return EventEntity(
      id: row['id'] as String,
      name: row['name'] as String,
      type: row['type'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(row['date'] as int),
      relationship: row['relationship'] as String,
      sex: row['sex'] as String,
      closeness: row['closeness'] as int,
      memories: memories,
      imagePath: row['imagePath'] as String?,
      generatedMessage: row['generatedMessage'] as String?,
    );
  }

  Map<String, Object?> _entityToRow(EventEntity event) {
    return {
      'id': event.id,
      'name': event.name,
      'type': event.type,
      'date': event.date.millisecondsSinceEpoch,
      'relationship': event.relationship,
      'sex': event.sex,
      'closeness': event.closeness,
      'memories': json.encode(event.memories),
      'imagePath': event.imagePath,
      'generatedMessage': event.generatedMessage,
    };
  }
}
