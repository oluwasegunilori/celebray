import 'package:celebray/core/utils/date_format.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:flutter/material.dart';

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
    [Color(0xFF111111), Color(0xFF333333)],
    [Color(0xFFD4A017), Color(0xFF9A7209)],
    [Color(0xFF111111), Color(0xFFD4A017)],
    [Color(0xFF2D2D2D), Color(0xFF111111)],
    [Color(0xFF4A4A4A), Color(0xFF111111)],
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
