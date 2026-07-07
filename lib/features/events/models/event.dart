import 'package:celebray/features/reminders/domain/event_model.dart';

class EventEntity {
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

  const EventEntity({
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

  EventModel toDomain() => EventModel(
        id: id,
        name: name,
        type: type,
        date: date,
        relationship: relationship,
        sex: sex,
        closeness: closeness,
        memories: memories,
        imagePath: imagePath,
        generatedMessage: generatedMessage,
      );

  factory EventEntity.fromDomain(EventModel event) => EventEntity(
        id: event.id,
        name: event.name,
        type: event.type,
        date: event.date,
        relationship: event.relationship,
        sex: event.sex,
        closeness: event.closeness,
        memories: event.memories,
        imagePath: event.imagePath,
        generatedMessage: event.generatedMessage,
      );
}
