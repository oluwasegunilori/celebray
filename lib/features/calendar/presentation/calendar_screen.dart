import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/utils/unique_id.dart';
import 'package:celebray/core/widgets/home_toolbar_actions.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/widgets/event_list_card.dart';
import 'package:celebray/features/reminders/presentation/add_event_sheet.dart';
import 'package:celebray/features/reminders/presentation/event_detail_sheet.dart';
import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  DateTime get _activeDay {
    final day = _selectedDay ?? DateTime.now();
    return DateTime(day.year, day.month, day.day);
  }

  void _openAddEvent([DateTime? day]) {
    final target = day ?? _activeDay;
    final normalized = DateTime(target.year, target.month, target.day);
    showAddEventSheet(
      context,
      initialData: EventModel(
        id: uniqueId(),
        name: '',
        type: '',
        date: normalized,
        relationship: '',
        sex: '',
        closeness: 5,
      ),
    );
  }

  List<EventModel> _eventsForDay(List<EventModel> events, DateTime day) {
    return events
        .where((e) => EventDateUtils.occursOnDay(e.date, day))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: const [HomeToolbarActions()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEvent,
        tooltip: 'Add celebration',
        child: const Icon(Icons.add),
      ),
      body: eventsAsync.when(
        data: (events) {
          final selected = _activeDay;
          final dayEvents = _eventsForDay(events, selected);

          return Column(
            children: [
              TableCalendar<EventModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _eventsForDay(events, day),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.primaryDark,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  if (_eventsForDay(events, selectedDay).isEmpty) {
                    _openAddEvent(selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      _formatSelectedDay(selected),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${dayEvents.length} event${dayEvents.length == 1 ? '' : 's'}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add celebration on this day',
                      color: AppTheme.primary,
                      onPressed: _openAddEvent,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: dayEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No celebrations on this day',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _openAddEvent,
                              icon: const Icon(Icons.add),
                              label: const Text('Add celebration'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: dayEvents.length,
                        itemBuilder: (context, index) {
                          final event = dayEvents[index];
                          return EventListCard(
                            event: event,
                            showDateCountdown: false,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            onTap: () => EventDetailSheet.show(
                              context,
                              event: event,
                              onAction: (_) {},
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatSelectedDay(DateTime day) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[day.month - 1]} ${day.day}, ${day.year}';
  }
}
