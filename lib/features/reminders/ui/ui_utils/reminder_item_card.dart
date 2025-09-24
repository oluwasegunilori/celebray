import 'dart:io';

import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/utils/date_format.dart';
import 'package:flutter/material.dart';

Widget reminderItem({required EventModel event, required Function(EventAction) onPressed}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 3,
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: event.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(event.imagePath!),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          : CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.event, color: Colors.blueAccent),
            ),
      title: Text(
        event.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "${event.type} • ${dateFormatterDay.format(event.date)}",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Text(
            "Relationship: ${event.relationship}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          if (event.memories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "“${event.memories.fold('', (initialValue, combine) => "$initialValue \n $combine")}”",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade800,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      trailing: PopupMenuButton<EventAction>(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onSelected: (action) {
          // Handle actions here
          switch (action) {
            case ViewEvent(:var eventId):
              onPressed(ViewEvent(eventId));
            case EditEvent(:var eventId):
              onPressed(EditEvent(eventId));
            case DeleteEvent(:var eventId):
              onPressed(DeleteEvent(eventId));
            case ShareEvent(:var eventId):
              onPressed(ShareEvent(eventId));
            case GenerateMessage(:var eventId):
              onPressed(GenerateMessage(eventId));
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: ViewEvent(event.id), child: const Text("View")),
          PopupMenuItem(value: EditEvent(event.id), child: const Text("Edit")),
          PopupMenuItem(
            value: DeleteEvent(event.id),
            child: const Text("Delete"),
          ),
          PopupMenuItem(
            value: ShareEvent(event.id),
            child: const Text("Share"),
          ),
        ],
      ),
      onTap: () {
        // Maybe navigate to Event details page
      },
    ),
  );
}

sealed class EventAction {
  const EventAction();
}

class ViewEvent extends EventAction {
  final String eventId;
  const ViewEvent(this.eventId);
}

class EditEvent extends EventAction {
  final String eventId;
  const EditEvent(this.eventId);
}

class DeleteEvent extends EventAction {
  final String eventId;
  const DeleteEvent(this.eventId);
}

class ShareEvent extends EventAction {
  final String eventId;
  const ShareEvent(this.eventId);
}

class GenerateMessage extends EventAction {
  final String eventId;
  const GenerateMessage(this.eventId);
}
