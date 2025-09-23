import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/reminders/ui/add_event_screen.dart';
import 'package:celebray/features/reminders/ui/ui_utils/custom_designs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersScreen extends ConsumerWidget {
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
            : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    title: Text(event.name),
                    subtitle: Text('${event.type} • ${event.date.toLocal()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        eventNotifier.deleteEvent(event);
                      },
                    ),
                  );
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
