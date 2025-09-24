import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/features/reminders/ui/ui_utils/reminder_item_card.dart';
import 'package:flutter/material.dart';

class ReminderList extends StatefulWidget {
  final List<EventModel> events;
  final Function(EventAction) onAction;

  const ReminderList({super.key, required this.events, required this.onAction});

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<EventModel> _events;

  @override
  void initState() {
    super.initState();
    _events = List.from(widget.events);
  }

  @override
  void didUpdateWidget(covariant ReminderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local list if the Riverpod stream changes
    _events = List.from(widget.events);
  }

  void _hideEvent(int index) {
    final removed = _events.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: 0,
        child: reminderItem(event: removed, onPressed: (_) {}),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _events.length,
      itemBuilder: (context, index, animation) {
        final event = _events[index];
        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0,
          child: reminderItem(
            event: event,
            onPressed: (eventAction) {
              final idx = _events.indexOf(event);
              switch (eventAction) {
                case DeleteEvent(:var eventId):
                  _hideEvent(idx);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                        SnackBar(
                          content: Text('Deleted "${event.name}"'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() => _events.insert(idx, event));
                              _listKey.currentState?.insertItem(idx);
                              // Optional: clear hidden in Riverpod
                            },
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      )
                      .closed
                      .then((reason) {
                        if (reason != SnackBarClosedReason.action) {
                          // Delete from DB only if snackbar not undone
                          widget.onAction(eventAction);
                        }
                      });
                default:
                  widget.onAction(eventAction);
              }
            },
          ),
        );
      },
    );
  }
}
