import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/messages/ai_message_api.dart';
import 'package:celebray/features/messages/message_generation_result.dart';
import 'package:celebray/features/messages/message_template_generator.dart';
import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Generates personalized celebration messages via AI with template fallback.
class MessageGeneratorService {
  static const _tones = ['warm', 'funny', 'formal'];

  static List<String> get availableTones => _tones;

  static Future<MessageGenerationResult> generateMessages(
    EventModel event, {
    String tone = 'warm',
  }) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return MessageGenerationResult(
        messages: MessageTemplateGenerator.generate(event, tone: tone),
        source: MessageGenerationSource.template,
        notice: 'Sign in to unlock AI-powered messages.',
      );
    }

    try {
      final messages = await AiMessageApi.generateMessages(
        event: event,
        tone: tone,
      );
      return MessageGenerationResult(
        messages: messages,
        source: MessageGenerationSource.ai,
      );
    } on AiMessageException catch (error) {
      return MessageGenerationResult(
        messages: MessageTemplateGenerator.generate(event, tone: tone),
        source: MessageGenerationSource.template,
        notice: error.message,
      );
    } catch (_) {
      return MessageGenerationResult(
        messages: MessageTemplateGenerator.generate(event, tone: tone),
        source: MessageGenerationSource.template,
        notice: 'AI is unavailable. Showing template messages instead.',
      );
    }
  }

  static Future<MessageGenerationResult> touchUpMessage({
    required EventModel event,
    required String currentMessage,
    String instructions = '',
    String tone = 'warm',
  }) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return MessageGenerationResult(
        messages: MessageTemplateGenerator.touchUp(
          event: event,
          currentMessage: currentMessage,
          instructions: instructions,
          tone: tone,
        ),
        source: MessageGenerationSource.template,
        notice: 'Sign in to unlock AI touch-ups.',
      );
    }

    try {
      final messages = await AiMessageApi.touchUpMessage(
        event: event,
        currentMessage: currentMessage,
        instructions: instructions,
      );
      return MessageGenerationResult(
        messages: messages,
        source: MessageGenerationSource.ai,
      );
    } on AiMessageException catch (error) {
      if (error.code == 'content_refused') {
        return MessageGenerationResult(
          messages: const [],
          source: MessageGenerationSource.template,
          notice: error.message,
          refused: true,
        );
      }
      return MessageGenerationResult(
        messages: MessageTemplateGenerator.touchUp(
          event: event,
          currentMessage: currentMessage,
          instructions: instructions,
          tone: tone,
        ),
        source: MessageGenerationSource.template,
        notice: error.message,
      );
    } catch (_) {
      return MessageGenerationResult(
        messages: MessageTemplateGenerator.touchUp(
          event: event,
          currentMessage: currentMessage,
          instructions: instructions,
          tone: tone,
        ),
        source: MessageGenerationSource.template,
        notice: 'AI is unavailable. Showing template suggestions instead.',
      );
    }
  }

  static String shareMessageFor(EventModel event) {
    final saved = event.generatedMessage?.trim();
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    return MessageTemplateGenerator.generate(event).first;
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
