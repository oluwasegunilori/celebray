import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:intl/intl.dart';

/// Generates personalized celebration messages.
/// Uses template-based generation; can be extended with a backend API.
class MessageGeneratorService {
  static const _tones = ['warm', 'funny', 'formal'];

  static List<String> get availableTones => _tones;

  static List<String> generateMessages(
    EventModel event, {
    String tone = 'warm',
  }) {
    final name = event.name.split(' ').first;
    final type = event.type.toLowerCase();
    final relationship = event.relationship.toLowerCase();
    final memory = event.memories.isNotEmpty ? event.memories.first : null;
    final daysUntil = EventDateUtils.daysUntilNext(event.date);

    switch (tone) {
      case 'funny':
        return _funnyMessages(name, type, relationship, memory, daysUntil);
      case 'formal':
        return _formalMessages(name, type, relationship, daysUntil);
      default:
        return _warmMessages(name, type, relationship, memory, daysUntil);
    }
  }

  static List<String> _warmMessages(
    String name,
    String type,
    String relationship,
    String? memory,
    int daysUntil,
  ) {
    final messages = <String>[
      "Happy $type, $name! 🎉 You're such an important $relationship to me. Wishing you a day filled with love and joy!",
      "Thinking of you today, $name! Hope your $type is as wonderful as you are. Cheers to many more celebrations together!",
    ];
    if (memory != null) {
      messages.add(
        "Happy $type, $name! I'll never forget when we $memory — here's to making more memories today! 💕",
      );
    }
    if (daysUntil == 0) {
      messages.insert(
        0,
        "Today's the day! Happy $type, $name! 🎂 Sending you all my love on your special day.",
      );
    }
    return messages.take(3).toList();
  }

  static List<String> _funnyMessages(
    String name,
    String type,
    String relationship,
    String? memory,
    int daysUntil,
  ) {
    return [
      "Happy $type, $name! 🎉 Another year older, another year wiser... or at least another year of great stories!",
      "It's $name's $type! Time to celebrate my favorite $relationship. Cake is mandatory, regrets are optional! 🎂",
      if (memory != null)
        "Happy $type! Remember $memory? Yeah, we need a repeat performance — but with more cake this time! 😄"
      else
        "Happy $type, $name! May your day be as awesome as you pretend to be humble! 😄",
    ];
  }

  static List<String> _formalMessages(
    String name,
    String type,
    String relationship,
    int daysUntil,
  ) {
    return [
      "Warmest wishes on your $type, $name. May this special day bring you happiness and fulfillment.",
      "Dear $name, please accept my sincere congratulations on your $type. Wishing you continued success and joy.",
      "Happy $type! It is always a pleasure to celebrate the milestones of valued $relationship like yours.",
    ];
  }

  static String shareText(EventModel event) {
    final next = EventDateUtils.nextOccurrence(event.date);
    final formatted = DateFormat('EEEE, MMMM d').format(next);
    final daysUntil = EventDateUtils.daysUntilNext(event.date);
    final countdown = daysUntil == 0
        ? "It's today!"
        : daysUntil == 1
            ? 'Tomorrow!'
            : 'In $daysUntil days';

    final buffer = StringBuffer()
      ..writeln("🎉 ${event.name}'s ${event.type}")
      ..writeln('📅 $formatted ($countdown)')
      ..writeln('💝 Relationship: ${event.relationship}');

    if (event.generatedMessage != null) {
      buffer.writeln('\n"${event.generatedMessage}"');
    }

    buffer.writeln('\n— Sent via Celebray');
    return buffer.toString();
  }
}
