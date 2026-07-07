import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static Future<void> shareMessage({
    required String message,
    required BuildContext shareContext,
  }) async {
    final origin = sharePositionOrigin(shareContext);
    await SharePlus.instance.share(
      ShareParams(
        text: message,
        sharePositionOrigin: origin,
      ),
    );
  }

  static Future<void> shareGreetingCard({
    required GlobalKey cardKey,
    required BuildContext shareContext,
  }) async {
    final origin = sharePositionOrigin(shareContext);
    final boundary =
        cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/celebray_card_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: origin,
      ),
    );
  }

  /// iOS requires a non-zero rect for the share sheet popover anchor.
  static Rect sharePositionOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final origin = box.localToGlobal(Offset.zero) & box.size;
      if (origin.width > 0 && origin.height > 0) {
        return origin;
      }
    }

    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 2,
      height: 2,
    );
  }
}
