import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:celebray/core/widgets/event_avatar.dart';
import 'package:celebray/features/events/domain/event_actions.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget reminderItem({
  required EventModel event,
  required Function(EventAction) onPressed,
}) {
  return ReminderItemCard(event: event, onAction: onPressed);
}

class ReminderItemCard extends StatelessWidget {
  final EventModel event;
  final ValueChanged<EventAction> onAction;

  const ReminderItemCard({
    super.key,
    required this.event,
    required this.onAction,
  });

  static const _weekThreshold = 7;

  String _dateLabel(DateTime eventDate) {
    final next = EventDateUtils.nextOccurrence(eventDate);
    final days = EventDateUtils.daysUntilNext(eventDate);

    if (days <= _weekThreshold) {
      return timeago.format(next, locale: 'en', allowFromNow: true);
    }

    final now = DateTime.now();
    if (next.year == now.year) {
      return DateFormat('EEE, MMM d').format(next);
    }
    return DateFormat('EEE, MMM d, y').format(next);
  }

  String _timeLabel(DateTime eventDate) {
    final next = EventDateUtils.nextOccurrence(eventDate);
    return DateFormat('h:mm a').format(next);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateLabel(event.date);
    final time = _timeLabel(event.date);
    final days = EventDateUtils.daysUntilNext(event.date);
    final urgent = days <= 1;
    final withinWeek = days <= _weekThreshold;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onAction(ViewEvent(event.id)),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventAvatar(
                    imagePath: event.imagePath,
                    fallbackIcon: EventAvatar.iconForEventType(event.type),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name.isNotEmpty ? event.name : event.type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event.type} · ${event.relationship}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _DateChip(
                              label: dateLabel,
                              highlighted: withinWeek,
                              urgent: urgent,
                            ),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        if (event.memories.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            event.memories.first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textSecondary.withValues(alpha: 0.9),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<EventAction>(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: onAction,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: ViewEvent(event.id),
                        child: const Text('View'),
                      ),
                      PopupMenuItem(
                        value: EditEvent(event),
                        child: const Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: DeleteEvent(event.id),
                        child: const Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: ShareEvent(event.id),
                        child: const Text('Share'),
                      ),
                      PopupMenuItem(
                        value: GenerateMessage(event.id),
                        child: const Text('Generate Message'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  final bool urgent;

  const _DateChip({
    required this.label,
    required this.highlighted,
    required this.urgent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: urgent ? AppTheme.accentLight : AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: urgent
              ? AppTheme.accent.withValues(alpha: 0.4)
              : AppTheme.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: urgent ? AppTheme.accentDark : AppTheme.black,
          height: 1.2,
        ),
      ),
    );
  }
}
