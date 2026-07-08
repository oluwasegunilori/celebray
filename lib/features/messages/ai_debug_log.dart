import 'package:flutter/foundation.dart';

/// Debug-only, privacy-safe logs for the AI flow. Filter console with `CelebrayAI`.
/// Does not log uids, tokens, names, message text, or response bodies.
abstract final class AiDebugLog {
  static const _tag = 'CelebrayAI';

  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] $message');
    }
  }

  static void error(
    String message, [
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;

    debugPrint('[$_tag] ERROR: $message');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
