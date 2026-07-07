import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/generator/presentation/generator_screen.dart';
import 'package:celebray/features/messages/message_generation_result.dart';
import 'package:celebray/features/messages/message_generator_service.dart';
import 'package:celebray/features/messages/widgets/message_generation_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditMessageScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EditMessageScreen({super.key, required this.event});

  @override
  ConsumerState<EditMessageScreen> createState() => _EditMessageScreenState();
}

class _EditMessageScreenState extends ConsumerState<EditMessageScreen> {
  late final TextEditingController _notesController;
  List<String> _suggestions = [];
  int _selectedIndex = 0;
  bool _showResults = false;
  bool _isTouchingUp = false;
  String? _touchUpNotice;
  MessageGenerationSource? _touchUpSource;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  EventModel get event => widget.event;

  String? get _currentMessage {
    final saved = event.generatedMessage?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    return null;
  }

  Future<void> _touchUp() async {
    final base = _currentMessage;
    if (base == null) return;

    setState(() {
      _isTouchingUp = true;
      _touchUpNotice = null;
      _touchUpSource = null;
    });

    final result = await MessageGeneratorService.touchUpMessage(
      event: event,
      currentMessage: base,
      instructions: _notesController.text,
    );

    if (!mounted) return;

    setState(() {
      _suggestions = result.messages;
      _selectedIndex = 0;
      _showResults = true;
      _isTouchingUp = false;
      _touchUpNotice = result.notice;
      _touchUpSource = result.source;
    });
  }

  Future<void> _saveSelected() async {
    if (_suggestions.isEmpty) return;

    final message = _suggestions[_selectedIndex];
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
        const SnackBar(content: Text('Message updated')),
      );
      Navigator.pop(context);
    }
  }

  void _startFresh() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GeneratorScreen(initialEvent: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch Up Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: current == null
          ? const Center(child: Text('No saved message to edit yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Your current message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    '"$current"',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'We know you love this — but what would you like to change or touch up?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Make it shorter, add more humor, mention our trip to Paris…',
                    filled: true,
                    fillColor: AppTheme.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                MessageGenerationNotice(
                  notice: _touchUpNotice,
                  source: _touchUpSource,
                  onSignedIn: () {
                    if (!mounted) return;
                    setState(() {
                      _touchUpNotice =
                          'Signed in. Tap Touch it up for AI-powered suggestions.';
                    });
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isTouchingUp ? null : _touchUp,
                    icon: _isTouchingUp
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(_isTouchingUp ? 'Working on it…' : 'Touch it up'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _startFresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate a whole new message'),
                  ),
                ),
                if (_showResults && _suggestions.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    _suggestions.length > 1
                        ? 'Pick your favorite version'
                        : 'Your updated message',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_suggestions.length > 1)
                    ...List.generate(_suggestions.length, (index) {
                      return RadioListTile<int>(
                        value: index,
                        groupValue: _selectedIndex,
                        onChanged: (value) =>
                            setState(() => _selectedIndex = value!),
                        title: Text(_suggestions[index]),
                        contentPadding: EdgeInsets.zero,
                      );
                    })
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        _suggestions.first,
                        style: const TextStyle(fontSize: 15, height: 1.45),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSelected,
                      child: const Text('Save Message'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
