import 'dart:convert';

import 'package:celebray/core/constants/app_constants.dart';
import 'package:celebray/features/auth/data/ai_auth_service.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/messages/ai_debug_log.dart';
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
    required User user,
  }) async {
    final body = _eventPayload(event, tone: tone);
    return _postMessages('generateMessages', body, user: user);
  }

  static Future<List<String>> touchUpMessage({
    required EventModel event,
    required String currentMessage,
    required String instructions,
    required User user,
  }) async {
    final body = {
      ..._eventPayload(event),
      'currentMessage': currentMessage,
      'instructions': instructions,
    };
    return _postMessages('touchUpMessage', body, user: user);
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
      if (tone != null) 'tone': tone,
    };
  }

  static Future<List<String>> _postMessages(
    String functionName,
    Map<String, dynamic> body, {
    required User user,
  }) async {
    final uri = Uri.parse('${AppConstants.aiFunctionsBaseUrl}/$functionName');
    AiDebugLog.log(
      '_postMessages: $functionName isAnonymous=${user.isAnonymous}',
    );

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      AiDebugLog.error('_postMessages: empty ID token');
      throw const AiMessageException(
        code: 'unauthorized',
        message: 'Could not get an auth token. Try again.',
      );
    }
    AiDebugLog.log('_postMessages: token ready');

    final stopwatch = Stopwatch()..start();
    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
    } catch (error, stack) {
      AiDebugLog.error(
        '_postMessages: network/timeout for $functionName',
        stack,
      );
      rethrow;
    }
    stopwatch.stop();

    AiDebugLog.log(
      '_postMessages: $functionName status=${response.statusCode} '
      'ms=${stopwatch.elapsedMilliseconds}',
    );

    Map<String, dynamic>? payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error, stack) {
      AiDebugLog.error('_postMessages: invalid JSON response', stack);
      payload = null;
    }

    if (payload != null) {
      AiDebugLog.log(
        '_postMessages: payload error=${payload["error"]} '
        'isAnonymous=${payload["isAnonymous"]} limit=${payload["limit"]}',
      );
    }

    if (response.statusCode == 401) {
      final isCloudRunGate =
          response.body.contains('<html>') || response.body.contains('Unauthorized</title>');
      AiDebugLog.error(
        '_postMessages: 401 ${isCloudRunGate ? "cloud_run_iam" : "app_auth"}',
      );
      throw AiMessageException(
        code: 'unauthorized',
        message: isCloudRunGate
            ? 'Cloud Function access denied (401). Redeploy functions with '
                'invoker: "public", or check GCP IAM for this function.'
            : payload?['message'] as String? ??
                'Sign in to use AI message generation.',
      );
    }

    if (response.statusCode == 429) {
      final limit = payload?['limit'] as int? ??
          (AiAuthService.isGuest
              ? AppConstants.aiAnonymousDailyLimit
              : AppConstants.aiDailyLimit);
      AiDebugLog.error('_postMessages: 429 rate_limited limit=$limit');
      final upgradeHint = limit <= AppConstants.aiAnonymousDailyLimit
          ? ' Sign in for ${AppConstants.aiDailyLimit}/day.'
          : ' Try again tomorrow.';
      throw AiMessageException(
        code: 'rate_limited',
        message: 'Daily AI limit reached ($limit/day).$upgradeHint',
      );
    }

    if (response.statusCode == 422) {
      AiDebugLog.error('_postMessages: 422 content_refused');
      throw AiMessageException(
        code: payload?['error'] as String? ?? 'content_refused',
        message: payload?['message'] as String? ??
            "This request can't be processed. Celebray only helps write celebration messages.",
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      AiDebugLog.error(
        '_postMessages: HTTP ${response.statusCode} error=${payload?["error"]}',
      );
      throw AiMessageException(
        code: 'unavailable',
        message: payload?['message'] as String? ??
            'AI is unavailable right now.',
      );
    }

    final messages = payload?['messages'];
    if (messages is! List || messages.isEmpty) {
      AiDebugLog.error('_postMessages: empty messages in 2xx response');
      throw const AiMessageException(
        code: 'unavailable',
        message: 'AI returned an empty response.',
      );
    }

    AiDebugLog.log('_postMessages: $functionName success count=${messages.length}');
    return messages.map((m) => m.toString().trim()).where((m) => m.isNotEmpty).toList();
  }
}
