// domain/entities/event.dart
import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String name;
  final String type;
  final DateTime date;
  final String relationship;
  final String sex;
  final int closeness;
  final List<String> memories;
  final String? imagePath;
  final String? generatedMessage;

  const EventModel({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.relationship,
    required this.sex,
    required this.closeness,
    this.memories = const [],
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
    sex,
    closeness,
    memories,
    imagePath,
    generatedMessage,
  ];
}
