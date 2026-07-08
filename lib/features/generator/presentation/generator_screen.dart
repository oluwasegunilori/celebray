import 'package:celebray/core/constants/app_constants.dart';
import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/tutorial/feature_tutorial_overlay.dart';
import 'package:celebray/core/tutorial/generator_tutorial_steps.dart';
import 'package:celebray/core/tutorial/tutorial_storage.dart';
import 'package:celebray/core/widgets/home_toolbar_actions.dart';
import 'package:celebray/features/auth/data/ai_auth_service.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/messages/message_generation_result.dart';
import 'package:celebray/features/messages/message_generator_service.dart';
import 'package:celebray/features/messages/message_tones.dart';
import 'package:celebray/features/messages/widgets/message_generation_notice.dart';
import 'package:celebray/features/messages/widgets/tone_picker.dart';
import 'package:celebray/features/generator/presentation/edit_message_screen.dart';
import 'package:celebray/features/reminders/presentation/add_event_sheet.dart';
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
  bool _showTutorial = false;
  int _tutorialStep = 0;
  String? _generationNotice;
  MessageGenerationSource? _generationSource;
  final _cardKey = GlobalKey();
  final _eventSelectorKey = GlobalKey();
  final _editEventKey = GlobalKey();
  final _tonePickerKey = GlobalKey();
  final _generateButtonKey = GlobalKey();
  late final ValueNotifier<String> _toneNotifier;

  late final List<TutorialStep> _tutorialSteps = buildGeneratorTutorialSteps(
    eventSelectorKey: _eventSelectorKey,
    editEventKey: _editEventKey,
    tonePickerKey: _tonePickerKey,
    generateButtonKey: _generateButtonKey,
  );

  @override
  void initState() {
    super.initState();
    _toneNotifier = ValueNotifier(MessageTones.defaultTone);
    _selectedEventId = widget.initialEvent?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
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

  Future<void> _maybeStartTutorial() async {
    if (await TutorialStorage.hasSeenGeneratorTutorial()) return;
    if (!mounted) return;

    final events = ref.read(eventProvider).value;
    if (events != null && events.isNotEmpty && _selectedEventId == null) {
      setState(() => _selectedEventId = events.first.id);
    }

    if (!mounted) return;
    setState(() => _showTutorial = true);
  }

  Future<void> _finishTutorial() async {
    await TutorialStorage.markGeneratorTutorialSeen();
    if (!mounted) return;
    setState(() => _showTutorial = false);
  }

  void _advanceTutorial() {
    if (_tutorialStep >= _tutorialSteps.length - 1) {
      _finishTutorial();
      return;
    }
    setState(() => _tutorialStep += 1);
  }

  void _editSelectedEvent(EventModel event) {
    showAddEventSheet(context, event: event);
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

    await _persistMessageAtIndex(event, 0);
  }

  Future<void> _persistMessageAtIndex(EventModel event, int index) async {
    if (index < 0 || index >= _messages.length) return;

    final message = _messages[index];
    if (message == event.generatedMessage) return;

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
  }

  void _openTouchUp(EventModel event) {
    final events = ref.read(eventProvider).value ?? [];
    var latest = event;
    for (final candidate in events) {
      if (candidate.id == event.id) {
        latest = candidate;
        break;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditMessageScreen(
          event: latest,
          navigateToShareOnSave: true,
          popExtraRouteOnShareSave: Navigator.of(context).canPop(),
        ),
      ),
    );
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

    return Stack(
      children: [
        Scaffold(
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
                  KeyedSubtree(
                    key: _eventSelectorKey,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedEvent?.id,
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
                  ),
                  if (selectedEvent != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: _editEventKey,
                      onPressed: () => _editSelectedEvent(selectedEvent),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit event details'),
                    ),
                  ],
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
                  TonePicker(
                    toneNotifier: _toneNotifier,
                    sectionKey: _tonePickerKey,
                  ),
                  const SizedBox(height: 20),
                  KeyedSubtree(
                    key: _generateButtonKey,
                    child: SizedBox(
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
                  ),
                  if (_messages.isNotEmpty && selectedEvent != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Pick a message',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RadioGroup<int>(
                      groupValue: _selectedMessageIndex,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedMessageIndex = value);
                        _persistMessageAtIndex(selectedEvent, value);
                      },
                      child: Column(
                        children: List.generate(_messages.length, (index) {
                          final selected = _selectedMessageIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.accentLight
                                    : AppTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.accent.withValues(alpha: 0.45)
                                      : AppTheme.border,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: RadioListTile<int>(
                                value: index,
                                title: Text(
                                  _messages[index],
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                activeColor: AppTheme.accent,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openTouchUp(selectedEvent),
                          icon: const Icon(Icons.auto_fix_high, size: 18),
                          label: const Text('Touch up'),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (shareContext) => ElevatedButton.icon(
                            onPressed: () =>
                                _shareCard(selectedEvent, shareContext),
                            icon: const Icon(Icons.ios_share, size: 18),
                            label: const Text('Share card'),
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
        ),
        if (_showTutorial)
          Positioned.fill(
            child: FeatureTutorialOverlay(
              steps: _tutorialSteps,
              stepIndex: _tutorialStep,
              onNext: _advanceTutorial,
              onSkip: _finishTutorial,
            ),
          ),
      ],
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
