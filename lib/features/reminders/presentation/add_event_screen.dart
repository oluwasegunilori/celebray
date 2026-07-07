import 'dart:io';

import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/events/domain/event_form_options.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/core/widgets/expansion_tile.dart';
import 'package:celebray/core/widgets/event_avatar.dart';
import 'package:celebray/core/utils/date_format.dart';
import 'package:celebray/core/utils/unique_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

//Updates and adds new events
class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key, this.event, this.initialData});

  final EventModel? event;
  final EventModel? initialData;

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String selectedType;
  late String selectedRelationship;
  late String selectedSex;
  late DateTime date;
  String? memory;

  final eventTypes = EventFormOptions.eventTypes;
  final relationships = EventFormOptions.relationships;
  final sexs = EventFormOptions.sexOptions;

  Future<void> _promptCustomEventType() async {
    final value = await _promptCustomValue(
      title: 'Custom event type',
      hint: 'e.g. Quinceañera, Naming Ceremony',
      initial: eventTypes.contains(selectedType) ? null : selectedType,
    );
    if (value != null && value.isNotEmpty && mounted) {
      setState(() => selectedType = value);
    }
  }

  Future<void> _promptCustomRelationship() async {
    final value = await _promptCustomValue(
      title: 'Custom relationship',
      hint: 'e.g. Godparent, Roommate',
      initial: relationships.contains(selectedRelationship)
          ? null
          : selectedRelationship,
    );
    if (value != null && value.isNotEmpty && mounted) {
      _selectRelationship(value);
    }
  }

  Future<String?> _promptCustomValue({
    required String title,
    required String hint,
    String? initial,
  }) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) {
              Navigator.pop(dialogContext, trimmed);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.pop(dialogContext, trimmed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _selectRelationship(String relation) {
    setState(() {
      selectedRelationship = relation;
      final suggested = EventFormOptions.suggestedSexForRelationship(relation);
      if (suggested != null) {
        selectedSex = suggested;
      }
    });
  }

  double closeness = 5;

  List<String> memories = [];
  String? imagePath;

  final _imagePicker = ImagePicker();

  late TextEditingController eventNameController;
  late TextEditingController eventDateController;
  TextEditingController memoriesController = TextEditingController();

  EventModel? get _seed => widget.event ?? widget.initialData;
  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController(text: _seed?.name ?? '');
    eventDateController = TextEditingController(
      text: _seed != null ? dateFormatterDay.format(_seed!.date) : '',
    );
    memories = _seed?.memories ?? [];
    selectedType = _seed?.type ?? eventTypes.first;
    selectedRelationship = _seed?.relationship ?? relationships.first;
    name = _seed?.name ?? '';
    date = _seed?.date ?? _atMidnight(DateTime.now());
    selectedSex = _seed?.sex ??
        EventFormOptions.suggestedSexForRelationship(selectedRelationship) ??
        sexs[0];
    closeness = _seed?.closeness.toDouble() ?? 5;
    imagePath = _seed?.imagePath;
    if (imagePath != null && !File(imagePath!).existsSync()) {
      imagePath = null;
    }
  }

  bool get _hasValidImage =>
      imagePath != null && File(imagePath!).existsSync();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => imagePath = picked.path);
    }
  }

  void _removeImage() => setState(() => imagePath = null);

  @override
  Widget build(BuildContext context) {
    final eventNotifier = ref.read(eventProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 5),
                  _buildTextField(
                    controller: eventNameController,
                    label: 'Event Name',
                    hint: "e.g. Mike's Birthday, Olu & Dara's Anniversary",
                    icon: Icons.event,
                    onSaved: (v) => name = v ?? '',
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter an event name'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      // 1️⃣ Pick the date
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _seed != null
                              ? TimeOfDay.fromDateTime(date)
                              : const TimeOfDay(hour: 0, minute: 0),
                        );

                        if (pickedTime != null) {
                          // 3️⃣ Combine date + time
                          final pickedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          setState(() => date = pickedDateTime);

                          // 4️⃣ Format nicely: Wed, May 24 – 3:30 PM
                          eventDateController.text = dateFormatterDay.format(
                            date,
                          );
                        }
                      }
                    },

                    hoverColor: AppTheme.primary.withValues(alpha: 0.3),
                    highlightColor: AppTheme.primary.withValues(alpha: 0.3),
                    child: _buildTextField(
                      label: 'Select the Event Date',
                      controller: eventDateController,
                      icon: Icons.edit_calendar,
                      onSaved: (v) => {},
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please Select a date'
                          : null,
                      editable: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Photo (optional)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      EventAvatar(
                        imagePath: _hasValidImage ? imagePath : null,
                        size: 72,
                        borderRadius: 12,
                        fallbackIcon: EventAvatar.iconForEventType(selectedType),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library, size: 18),
                              label: const Text('Gallery'),
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text('Camera'),
                            ),
                          ],
                        ),
                      ),
                      if (_hasValidImage)
                        IconButton(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Remove photo',
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppExpansionTile(
                    title: _buildSectionTitle('Event Type'),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...EventFormOptions.optionsWithCustom(
                          presets: eventTypes,
                          current: selectedType,
                        ).map((type) {
                          final isSelected = selectedType == type;
                          return _SelectableChip(
                            label: type,
                            isSelected: isSelected,
                            onTap: () => setState(() => selectedType = type),
                          );
                        }),
                        _SelectableChip(
                          label: EventFormOptions.addYoursLabel,
                          isSelected: false,
                          isAddOption: true,
                          onTap: _promptCustomEventType,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  AppExpansionTile(
                    title: _buildSectionTitle('Relationship'),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...EventFormOptions.optionsWithCustom(
                          presets: relationships,
                          current: selectedRelationship,
                        ).map((relation) {
                          final isSelected = selectedRelationship == relation;
                          return _SelectableChip(
                            label: relation,
                            isSelected: isSelected,
                            onTap: () => _selectRelationship(relation),
                          );
                        }),
                        _SelectableChip(
                          label: EventFormOptions.addYoursLabel,
                          isSelected: false,
                          isAddOption: true,
                          onTap: _promptCustomRelationship,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppExpansionTile(
                    title: _buildSectionTitle('Sex'),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sexs.map((sex) {
                        final isSelected = selectedSex == sex;
                        return _SelectableChip(
                          label: sex,
                          isSelected: isSelected,
                          onTap: () => setState(() => selectedSex = sex),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('How close are you to this person?'),
                  Row(
                    children: [
                      const Text("1", style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.primary,
                            inactiveTrackColor: AppTheme.primary.withValues(alpha: 0.3),
                            trackHeight: 6.0,
                            thumbColor: AppTheme.primaryDark,
                            overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                            valueIndicatorColor: AppTheme.primary,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 24,
                            ),
                          ),
                          child: Slider(
                            value: closeness,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: closeness.round().toString(),
                            onChanged: (v) => setState(() => closeness = v),
                          ),
                        ),
                      ),
                      const Text("10", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Center(
                    child: Text(
                      "Selected: ${closeness.round()}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle('Memories (optional)'),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: memoriesController,
                          label: 'Add Memory',
                          hint: "e.g. Karaoke night 🎤",
                          icon: Icons.book,
                          optional: true,
                          onSaved:
                              (
                                _,
                              ) {}, // not needed since we manage via controller
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final text = memoriesController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              memories.add(text);
                              memoriesController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: memories.map((m) {
                      return Chip(
                        label: Text(m),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() => memories.remove(m));
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isEditing ? 'Update Event' : 'Save Event',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final event = EventModel(
                    id: widget.event?.id ?? uniqueId(),
                    name: name,
                    type: selectedType,
                    date: date,
                    relationship: selectedRelationship,
                    memories: memories,
                    sex: selectedSex,
                    closeness: closeness.round(),
                    imagePath: _hasValidImage ? imagePath : null,
                    generatedMessage: widget.event?.generatedMessage,
                  );
                  if (_isEditing) {
                    await eventNotifier.updateEvent(event);
                  } else {
                    await eventNotifier.addEvent(event);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _buildTextField({
  required String label,
  TextEditingController? controller,
  String? hint,
  IconData? icon,
  bool optional = false,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
  bool editable = true,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: optional ? '$label (optional)' : label,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
      filled: true,
      fillColor: AppTheme.primaryLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabled: editable,
    ),
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    onSaved: onSaved,
    validator: validator,
  );
}

/// ✅ Custom Chip Widget with Checkmark
class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAddOption;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isAddOption = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedStyle = isAddOption
        ? BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accent, width: 1.5),
          )
        : BoxDecoration(
            color: isSelected ? AppTheme.black : AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: selectedStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAddOption) ...[
              const Icon(Icons.add, size: 16, color: AppTheme.accentDark),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isAddOption
                    ? AppTheme.black
                    : (isSelected ? Colors.white : AppTheme.black),
                fontWeight:
                    isSelected || isAddOption ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected && !isAddOption) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

DateTime _atMidnight(DateTime value) =>
    DateTime(value.year, value.month, value.day);
