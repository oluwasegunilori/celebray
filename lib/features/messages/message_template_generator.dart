import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:celebray/features/events/domain/event_model.dart';

/// Local template-based messages used as fallback when AI is unavailable.
class MessageTemplateGenerator {
  static List<String> generate(
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

  static List<String> touchUp({
    required EventModel event,
    required String currentMessage,
    String instructions = '',
    String tone = 'warm',
  }) {
    final notes = instructions.trim().toLowerCase();
    final variants = <String>[];

    variants.add(_applyInstructions(currentMessage, notes, event));

    if (notes.contains('short') || notes.contains('brief')) {
      variants.add(_shortenMessage(currentMessage));
    }
    if (notes.contains('funny') ||
        notes.contains('humor') ||
        notes.contains('joke')) {
      variants.add(_shiftTone(currentMessage, event, 'funny'));
    }
    if (notes.contains('formal') || notes.contains('professional')) {
      variants.add(_shiftTone(currentMessage, event, 'formal'));
    }
    if (notes.contains('warm') ||
        notes.contains('heartfelt') ||
        notes.contains('sweet')) {
      variants.add(_shiftTone(currentMessage, event, 'warm'));
    }

    if (variants.length < 2) {
      variants.add(_polishMessage(currentMessage));
    }

    if (notes.isEmpty && variants.length < 3) {
      variants.add(generate(event, tone: tone).first);
    }

    return _uniqueMessages(variants).take(3).toList();
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

  static List<String> _uniqueMessages(List<String> messages) {
    final seen = <String>{};
    final unique = <String>[];
    for (final message in messages) {
      final trimmed = message.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) continue;
      seen.add(trimmed);
      unique.add(trimmed);
    }
    return unique;
  }

  static String _applyInstructions(
    String message,
    String notes,
    EventModel event,
  ) {
    if (notes.isEmpty) return _polishMessage(message);

    final name = event.name.split(' ').first;
    var updated = message;

    if (notes.contains('emoji')) {
      if (!updated.contains('🎉')) updated = '🎉 $updated';
      if (!updated.contains('❤')) updated = '$updated ❤️';
    }
    if (notes.contains('exclamation') || notes.contains('excited')) {
      updated = updated.endsWith('!') ? updated : '$updated!';
    }
    if (notes.contains('name') && name.isNotEmpty && !updated.contains(name)) {
      updated = '$name, $updated';
    }
    if (notes.contains('memory') && event.memories.isNotEmpty) {
      updated =
          '${updated.trim()} I still smile thinking about ${event.memories.first}.';
    }

    return _polishMessage(updated);
  }

  static String _shortenMessage(String message) {
    final sentence = message.split(RegExp(r'[.!?]')).first.trim();
    if (sentence.isEmpty) return message;
    return sentence.endsWith('!') ? sentence : '$sentence!';
  }

  static String _shiftTone(String message, EventModel event, String tone) {
    final fresh = generate(event, tone: tone).first;
    if (message.length > fresh.length + 20) {
      return fresh;
    }
    return '$fresh ${message.trim()}'.trim();
  }

  static String _polishMessage(String message) {
    var polished = message.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (polished.isEmpty) return message;
    polished = polished[0].toUpperCase() + polished.substring(1);
    if (!RegExp(r'[.!?]$').hasMatch(polished)) {
      polished = '$polished.';
    }
    return polished;
  }
}
