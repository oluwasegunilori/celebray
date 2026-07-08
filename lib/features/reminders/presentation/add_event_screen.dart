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

enum _AddEventField { name, date, eventType, relationship, sex, closeness }

//Updates and adds new events
class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({
    super.key,
    this.event,
    this.initialData,
    this.scrollController,
  });

  final EventModel? event;
  final EventModel? initialData;
  final ScrollController? scrollController;

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameSectionKey = GlobalKey();
  final _memoriesSectionKey = GlobalKey();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final _nameFocusNode = FocusNode();
  final _memoriesFocusNode = FocusNode();
  final _dateFieldKey = GlobalKey<FormFieldState<String>>();
  final _eventTypeKey = GlobalKey();
  final _relationshipKey = GlobalKey();
  final _sexKey = GlobalKey();
  final _closenessKey = GlobalKey();
  final _eventTypeController = ExpansionTileController();
  final _relationshipController = ExpansionTileController();
  final _sexController = ExpansionTileController();
  final _faithController = ExpansionTileController();

  late String name;
  String? selectedType;
  String? selectedRelationship;
  String? selectedSex;
  String? selectedFaithContext;
  DateTime? date;
  String? memory;
  bool _eventTypeManuallySelected = false;
  _AddEventField? _highlightedField;

  final eventTypes = EventFormOptions.eventTypes;
  final relationships = EventFormOptions.relationships;
  final sexs = EventFormOptions.sexOptions;
  final faithContexts = EventFormOptions.faithContexts;

  Future<void> _promptCustomEventType() async {
    final value = await _promptCustomValue(
      title: 'Custom event type',
      hint: 'e.g. Quinceañera, Naming Ceremony',
      initial: selectedType != null && !eventTypes.contains(selectedType)
          ? selectedType
          : null,
    );
    if (value != null && value.isNotEmpty && mounted) {
      _selectEventType(value, manual: true);
    }
  }

  Future<void> _promptCustomRelationship() async {
    final value = await _promptCustomValue(
      title: 'Custom relationship',
      hint: 'e.g. Godparent, Roommate',
      initial: selectedRelationship != null &&
              !relationships.contains(selectedRelationship)
          ? selectedRelationship
          : null,
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

  void _selectEventType(String type, {required bool manual}) {
    setState(() {
      selectedType = type;
      if (manual) _eventTypeManuallySelected = true;
      _clearFieldError(_AddEventField.eventType);
    });
    _eventTypeController.collapse();
  }

  void _selectSex(String sex) {
    setState(() {
      selectedSex = sex;
      _clearFieldError(_AddEventField.sex);
    });
    _sexController.collapse();
  }

  void _selectFaithContext(String faith) {
    setState(() => selectedFaithContext = faith);
    _faithController.collapse();
  }

  void _maybeInferEventTypeFromName(String value) {
    if (_seed != null || _eventTypeManuallySelected) return;

    final inferred = EventFormOptions.inferEventTypeFromName(value);
    if (inferred == null || inferred == selectedType) return;

    setState(() {
      selectedType = inferred;
      _clearFieldError(_AddEventField.eventType);
    });
  }

  void _clearFieldError(_AddEventField field) {
    if (_highlightedField == field) {
      _highlightedField = null;
    }
  }

  void _selectRelationship(String relation) {
    setState(() {
      selectedRelationship = relation;
      final suggested = EventFormOptions.suggestedSexForRelationship(relation);
      if (suggested != null) {
        selectedSex = suggested;
        _clearFieldError(_AddEventField.sex);
      }
      _clearFieldError(_AddEventField.relationship);
    });
    _relationshipController.collapse();
  }

  double? closeness;

  List<String> memories = [];
  String? imagePath;

  final _imagePicker = ImagePicker();

  late TextEditingController eventNameController;
  late TextEditingController eventDateController;
  TextEditingController memoriesController = TextEditingController();

  EventModel? get _seed => widget.event;
  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final initialData = widget.initialData;

    eventNameController = TextEditingController(
      text: _seed?.name ?? initialData?.name ?? '',
    );
    eventDateController = TextEditingController(
      text: _seed != null
          ? dateFormatterDay.format(_seed!.date)
          : initialData != null
              ? dateFormatterDay.format(initialData.date)
              : '',
    );
    memories = List<String>.from(_seed?.memories ?? []);
    name = _seed?.name ?? initialData?.name ?? '';
    imagePath = _seed?.imagePath;

    if (_seed != null) {
      selectedType = _seed!.type;
      selectedRelationship = _seed!.relationship;
      selectedSex = _seed!.sex;
      selectedFaithContext = _seed!.faithContext.isNotEmpty
          ? _seed!.faithContext
          : null;
      closeness = _seed!.closeness.toDouble();
      date = _seed!.date;
      _eventTypeManuallySelected = true;
    } else if (initialData != null) {
      selectedType = initialData.type;
      date = initialData.date;
    }

    if (imagePath != null && !File(imagePath!).existsSync()) {
      imagePath = null;
    }

    if (_seed == null && selectedType == null) {
      final inferred = EventFormOptions.inferEventTypeFromName(
        eventNameController.text,
      );
      if (inferred != null) {
        selectedType = inferred;
      }
    }

    eventNameController.addListener(() {
      _maybeInferEventTypeFromName(eventNameController.text);
    });

    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        _scrollFocusedFieldIntoView(_nameSectionKey);
      }
    });
    _memoriesFocusNode.addListener(() {
      if (_memoriesFocusNode.hasFocus) {
        _scrollFocusedFieldIntoView(_memoriesSectionKey);
      }
    });
  }

  void _scrollFocusedFieldIntoView(GlobalKey fieldKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = fieldKey.currentContext;
      if (targetContext == null) return;

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.25,
      );
    });
  }

  @override
  void dispose() {
    eventNameController.dispose();
    eventDateController.dispose();
    memoriesController.dispose();
    _nameFocusNode.dispose();
    _memoriesFocusNode.dispose();
    _scrollController.dispose();
    _eventTypeController.dispose();
    _relationshipController.dispose();
    _sexController.dispose();
    _faithController.dispose();
    super.dispose();
  }

  _AddEventField? _firstInvalidField() {
    if (eventNameController.text.trim().isEmpty) {
      return _AddEventField.name;
    }
    if (date == null || eventDateController.text.trim().isEmpty) {
      return _AddEventField.date;
    }
    if (selectedType == null || selectedType!.trim().isEmpty) {
      return _AddEventField.eventType;
    }
    if (selectedRelationship == null || selectedRelationship!.trim().isEmpty) {
      return _AddEventField.relationship;
    }
    if (selectedSex == null || selectedSex!.trim().isEmpty) {
      return _AddEventField.sex;
    }
    if (closeness == null) {
      return _AddEventField.closeness;
    }
    return null;
  }

  String _missingFieldMessage(_AddEventField field) {
    switch (field) {
      case _AddEventField.name:
        return 'Please enter an event name.';
      case _AddEventField.date:
        return 'Please select an event date.';
      case _AddEventField.eventType:
        return 'Please select an event type.';
      case _AddEventField.relationship:
        return 'Please select a relationship.';
      case _AddEventField.sex:
        return 'Please select sex.';
      case _AddEventField.closeness:
        return 'Please choose how close you are to this person.';
    }
  }

  ExpansionTileController? _controllerForField(_AddEventField field) {
    switch (field) {
      case _AddEventField.eventType:
        return _eventTypeController;
      case _AddEventField.relationship:
        return _relationshipController;
      case _AddEventField.sex:
        return _sexController;
      case _AddEventField.name:
      case _AddEventField.date:
      case _AddEventField.closeness:
        return null;
    }
  }

  GlobalKey? _keyForField(_AddEventField field) {
    switch (field) {
      case _AddEventField.name:
        return _nameSectionKey;
      case _AddEventField.date:
        return _dateFieldKey;
      case _AddEventField.eventType:
        return _eventTypeKey;
      case _AddEventField.relationship:
        return _relationshipKey;
      case _AddEventField.sex:
        return _sexKey;
      case _AddEventField.closeness:
        return _closenessKey;
    }
  }

  void _scrollToField(_AddEventField field) {
    if (field == _AddEventField.name || field == _AddEventField.date) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }

    final targetContext = _keyForField(field)?.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.15,
    );
  }

  void _focusInvalidField(_AddEventField field) {
    if (field == _AddEventField.name || field == _AddEventField.date) {
      setState(() => _highlightedField = null);
    } else {
      setState(() => _highlightedField = field);
      _controllerForField(field)?.expand();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      switch (field) {
        case _AddEventField.name:
          _nameFieldKey.currentState?.validate();
        case _AddEventField.date:
          _dateFieldKey.currentState?.validate();
        case _AddEventField.eventType:
        case _AddEventField.relationship:
        case _AddEventField.sex:
        case _AddEventField.closeness:
          break;
      }

      _scrollToField(field);
    });
  }

  bool _validateInScreenOrder() {
    final invalid = _firstInvalidField();
    if (invalid == null) {
      if (_highlightedField != null) {
        setState(() => _highlightedField = null);
      }
      _formKey.currentState!.save();
      return true;
    }

    _focusInvalidField(invalid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_missingFieldMessage(invalid))),
    );
    return false;
  }

  List<String> _effectiveMemories() {
    final items = List<String>.from(memories);
    final pending = memoriesController.text.trim();
    if (pending.isNotEmpty && !items.contains(pending)) {
      items.add(pending);
    }
    return items;
  }

  EventModel _buildEventModel() {
    return EventModel(
      id: widget.event?.id ?? uniqueId(),
      name: name,
      type: selectedType!,
      date: date!,
      relationship: selectedRelationship!,
      memories: _effectiveMemories(),
      sex: selectedSex!,
      closeness: closeness!.round(),
      imagePath: _hasValidImage ? imagePath : null,
      generatedMessage: widget.event?.generatedMessage,
      faithContext: selectedFaithContext == null ||
              selectedFaithContext == 'None' ||
              selectedFaithContext!.trim().isEmpty
          ? ''
          : selectedFaithContext!,
    );
  }

  Future<bool> _confirmNewEventSummary(EventModel event) async {
    final faithLabel = event.faithContext.isEmpty
        ? 'Not specified'
        : event.faithContext;
    final additionalInfoLabel = event.memories.isEmpty
        ? 'None'
        : event.memories.join(', ');

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Review your event'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow('Name', event.name),
                  _summaryRow('Date', dateFormatterDay.format(event.date)),
                  _summaryRow('Type', event.type),
                  _summaryRow('Relationship', event.relationship),
                  _summaryRow('Sex', event.sex),
                  _summaryRow('Closeness', '${event.closeness}/10'),
                  _summaryRow('Faith context', faithLabel),
                  _summaryRow('Photo', _hasValidImage ? 'Added' : 'None'),
                  _summaryRow('Additional info', additionalInfoLabel),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Go back'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Save event'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredExpansionSection({
    required GlobalKey sectionKey,
    required _AddEventField field,
    required ExpansionTileController controller,
    required String title,
    String? selectedLabel,
    required Widget child,
  }) {
    final hasError = _highlightedField == field;

    return KeyedSubtree(
      key: sectionKey,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: hasError
              ? Border.all(color: Theme.of(context).colorScheme.error, width: 1.5)
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hasError ? 8 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppExpansionTile(
                controller: controller,
                title: _buildSectionTitle(
                  title,
                  selectedLabel: selectedLabel,
                  showError: hasError,
                ),
                child: child,
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    _missingFieldMessage(field),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionalExpansionSection({
    required ExpansionTileController controller,
    required String title,
    String? selectedLabel,
    required Widget child,
  }) {
    return AppExpansionTile(
      controller: controller,
      title: _buildSectionTitle(
        title,
        selectedLabel: selectedLabel,
      ),
      child: child,
    );
  }

  Widget _buildClosenessSection() {
    final hasError = _highlightedField == _AddEventField.closeness;

    return KeyedSubtree(
      key: _closenessKey,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: hasError
              ? Border.all(color: Theme.of(context).colorScheme.error, width: 1.5)
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(hasError ? 8 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(
                'How close are you to this person? (required)',
                showError: hasError,
              ),
              Row(
                children: [
                  const Text('1', style: TextStyle(fontSize: 12)),
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
                        value: closeness ?? 5,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: closeness?.round().toString() ?? '?',
                        onChanged: (v) => setState(() {
                          closeness = v;
                          _clearFieldError(_AddEventField.closeness);
                        }),
                      ),
                    ),
                  ),
                  const Text('10', style: TextStyle(fontSize: 12)),
                ],
              ),
              Center(
                child: Text(
                  closeness == null
                      ? 'Slide to choose (1–10)'
                      : 'Selected: ${closeness!.round()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: closeness == null
                        ? Colors.grey.shade600
                        : AppTheme.black,
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _missingFieldMessage(_AddEventField.closeness),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final scrollController = widget.scrollController ?? _scrollController;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 12 : 0),
                children: [
                  const SizedBox(height: 5),
                  KeyedSubtree(
                    key: _nameSectionKey,
                    child: _buildTextField(
                      fieldKey: _nameFieldKey,
                      controller: eventNameController,
                      focusNode: _nameFocusNode,
                      label: 'Event Name',
                    hint: "e.g. Mike's Birthday, Olu & Dara's Anniversary",
                    icon: Icons.event,
                    onSaved: (v) => name = v ?? '',
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter an event name'
                        : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      // 1️⃣ Pick the date
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: date != null
                              ? TimeOfDay.fromDateTime(date!)
                              : const TimeOfDay(hour: 0, minute: 0),
                        );

                        if (pickedTime != null) {
                          final pickedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          setState(() {
                            date = pickedDateTime;
                            _clearFieldError(_AddEventField.date);
                          });

                          // 4️⃣ Format nicely: Wed, May 24 – 3:30 PM
                          eventDateController.text = dateFormatterDay.format(
                            date!,
                          );
                        }
                      }
                    },

                    hoverColor: AppTheme.primary.withValues(alpha: 0.3),
                    highlightColor: AppTheme.primary.withValues(alpha: 0.3),
                    child: _buildTextField(
                      fieldKey: _dateFieldKey,
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
                        fallbackIcon: EventAvatar.iconForEventType(
                          selectedType ?? '',
                        ),
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
                  _buildRequiredExpansionSection(
                    sectionKey: _eventTypeKey,
                    field: _AddEventField.eventType,
                    controller: _eventTypeController,
                    title: 'Event Type (required)',
                    selectedLabel: selectedType,
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
                            onTap: () => _selectEventType(type, manual: true),
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
                  _buildRequiredExpansionSection(
                    sectionKey: _relationshipKey,
                    field: _AddEventField.relationship,
                    controller: _relationshipController,
                    title: 'Relationship (required)',
                    selectedLabel: selectedRelationship,
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
                  _buildRequiredExpansionSection(
                    sectionKey: _sexKey,
                    field: _AddEventField.sex,
                    controller: _sexController,
                    title: 'Sex (required)',
                    selectedLabel: selectedSex,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sexs.map((sex) {
                        final isSelected = selectedSex == sex;
                        return _SelectableChip(
                          label: sex,
                          isSelected: isSelected,
                          onTap: () => _selectSex(sex),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionalExpansionSection(
                    controller: _faithController,
                    title: 'Faith context (optional)',
                    selectedLabel: selectedFaithContext,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: faithContexts.map((faith) {
                        final isSelected = selectedFaithContext == faith;
                        return _SelectableChip(
                          label: faith,
                          isSelected: isSelected,
                          onTap: () => _selectFaithContext(faith),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildClosenessSection(),

                  const SizedBox(height: 20),
                  _buildSectionTitle('Additional info (optional)'),

                  Row(
                    children: [
                      Expanded(
                        child: KeyedSubtree(
                          key: _memoriesSectionKey,
                          child: _buildTextField(
                            controller: memoriesController,
                            focusNode: _memoriesFocusNode,
                            label: 'Add info',
                            hint: 'e.g. loves jazz, always late, favorite quote',
                            icon: Icons.book,
                            optional: true,
                            onSaved: (_) {},
                          ),
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
                if (!_validateInScreenOrder()) return;

                final event = _buildEventModel();

                if (_isEditing) {
                  await eventNotifier.updateEvent(event);
                } else {
                  final confirmed = await _confirmNewEventSummary(event);
                  if (!confirmed) return;
                  await eventNotifier.addEvent(event);
                }

                if (context.mounted) {
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

  Widget _buildSectionTitle(
    String title, {
    String? selectedLabel,
    bool showError = false,
  }) {
    final trimmedSelection = selectedLabel?.trim();
    final hasSelection =
        trimmedSelection != null && trimmedSelection.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: showError ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
                if (hasSelection)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      trimmedSelection,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showError)
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
        ],
      ),
    );
  }
}

Widget _buildTextField({
  Key? fieldKey,
  required String label,
  TextEditingController? controller,
  FocusNode? focusNode,
  String? hint,
  IconData? icon,
  bool optional = false,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
  bool editable = true,
}) {
  return TextFormField(
    key: fieldKey,
    controller: controller,
    focusNode: focusNode,
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
