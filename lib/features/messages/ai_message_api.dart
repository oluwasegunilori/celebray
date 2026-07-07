import 'dart:convert';

import 'package:celebray/core/constants/app_constants.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AiMessageException implements Exception {
  final String code;
  final String message;

  const AiMessageException({required this.code, required this.message});

  @override
  String toString() => message;
}

class AiMessageApi {
  AiMessageApi._();

  static Future<List<String>> generateMessages({
    required EventModel event,
    required String tone,
  }) async {
    final body = _eventPayload(event, tone: tone);
    return _postMessages('generateMessages', body);
  }

  static Future<List<String>> touchUpMessage({
    required EventModel event,
    required String currentMessage,
    required String instructions,
  }) async {
    final body = {
      ..._eventPayload(event),
      'currentMessage': currentMessage,
      'instructions': instructions,
    };
    return _postMessages('touchUpMessage', body);
  }

  static Map<String, dynamic> _eventPayload(
    EventModel event, {
    String? tone,
  }) {
    return {
      'name': event.name,
      'type': event.type,
      'relationship': event.relationship,
      'sex': event.sex,
      'closeness': event.closeness,
      'memories': event.memories,
      'faithContext': event.faithContext,
      ?'tone': tone,
    };
  }

  static Future<List<String>> _postMessages(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const AiMessageException(
        code: 'unauthorized',
        message: 'Sign in to use AI message generation.',
      );
    }

    final token = await user.getIdToken();
    final uri = Uri.parse('${AppConstants.aiFunctionsBaseUrl}/$functionName');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    Map<String, dynamic>? payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      payload = null;
    }

    if (response.statusCode == 401) {
      throw AiMessageException(
        code: 'unauthorized',
        message: payload?['message'] as String? ??
            'Sign in to use AI message generation.',
      );
    }

    if (response.statusCode == 429) {
      final limit = payload?['limit'] as int? ??
          (AiAuthService.isGuest
              ? AppConstants.aiAnonymousDailyLimit
              : AppConstants.aiDailyLimit);
      final upgradeHint = limit <= AppConstants.aiAnonymousDailyLimit
          ? ' Sign in for ${AppConstants.aiDailyLimit}/day.'
          : ' Try again tomorrow.';
      throw AiMessageException(
        code: 'rate_limited',
        message: 'Daily AI limit reached ($limit/day).$upgradeHint',
      );
    }

    if (response.statusCode == 422) {
      throw AiMessageException(
        code: payload?['error'] as String? ?? 'content_refused',
        message: payload?['message'] as String? ??
            "This request can't be processed. Celebray only helps write celebration messages.",
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiMessageException(
        code: 'unavailable',
        message: payload?['message'] as String? ??
            'AI is unavailable right now.',
      );
    }

    final messages = payload?['messages'];
    if (messages is! List || messages.isEmpty) {
      throw const AiMessageException(
        code: 'unavailable',
        message: 'AI returned an empty response.',
      );
    }

    return messages.map((m) => m.toString().trim()).where((m) => m.isNotEmpty).toList();
  }
}
