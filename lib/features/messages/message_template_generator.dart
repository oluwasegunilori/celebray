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
      case 'prayerful':
        return _prayerfulMessages(name, type, relationship, memory, daysUntil);
      case 'romantic':
        return _romanticMessages(name, type, relationship, memory, daysUntil);
      case 'casual':
        return _casualMessages(name, type, relationship, memory, daysUntil);
      case 'brief':
        return _briefMessages(name, type, relationship, daysUntil);
      case 'heartfelt':
        return _heartfeltMessages(name, type, relationship, memory, daysUntil);
      case 'poetic':
        return _poeticMessages(name, type, relationship, daysUntil);
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

  static List<String> _prayerfulMessages(
    String name,
    String type,
    String relationship,
    String? memory,
    int daysUntil,
  ) {
    final messages = <String>[
      "May you be blessed on your $type, $name. Grateful for you and praying for joy, peace, and good things ahead.",
      "Thinking of you with love today, $name. May this $type be filled with grace and the warmth of people who care about you.",
    ];
    if (memory != null) {
      messages.add(
        "Happy $type, $name. Thankful for moments like when we $memory — praying this year brings you even more to cherish.",
      );
    } else {
      messages.add(
        "On your $type, $name, I pray you feel surrounded by love and reminded how deeply you are valued.",
      );
    }
    if (daysUntil == 0) {
      messages.insert(
        0,
        "Today is your $type, $name. May God bless this day and all that is ahead for you.",
      );
    }
    return messages.take(3).toList();
  }

  static List<String> _romanticMessages(
    String name,
    String type,
    String relationship,
    String? memory,
    int daysUntil,
  ) {
    return [
      "Happy $type, my love. You make ordinary days feel like celebrations — today is all about you, $name. 💕",
      "To my favorite person: happy $type! Grateful every day that you're my $relationship.",
      if (memory != null)
        "Happy $type, $name. From $memory to today — I fall for you a little more each time. ❤️"
      else
        "Happy $type, $name. Here's to you, to us, and to every beautiful moment still ahead.",
    ];
  }

  static List<String> _casualMessages(
    String name,
    String type,
    String relationship,
    String? memory,
    int daysUntil,
  ) {
    return [
      "Happy $type, $name! Hope it's a good one 🎉",
      "It's your $type — go enjoy it, $name. You deserve a great day.",
      if (memory != null)
        "Happy $type! Still think about $memory — we need a repeat soon, $name."
      else
        "Hey $name, happy $type! Catch up soon?",
    ];
  }

  static List<String> _briefMessages(
    String name,
    String type,
    String relationship,
    int daysUntil,
  ) {
    return [
      "Happy $type, $name! 🎉",
      "Wishing you the best $type, $name!",
      if (daysUntil == 0) "Today's your day, $name — happy $type!" else "Happy $type, $name!",
    ];
  }

  static List<String> _heartfeltMessages(
    String name,
    String type,
    String relationship,
    String? memory,
    int daysUntil,
  ) {
    return [
      "Happy $type, $name. You mean more to me than I say out loud — I'm lucky to have you in my life.",
      "On your $type, $name, I want you to know how deeply you're loved and appreciated.",
      if (memory != null)
        "Happy $type, $name. I'll always cherish $memory — thank you for being you."
      else
        "Happy $type, $name. You bring so much light to the people around you.",
    ];
  }

  static List<String> _poeticMessages(
    String name,
    String type,
    String relationship,
    int daysUntil,
  ) {
    return [
      "Happy $type, $name — may this day unfold like a small gift, one moment of joy at a time.",
      "On your $type, $name, the calendar marks a date; the heart marks someone irreplaceable.",
      "Happy $type, $name. Another year, another chapter — may yours be written in kindness and light.",
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
