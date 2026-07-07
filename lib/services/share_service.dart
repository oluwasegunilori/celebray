import 'dart:io';
import 'dart:ui' as ui;

import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareEventText(EventModel event) async {
    final text = _buildShareText(event);
    await Share.share(text, subject: "${event.name}'s ${event.type}");
  }

  static String _buildShareText(EventModel event) {
    return '${event.name}\'s ${event.type} is on '
        '${dateFormatterDay.format(event.date)}. '
        'Don\'t forget to celebrate! 🎉';
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
      text: "${event.name}'s ${event.type} 🎉",
    );
  }
}

/// Styled greeting card widget for screenshot sharing.
class GreetingCardWidget extends StatelessWidget {
  final EventModel event;
  final String message;
  final int themeIndex;

  const GreetingCardWidget({
    super.key,
    required this.event,
    required this.message,
    this.themeIndex = 0,
  });

  static const cardGradients = [
    [Color(0xFFE91E63), Color(0xFFAD1457)],
    [Color(0xFF7B1FA2), Color(0xFF4A148C)],
    [Color(0xFF00838F), Color(0xFF006064)],
    [Color(0xFFF57C00), Color(0xFFE65100)],
    [Color(0xFF388E3C), Color(0xFF1B5E20)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = cardGradients[themeIndex % cardGradients.length];

    return Container(
      width: 340,
      height: 480,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.type.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormatterDay.format(event.date),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— Celebray',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
