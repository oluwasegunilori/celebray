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
      final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: bottomInset > 0 ? 0.92 : 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
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
                      scrollController: scrollController,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
