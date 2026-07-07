import 'package:celebray/app_theme.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/services/message_generator_service.dart';
import 'package:celebray/services/share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  final EventModel? initialEvent;

  const GeneratorScreen({super.key, this.initialEvent});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  EventModel? _selectedEvent;
  String _selectedTone = 'warm';
  int _selectedMessageIndex = 0;
  int _cardThemeIndex = 0;
  List<String> _messages = [];
  final _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedEvent = widget.initialEvent;
  }

  void _generateMessages() {
    if (_selectedEvent == null) return;
    setState(() {
      _messages = MessageGeneratorService.generateMessages(
        _selectedEvent!,
        tone: _selectedTone,
      );
      _selectedMessageIndex = 0;
    });
  }

  Future<void> _saveMessage() async {
    if (_selectedEvent == null || _messages.isEmpty) return;
    final message = _messages[_selectedMessageIndex];
    final updated = EventModel(
      id: _selectedEvent!.id,
      name: _selectedEvent!.name,
      type: _selectedEvent!.type,
      date: _selectedEvent!.date,
      relationship: _selectedEvent!.relationship,
      sex: _selectedEvent!.sex,
      closeness: _selectedEvent!.closeness,
      memories: _selectedEvent!.memories,
      imagePath: _selectedEvent!.imagePath,
      generatedMessage: message,
    );
    await ref.read(eventProvider.notifier).updateEvent(updated);
    setState(() => _selectedEvent = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message saved to event')),
      );
    }
  }

  Future<void> _shareCard() async {
    if (_selectedEvent == null || _messages.isEmpty) return;
    await ShareService.shareGreetingCard(
      event: _selectedEvent!,
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
            return _EmptyState(
              icon: Icons.auto_awesome,
              title: 'No events yet',
              subtitle: 'Add a celebration first, then generate a message.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Select an event',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EventModel>(
                value: _selectedEvent,
                decoration: const InputDecoration(
                  labelText: 'Event',
                  border: OutlineInputBorder(),
                ),
                items: events
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text('${e.name} — ${e.type}'),
                      ),
                    )
                    .toList(),
                onChanged: (event) {
                  setState(() {
                    _selectedEvent = event;
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
                  onPressed: _selectedEvent != null ? _generateMessages : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Messages'),
                ),
              ),
              if (_messages.isNotEmpty) ...[
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
                        onPressed: _saveMessage,
                        child: const Text('Save to Event'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _shareCard,
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
                          backgroundColor: GreetingCardWidget
                              .cardGradients[i % 5][0],
                          child: _cardThemeIndex == i
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
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
                      event: _selectedEvent!,
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
