import 'package:celebray/features/reminders/providers/reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderProvider);
    final notifier = ref.read(reminderProvider.notifier);

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
                  notifier.addReminder(input.trim());
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
            onPressed: () => notifier.clearAll(),
          ),
        ],
      ),
      body: reminders.isEmpty
          ? Center(child: Text('No reminders yet.'))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(reminders[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () => notifier.removeReminder(index),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
