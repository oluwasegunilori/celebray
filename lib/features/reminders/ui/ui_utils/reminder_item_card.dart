import 'dart:io';

import 'package:celebray/app_theme.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/utils/date_format.dart';
import 'package:flutter/material.dart';

Widget reminderItem({
  required EventModel event,
  required Function(EventAction) onPressed,
}) {
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
              backgroundColor: AppTheme.primaryLight,
              child: const Icon(Icons.event, color: AppTheme.primary),
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
            '${event.type} • ${dateFormatterDay.format(event.date)}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Text(
            'Relationship: ${event.relationship}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          if (event.memories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '"${event.memories.first}"',
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
        onSelected: onPressed,
        itemBuilder: (context) => [
          PopupMenuItem(value: ViewEvent(event.id), child: const Text('View')),
          PopupMenuItem(value: EditEvent(event), child: const Text('Edit')),
          PopupMenuItem(
            value: DeleteEvent(event.id),
            child: const Text('Delete'),
          ),
          PopupMenuItem(
            value: ShareEvent(event.id),
            child: const Text('Share'),
          ),
          PopupMenuItem(
            value: GenerateMessage(event.id),
            child: const Text('Generate Message'),
          ),
        ],
      ),
      onTap: () => onPressed(ViewEvent(event.id)),
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
  final EventModel event;
  const EditEvent(this.event);
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
