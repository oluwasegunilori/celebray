
import 'package:celebray/features/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database_provider.g.dart'; 

@riverpod
AppDatabase appDatabase(Ref ref) {
  //to be replased in main.dart
  //with the actual database initialization logic
  //e.g., return $FloorAppDatabase.databaseBuilder('app_database.db').build();
  throw UnimplementedError('Database initialization not implemented');
}
