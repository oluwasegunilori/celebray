import 'dart:io';

import 'package:celebray/app_theme.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/reminders/domain/event_model.dart';
import 'package:celebray/features/reminders/ui/ui_utils/custom_designs.dart';
import 'package:celebray/utils/date_format.dart';
import 'package:celebray/utils/unique_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

//Updates and adds new events
class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key, this.event});

  final EventModel? event;

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

  final List<String> eventTypes = [
    'Birthday',
    'Anniversary',
    'Graduation',
    'Promotion',
    'Wedding',
    'Engagement',
    'New Baby',
    'Housewarming',
    'Farewell',
  ];

  final List<String> relationships = [
    'Wife',
    'Husband',
    'Boyfriend',
    'Girlfriend',
    'Friend',
    'Family',
    'Colleague',
    'Best Friend',
    'Brother',
    'Sister',
    'Parent',
    'Child',
    'Partner',
    'Neighbor',
  ];

  final List<String> sexs = ['Male', 'Female', 'Other'];

  double closeness = 5;

  List<String> memories = [];
  String? imagePath;

  final _imagePicker = ImagePicker();

  late TextEditingController eventNameController;
  late TextEditingController eventDateController;
  TextEditingController memoriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController(text: widget.event?.name ?? '');
    eventDateController = TextEditingController(
      text: widget.event != null
          ? dateFormatterDay.format(widget.event!.date)
          : '',
    );
    memories = widget.event?.memories ?? [];
    selectedType = widget.event?.type ?? eventTypes[0];
    selectedRelationship = widget.event?.relationship ?? relationships[0];
    name = widget.event?.name ?? '';
    date = widget.event?.date ?? DateTime.now();
    selectedSex = widget.event?.sex ?? sexs[0];
    closeness = widget.event?.closeness.toDouble() ?? 5;
    imagePath = widget.event?.imagePath;
  }

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
                        // 2️⃣ Pick the time
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(date),
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
                      if (imagePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(imagePath!),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, color: AppTheme.primary),
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
                      if (imagePath != null)
                        IconButton(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Remove photo',
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomExpansionTile(
                    title: _buildSectionTitle('Event Type'),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: eventTypes.map((type) {
                        final isSelected = selectedType == type;
                        return _SelectableChip(
                          label: type,
                          isSelected: isSelected,
                          onTap: () => setState(() => selectedType = type),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  CustomExpansionTile(
                    title: _buildSectionTitle('Relationship'),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: relationships.map((relation) {
                        final isSelected = selectedRelationship == relation;
                        return _SelectableChip(
                          label: relation,
                          isSelected: isSelected,
                          onTap: () =>
                              setState(() => selectedRelationship = relation),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomExpansionTile(
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
                widget.event != null ? 'Update Event' : 'Save Event',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
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
                    imagePath: imagePath,
                    generatedMessage: widget.event?.generatedMessage,
                  );
                  if (widget.event != null) {
                    eventNotifier.updateEvent(event);
                  } else {
                    eventNotifier.addEvent(event);
                  }
                  Navigator.pop(context);
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

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
