import 'dart:io';
import 'dart:ui' as ui;

import 'package:celebray/core/utils/date_format.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static Future<void> shareEventText(EventModel event) async {
    final text = _buildShareText(event);
    await Share.share(text, subject: "${event.name}'s ${event.type}");
  }

  static String _buildShareText(EventModel event) {
    return "${event.name}'s ${event.type} is on "
        '${dateFormatterDay.format(event.date)}. '
        "Don't forget to celebrate!";
  }

  static Future<void> shareGreetingCard({
    required EventModel event,
    required GlobalKey cardKey,
  }) async {
    final boundary =
        cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/celebray_card_${event.id}.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "${event.name}'s ${event.type}",
    );
  }
}
