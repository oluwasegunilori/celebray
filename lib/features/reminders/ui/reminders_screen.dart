import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/reminders/ui/add_event_screen.dart';
import 'package:celebray/features/reminders/ui/ui_utils/animations/reminder_list_anim.dart';
import 'package:celebray/features/reminders/ui/ui_utils/custom_designs.dart';
import 'package:celebray/features/reminders/ui/ui_utils/reminder_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to events (the front-facing "reminders")
    final eventsAsync = ref.watch(eventNotifierProvider);
    final eventNotifier = ref.read(eventNotifierProvider.notifier);

    void showAddReminderDialog() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Allows full height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8, // Almost full screen
            minChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Material(
                child: Column(
                  children: [
                    SheetHeader(
                      title: "Add Event",
                      onClose: () => Navigator.pop(context),
                    ),
                    Expanded(child: AddEventScreen()),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Clear all events
              final events = await ref
                  .read(eventNotifierProvider.notifier)
                  .build()
                  .first;
              for (final e in events) {
                await eventNotifier.deleteEvent(e);
              }
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? Center(child: Text('No reminders yet.'))
            : ReminderList(
                events: events,
                onAction: (action) {
                  // Handle actions from the reminder items
                  switch (action) {
                    case ViewEvent(:var eventId):
                      // Navigate to view event details
                      print("View event: $eventId");
                    case EditEvent(:var eventId):
                      // Navigate to edit event screen
                      print("Edit event: $eventId");
                    case DeleteEvent(:var eventId):
                      final event = events.firstWhere((e) => e.id == eventId);
                      eventNotifier.deleteEvent(event);
                    case ShareEvent(:var eventId):
                      // Share the event details
                      print("Share event: $eventId");
                    case GenerateMessage(:var eventId):
                      // Generate a message for the event
                      print("Generate message for event: $eventId");
                  }
                },
              ),

        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddReminderDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
