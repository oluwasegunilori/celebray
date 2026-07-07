import 'package:celebray/features/events/domain/event_model.dart';

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
