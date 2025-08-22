import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to events (the front-facing "reminders")
    final eventsAsync = ref.watch(eventNotifierProvider);
    final notifier = ref.read(eventNotifierProvider.notifier);

    void _showAddReminderDialog() {
      String input = '';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add Reminder'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => input = value,
            decoration: InputDecoration(hintText: 'Enter reminder'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (input.trim().isNotEmpty) {
                  // Create an Event from input
                  // final event = Event(title: input.trim(), date: DateTime.now());
                  // notifier.addEvent(event);
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        ),
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
                await notifier.deleteEvent(e);
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
                        notifier.deleteEvent(event);
                      },
                    ),
                  );
                },
              ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
