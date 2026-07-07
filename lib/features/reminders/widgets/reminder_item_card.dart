import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/events/domain/event_actions.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/widgets/event_list_card.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return EventListCard(
      event: event,
      onTap: () => onAction(ViewEvent(event.id)),
      trailing: PopupMenuButton<EventAction>(
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
            child: Text(
              event.generatedMessage?.trim().isNotEmpty ?? false
                  ? 'Edit Message'
                  : 'Generate Message',
            ),
          ),
        ],
      ),
    );
  }
}
