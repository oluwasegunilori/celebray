import 'package:celebray/core/constants/app_constants.dart';
import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/widgets/home_toolbar_actions.dart';
import 'package:celebray/features/auth/data/ai_auth_service.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/messages/message_generation_result.dart';
import 'package:celebray/features/messages/message_generator_service.dart';
import 'package:celebray/features/messages/message_tones.dart';
import 'package:celebray/features/messages/widgets/message_generation_notice.dart';
import 'package:celebray/features/messages/widgets/tone_picker.dart';
import 'package:celebray/features/sharing/models/card_style.dart';
import 'package:celebray/features/sharing/share_service.dart';
import 'package:celebray/features/sharing/widgets/card_alignment_picker.dart';
import 'package:celebray/features/sharing/widgets/card_color_picker.dart';
import 'package:celebray/features/sharing/widgets/card_typography_picker.dart';
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
  int _selectedMessageIndex = 0;
  int _cardColorIndex = 0;
  int _cardTypographyIndex = 0;
  CardTextAlignment _cardAlignment = CardStyles.defaultAlignment;
  List<String> _messages = [];
  bool _isGenerating = false;
  String? _generationNotice;
  MessageGenerationSource? _generationSource;
  final _cardKey = GlobalKey();
  late final ValueNotifier<String> _toneNotifier;

  @override
  void initState() {
    super.initState();
    _toneNotifier = ValueNotifier(MessageTones.defaultTone);
    _selectedEventId = widget.initialEvent?.id;
  }

  @override
  void dispose() {
    _toneNotifier.dispose();
    super.dispose();
  }

  EventModel? _selectedFrom(List<EventModel> events) {
    if (_selectedEventId == null) return null;
    for (final event in events) {
      if (event.id == _selectedEventId) return event;
    }
    return null;
  }

  Future<void> _generateMessages(EventModel event) async {
    setState(() {
      _isGenerating = true;
      _generationNotice = null;
      _generationSource = null;
    });

    final result = await MessageGeneratorService.generateMessages(
      event,
      tone: _toneNotifier.value,
    );

    if (!mounted) return;

    setState(() {
      _messages = result.messages;
      _selectedMessageIndex = 0;
      _isGenerating = false;
      _generationNotice = result.notice;
      _generationSource = result.source;
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
      faithContext: event.faithContext,
    );
    await ref.read(eventProvider.notifier).updateEvent(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message saved to event')),
      );
    }
  }

  Future<void> _shareCard(EventModel event, BuildContext shareContext) async {
    if (_messages.isEmpty) return;
    await ShareService.shareGreetingCard(
      cardKey: _cardKey,
      shareContext: shareContext,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Message'),
        actions: const [HomeToolbarActions()],
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
                    _generationNotice = null;
                    _generationSource = null;
                  });
                },
              ),
              MessageGenerationNotice(
                notice: _generationNotice,
                source: _generationSource,
                onSignedIn: () {
                  if (!mounted) return;
                  setState(() {
                    _generationNotice = AiAuthService.hasFullAccount
                        ? 'Signed in. Tap Generate Messages for AI-powered options.'
                        : AppConstants.guestAiNotice();
                  });
                },
              ),
              const SizedBox(height: 4),
              TonePicker(toneNotifier: _toneNotifier),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedEvent != null && !_isGenerating
                      ? () => _generateMessages(selectedEvent)
                      : null,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isGenerating ? 'Generating…' : 'Generate Messages',
                  ),
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
                      child: Builder(
                        builder: (shareContext) => ElevatedButton(
                          onPressed: () => _shareCard(selectedEvent, shareContext),
                          child: const Text('Share Card'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CardColorPicker(
                  selectedIndex: _cardColorIndex,
                  onSelected: (i) => setState(() => _cardColorIndex = i),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Text style',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CardTypographyPicker(
                  selectedIndex: _cardTypographyIndex,
                  onSelected: (i) => setState(() => _cardTypographyIndex = i),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alignment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CardAlignmentPicker(
                  selected: _cardAlignment,
                  onSelected: (a) => setState(() => _cardAlignment = a),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Card preview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GreetingCardPreview(
                    cardKey: _cardKey,
                    message: _messages[_selectedMessageIndex],
                    colorIndex: _cardColorIndex,
                    typographyIndex: _cardTypographyIndex,
                    alignment: _cardAlignment,
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
