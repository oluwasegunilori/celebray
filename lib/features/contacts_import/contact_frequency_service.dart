import 'dart:io';

import 'package:flutter/services.dart';

/// Android-only last-contacted timestamps for ranking import suggestions.
class ContactFrequencyService {
  ContactFrequencyService._();

  static const _channel = MethodChannel('com.shegz.celebray/contacts');

  static Future<Map<String, int>> lastContactedTimes() async {
    if (!Platform.isAndroid) return const {};

    try {
      final result =
          await _channel.invokeMethod<Map<Object?, Object?>>('lastContactedTimes');
      if (result == null) return const {};

      return result.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as num).toInt(),
        ),
      );
    } on PlatformException {
      return const {};
    }
  }
}
