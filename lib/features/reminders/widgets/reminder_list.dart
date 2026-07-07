import 'package:celebray/features/events/domain/event_actions.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/reminders/widgets/reminder_item_card.dart';
import 'package:flutter/material.dart';

class ReminderList extends StatelessWidget {
  final List<EventModel> events;
  final void Function(EventAction action, EventModel event) onAction;
  final Future<void> Function(EventModel event) onDelete;

  const ReminderList({
    super.key,
    required this.events,
    required this.onAction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        return Dismissible(
          key: ValueKey(event.id),
          direction: DismissDirection.endToStart,
          background: const _SwipeDeleteBackground(),
          onDismissed: (_) => onDelete(event),
          child: ReminderItemCard(
            event: event,
            onAction: (action) => onAction(action, event),
          ),
        );
      },
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }
}
