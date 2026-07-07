import 'package:celebray/app_theme.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/features/reminders/ui/ui_utils/event_avatar.dart';
import 'package:celebray/features/reminders/ui/ui_utils/reminder_item_card.dart';
import 'package:celebray/services/share_service.dart';
import 'package:celebray/utils/date_format.dart';
import 'package:celebray/utils/event_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailSheet extends ConsumerWidget {
  final EventModel event;
  final void Function(EventAction) onAction;

  const EventDetailSheet({
    super.key,
    required this.event,
    required this.onAction,
  });

  static void show(
    BuildContext context, {
    required EventModel event,
    required void Function(EventAction) onAction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EventDetailSheet(event: event, onAction: onAction),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = EventDateUtils.nextOccurrence(event.date);
    final actualDate = dateFormatterDay.format(next);
    final daysUntil = EventDateUtils.daysUntilNext(event.date);
    final badge = daysUntil <= 7
        ? (daysUntil == 0
            ? 'Today'
            : daysUntil == 1
                ? 'Tomorrow'
                : 'In $daysUntil days')
        : null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventAvatar(
                    imagePath: event.imagePath,
                    size: 56,
                    borderRadius: 28,
                    fallbackIcon: EventAvatar.iconForEventType(event.type),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name.isNotEmpty ? event.name : event.type,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          event.type,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Chip(
                              label: Text(badge),
                              backgroundColor: AppTheme.primaryLight,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: actualDate,
              ),
              _DetailRow(
                icon: Icons.people,
                label: 'Relationship',
                value: event.relationship,
              ),
              _DetailRow(
                icon: Icons.favorite,
                label: 'Closeness',
                value: '${event.closeness}/10',
              ),
              if (event.memories.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Memories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: event.memories
                      .map((m) => Chip(label: Text(m)))
                      .toList(),
                ),
              ],
              if (event.generatedMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '"${event.generatedMessage}"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onAction(EditEvent(event));
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ShareService.shareEventText(event);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onAction(GenerateMessage(event.id));
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Message'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
