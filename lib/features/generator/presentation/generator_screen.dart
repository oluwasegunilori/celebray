import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/messages/message_generator_service.dart';
import 'package:celebray/features/sharing/share_service.dart';
import 'package:celebray/features/sharing/widgets/greeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  final EventModel? initialEvent;

  const GeneratorScreen({super.key, this.initialEvent});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  String? _selectedEventId;
  String _selectedTone = 'warm';
  int _selectedMessageIndex = 0;
  int _cardThemeIndex = 0;
  List<String> _messages = [];
  final _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialEvent?.id;
  }

  EventModel? _selectedFrom(List<EventModel> events) {
    if (_selectedEventId == null) return null;
    for (final event in events) {
      if (event.id == _selectedEventId) return event;
    }
    return null;
  }

  void _generateMessages(EventModel event) {
    setState(() {
      _messages = MessageGeneratorService.generateMessages(
        event,
        tone: _selectedTone,
      );
      _selectedMessageIndex = 0;
    });
  }

  Future<void> _saveMessage(EventModel event) async {
    if (_messages.isEmpty) return;
    final message = _messages[_selectedMessageIndex];
    final updated = EventModel(
      id: event.id,
      name: event.name,
      type: event.type,
      date: event.date,
      relationship: event.relationship,
      sex: event.sex,
      closeness: event.closeness,
      memories: event.memories,
      imagePath: event.imagePath,
      generatedMessage: message,
    );
    await ref.read(eventProvider.notifier).updateEvent(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message saved to event')),
      );
    }
  }

  Future<void> _shareCard(EventModel event) async {
    if (_messages.isEmpty) return;
    await ShareService.shareGreetingCard(
      event: event,
      cardKey: _cardKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const _EmptyState(
              icon: Icons.auto_awesome,
              title: 'No events yet',
              subtitle: 'Add a celebration first, then generate a message.',
            );
          }

          final selectedEvent = _selectedFrom(events);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Select an event',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedEvent?.id,
                decoration: const InputDecoration(
                  labelText: 'Event',
                  border: OutlineInputBorder(),
                ),
                items: events
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(
                          e.name.isNotEmpty
                              ? '${e.name} — ${e.type}'
                              : e.type,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (eventId) {
                  setState(() {
                    _selectedEventId = eventId;
                    _messages = [];
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tone',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'warm', label: Text('Warm')),
                  ButtonSegment(value: 'funny', label: Text('Funny')),
                  ButtonSegment(value: 'formal', label: Text('Formal')),
                ],
                selected: {_selectedTone},
                onSelectionChanged: (selection) {
                  setState(() => _selectedTone = selection.first);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedEvent != null
                      ? () => _generateMessages(selectedEvent)
                      : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Messages'),
                ),
              ),
              if (_messages.isNotEmpty && selectedEvent != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Pick a message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(_messages.length, (index) {
                  return RadioListTile<int>(
                    value: index,
                    groupValue: _selectedMessageIndex,
                    onChanged: (v) => setState(() => _selectedMessageIndex = v!),
                    title: Text(_messages[index]),
                  );
                }),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _saveMessage(selectedEvent),
                        child: const Text('Save to Event'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _shareCard(selectedEvent),
                        child: const Text('Share Card'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Card preview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _cardThemeIndex = i),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              GreetingCardWidget.cardGradients[i % 5][0],
                          child: _cardThemeIndex == i
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Center(
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: GreetingCardWidget(
                      event: selectedEvent,
                      message: _messages[_selectedMessageIndex],
                      themeIndex: _cardThemeIndex,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppTheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
