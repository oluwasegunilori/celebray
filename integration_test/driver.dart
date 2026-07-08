import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final outputDir = Platform.environment['SCREENSHOT_OUTPUT_DIR'] ??
      p.join(
        Directory.current.path,
        'store_screenshots',
        'ios',
        '6.7-inch',
      );
  await Directory(outputDir).create(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File(p.join(outputDir, '$name.png'));
      await file.writeAsBytes(bytes, flush: true);
      // ignore: avoid_print
      print('Screenshot saved: ${file.path}');
      return true;
    },
  );
}
