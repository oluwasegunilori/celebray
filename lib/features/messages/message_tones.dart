/// Supported message tones for generate + template fallback.
abstract final class MessageTones {
  static const defaultTone = 'warm';

  static const all = [
    'warm',
    'funny',
    'formal',
    'prayerful',
    'romantic',
    'casual',
    'brief',
    'heartfelt',
    'poetic',
  ];

  static String label(String tone) {
    return switch (tone) {
      'brief' => 'Brief',
      _ => tone[0].toUpperCase() + tone.substring(1),
    };
  }
}
