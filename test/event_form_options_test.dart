import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizePersonName', () {
    test('strips redundant birthday from possessive name', () {
      expect(
        EventFormOptions.normalizePersonName(
          "David's Birthday",
          eventType: 'Birthday',
        ),
        'David',
      );
    });

    test('keeps couple names for anniversaries', () {
      expect(
        EventFormOptions.normalizePersonName(
          'David & Jessica',
          eventType: 'Anniversary',
        ),
        'David & Jessica',
      );
    });

    test('strips trailing anniversary phrase', () {
      expect(
        EventFormOptions.normalizePersonName(
          'David and Jessica Anniversary',
          eventType: 'Anniversary',
        ),
        'David and Jessica',
      );
    });
  });
}
