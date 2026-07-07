import 'package:celebray/core/widgets/sheet_header.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/reminders/presentation/add_event_screen.dart';
import 'package:flutter/material.dart';

void showAddEventSheet(
  BuildContext context, {
  EventModel? event,
  EventModel? initialData,
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
                Expanded(
                  child: AddEventScreen(
                    event: event,
                    initialData: initialData,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
