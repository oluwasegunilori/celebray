// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  EventDao? _eventDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `events` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `type` TEXT NOT NULL, `date` INTEGER NOT NULL, `relationship` TEXT NOT NULL, `sex` TEXT NOT NULL, `closeness` INTEGER NOT NULL, `memories` TEXT NOT NULL, `imagePath` TEXT, `generatedMessage` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  EventDao get eventDao {
    return _eventDaoInstance ??= _$EventDao(database, changeListener);
  }
}

class _$EventDao extends EventDao {
  _$EventDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _eventEntityInsertionAdapter = InsertionAdapter(
            database,
            'events',
            (EventEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'date': _dateTimeConverter.encode(item.date),
                  'relationship': item.relationship,
                  'sex': item.sex,
                  'closeness': item.closeness,
                  'memories': _stringListConverter.encode(item.memories),
                  'imagePath': item.imagePath,
                  'generatedMessage': item.generatedMessage
                },
            changeListener),
        _eventEntityUpdateAdapter = UpdateAdapter(
            database,
            'events',
            ['id'],
            (EventEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'date': _dateTimeConverter.encode(item.date),
                  'relationship': item.relationship,
                  'sex': item.sex,
                  'closeness': item.closeness,
                  'memories': _stringListConverter.encode(item.memories),
                  'imagePath': item.imagePath,
                  'generatedMessage': item.generatedMessage
                },
            changeListener),
        _eventEntityDeletionAdapter = DeletionAdapter(
            database,
            'events',
            ['id'],
            (EventEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'date': _dateTimeConverter.encode(item.date),
                  'relationship': item.relationship,
                  'sex': item.sex,
                  'closeness': item.closeness,
                  'memories': _stringListConverter.encode(item.memories),
                  'imagePath': item.imagePath,
                  'generatedMessage': item.generatedMessage
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EventEntity> _eventEntityInsertionAdapter;

  final UpdateAdapter<EventEntity> _eventEntityUpdateAdapter;

  final DeletionAdapter<EventEntity> _eventEntityDeletionAdapter;

  @override
  Stream<List<EventEntity>> getAllEvents() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM events ORDER BY date ASC',
        mapper: (Map<String, Object?> row) => EventEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            date: _dateTimeConverter.decode(row['date'] as int),
            relationship: row['relationship'] as String,
            sex: row['sex'] as String,
            closeness: row['closeness'] as int,
            memories: _stringListConverter.decode(row['memories'] as String),
            imagePath: row['imagePath'] as String?,
            generatedMessage: row['generatedMessage'] as String?),
        queryableName: 'events',
        isView: false);
  }

  @override
  Future<void> insertEvent(EventEntity event) async {
    await _eventEntityInsertionAdapter.insert(event, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
    await _eventEntityUpdateAdapter.update(event, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEvent(EventEntity event) async {
    await _eventEntityDeletionAdapter.delete(event);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _stringListConverter = StringListConverter();
