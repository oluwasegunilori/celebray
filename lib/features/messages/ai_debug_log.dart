import 'package:flutter/foundation.dart';

/// Debug-only logs for the AI guest/auth/API flow. Filter console with `CelebrayAI`.
abstract final class AiDebugLog {
  static const _tag = 'CelebrayAI';

  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] $message');
    }
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;

    final buffer = StringBuffer('[$_tag] ERROR: $message');
    if (error != null) {
      buffer.write(' | $error');
    }
    debugPrint(buffer.toString());
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
