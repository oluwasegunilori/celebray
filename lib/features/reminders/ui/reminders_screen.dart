import 'package:celebray/app_theme.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/generator/generator_screen.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/features/reminders/ui/add_event_screen.dart';
import 'package:celebray/features/reminders/ui/event_detail_sheet.dart';
import 'package:celebray/features/reminders/ui/ui_utils/animations/reminder_list_anim.dart';
import 'package:celebray/features/reminders/ui/ui_utils/custom_designs.dart';
import 'package:celebray/features/reminders/ui/ui_utils/reminder_item_card.dart';
import 'package:celebray/services/share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventProvider);
    final eventNotifier = ref.read(eventProvider.notifier);

    void showAddReminderDialog({
      required BuildContext context,
      EventModel? event,
    }) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Material(
                child: Column(
                  children: [
                    SheetHeader(
                      title: event != null ? 'Edit Event' : 'Add Event',
                      onClose: () => Navigator.pop(context),
                    ),
                    Expanded(child: AddEventScreen(event: event)),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    Future<void> confirmClearAll(List<EventModel> events) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear all events?'),
          content: const Text(
            'This will permanently delete all your celebrations and cancel their reminders.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await eventNotifier.deleteAllEvents(events);
      }
    }

    void handleAction(EventAction action, List<EventModel> events) {
      switch (action) {
        case ViewEvent(:var eventId):
          final event = events.firstWhere((e) => e.id == eventId);
          EventDetailSheet.show(
            context,
            event: event,
            onAction: (a) => handleAction(a, events),
          );
        case EditEvent(:var event):
          showAddReminderDialog(context: context, event: event);
        case DeleteEvent(:var eventId):
          final event = events.firstWhere((e) => e.id == eventId);
          eventNotifier.deleteEvent(event);
        case ShareEvent(:var eventId):
          final event = events.firstWhere((e) => e.id == eventId);
          ShareService.shareEventText(event);
        case GenerateMessage(:var eventId):
          final event = events.firstWhere((e) => e.id == eventId);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GeneratorScreen(initialEvent: event),
            ),
          );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all',
            onPressed: () {
              final events = eventsAsync.value;
              if (events != null && events.isNotEmpty) {
                confirmClearAll(events);
              }
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? _EmptyRemindersState(
                onAdd: () => showAddReminderDialog(context: context),
              )
            : ReminderList(
                events: events,
                onAction: (action) => handleAction(action, events),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddReminderDialog(context: context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyRemindersState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyRemindersState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration_outlined,
              size: 80,
              color: AppTheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 20),
            const Text(
              'No celebrations yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first birthday, anniversary, or milestone to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add your first celebration'),
            ),
          ],
        ),
      ),
    );
  }
}
