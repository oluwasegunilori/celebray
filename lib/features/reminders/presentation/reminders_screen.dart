import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/widgets/home_toolbar_actions.dart';
import 'package:celebray/features/events/domain/event_actions.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/generator/presentation/edit_message_screen.dart';
import 'package:celebray/features/generator/presentation/generator_screen.dart';
import 'package:celebray/features/reminders/presentation/add_event_sheet.dart';
import 'package:celebray/features/reminders/presentation/event_detail_sheet.dart';
import 'package:celebray/features/reminders/widgets/reminder_list.dart';
import 'package:celebray/features/sharing/widgets/share_event_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventProvider);
    final eventNotifier = ref.read(eventProvider.notifier);

    void openAddEventSheet({EventModel? event, EventModel? initialData}) {
      showAddEventSheet(
        context,
        event: event,
        initialData: initialData,
      );
    }

    void openCalendarImport() {
      HomeToolbarActions.openCalendarImport(context);
    }

    Future<void> deleteWithUndo(EventModel event) async {
      final label = event.name.isNotEmpty ? event.name : event.type;

      await eventNotifier.deleteEvent(event);

      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final reason = await messenger
          .showSnackBar(
            SnackBar(
              content: Text(
                'Deleted "$label"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                textColor: AppTheme.accent,
                onPressed: () {},
              ),
              duration: const Duration(seconds: 4),
            ),
          )
          .closed;

      if (reason == SnackBarClosedReason.action) {
        await eventNotifier.addEvent(event);
      }
    }

    void handleAction(
      EventAction action,
      List<EventModel> events, [
      EventModel? eventContext,
    ]) {
      switch (action) {
        case ViewEvent(:var eventId):
          final event = events.firstWhere((e) => e.id == eventId);
          EventDetailSheet.show(
            context,
            event: event,
            onAction: (a) => handleAction(a, events),
          );
        case EditEvent(:var event):
          openAddEventSheet(event: event);
        case DeleteEvent(:var eventId):
          final event = eventContext ??
              events.firstWhere((e) => e.id == eventId);
          deleteWithUndo(event);
        case ShareEvent(:var eventId):
          final event = events.firstWhere((e) => e.id == eventId);
          ShareEventSheet.show(context, event: event);
        case GenerateMessage(:var eventId):
          final event = events.firstWhere((e) => e.id == eventId);
          final hasMessage = event.generatedMessage?.trim().isNotEmpty ?? false;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => hasMessage
                  ? EditMessageScreen(event: event)
                  : GeneratorScreen(initialEvent: event),
            ),
          );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: const [HomeToolbarActions()],
      ),
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? _EmptyRemindersState(
                onAdd: () => openAddEventSheet(),
                onImport: openCalendarImport,
              )
            : ReminderList(
                events: events,
                onAction: (action, event) =>
                    handleAction(action, events, event),
                onDelete: deleteWithUndo,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddEventSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyRemindersState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onImport;

  const _EmptyRemindersState({
    required this.onAdd,
    required this.onImport,
  });

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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Import from calendar'),
            ),
          ],
        ),
      ),
    );
  }
}
