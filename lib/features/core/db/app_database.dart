import 'dart:async';

import 'package:celebray/utils/db_converters.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../../events/models/event.dart';
import '../../events/data/event_dao.dart';

part 'app_database.g.dart'; // generated code

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [EventEntity])
abstract class AppDatabase extends FloorDatabase {
  EventDao get eventDao;
}
