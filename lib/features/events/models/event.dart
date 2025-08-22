import 'package:celebray/utils/db_converters.dart';
import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'events')
class Event extends Equatable {
  @PrimaryKey()
  final String id;

  final String name;
  final String type; // birthday / anniversary
  @TypeConverters([DateTimeConverter])
  final DateTime date;
  final String relationship;
  final String? memory;
  final String? imagePath;
  final String? generatedMessage;

  const Event({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.relationship,
    this.memory,
    this.imagePath,
    this.generatedMessage,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    date,
    relationship,
    memory,
    imagePath,
    generatedMessage,
  ];
}
