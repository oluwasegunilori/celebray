import 'package:celebray/features/events/data/event_entity.dart';
import 'package:celebray/features/events/domain/event_model.dart';

/// Curated demo celebrations for App Store screenshots and integration tests.
class AppStoreDemoData {
  static List<EventModel> events({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime onDay(int dayOffset) => today.add(Duration(days: dayOffset));

    return [
      EventModel(
        id: 'demo-mom-birthday',
        name: 'Mom',
        type: 'Birthday',
        date: onDay(2),
        relationship: 'Mother',
        sex: 'Female',
        closeness: 5,
        memories: const [
          'Always saves me a slice of her caramel cake',
          'Calls every Sunday without fail',
        ],
      ),
      EventModel(
        id: 'demo-partner-anniversary',
        name: 'Jordan',
        type: 'Anniversary',
        date: onDay(9),
        relationship: 'Partner',
        sex: 'Female',
        closeness: 5,
        memories: const [
          'Our first trip to Lisbon',
          'Still laugh about the lost luggage',
        ],
        generatedMessage:
            'Happy anniversary, Jordan. Thank you for every ordinary day that feels like a gift.',
      ),
      EventModel(
        id: 'demo-alex-graduation',
        name: 'Alex',
        type: 'Graduation',
        date: onDay(16),
        relationship: 'Friend',
        sex: 'Male',
        closeness: 4,
        memories: const ['Study sessions that turned into late-night talks'],
      ),
      EventModel(
        id: 'demo-sarah-birthday',
        name: 'Sarah',
        type: 'Birthday',
        date: onDay(23),
        relationship: 'Sister',
        sex: 'Female',
        closeness: 4,
        memories: const ['Shared room, shared secrets'],
      ),
      EventModel(
        id: 'demo-dad-birthday',
        name: 'Dad',
        type: 'Birthday',
        date: onDay(-3),
        relationship: 'Father',
        sex: 'Male',
        closeness: 5,
        memories: const ['Taught me to ride a bike in one afternoon'],
      ),
    ];
  }

  static List<EventEntity> entities({DateTime? reference}) =>
      events(reference: reference)
          .map(EventEntity.fromDomain)
          .toList(growable: false);
}
