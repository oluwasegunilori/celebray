import 'package:flutter_riverpod/flutter_riverpod.dart';

// A simple StateNotifier for managing a list of reminders
class ReminderNotifier extends Notifier<List<String>> {

  @override
  List<String> build() => [];

  void addReminder(String reminder) {
    state = [...state, reminder];
  }

  void removeReminder(int index) {
    state = [...state]..removeAt(index);
  }

  void clearAll() {
    state = [];
  }

}

// Provider for accessing the state
final reminderProvider = NotifierProvider<ReminderNotifier, List<String>>(ReminderNotifier.new);
