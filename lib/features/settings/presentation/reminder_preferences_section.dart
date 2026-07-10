import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/notifications/reminder_preferences.dart';
import 'package:flutter/material.dart';

class ReminderPreferencesSection extends StatefulWidget {
  const ReminderPreferencesSection({
    super.key,
    required this.onChanged,
  });

  final Future<void> Function() onChanged;

  @override
  State<ReminderPreferencesSection> createState() =>
      _ReminderPreferencesSectionState();
}

class _ReminderPreferencesSectionState
    extends State<ReminderPreferencesSection> {
  ReminderPreferences? _prefs;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ReminderPreferences.load();
    if (mounted) setState(() => _prefs = prefs);
  }

  Future<void> _toggleOffset(ReminderOffset offset, bool enabled) async {
    final prefs = _prefs;
    if (prefs == null) return;

    final next = prefs.enabledOffsets.toSet();
    if (enabled) {
      next.add(offset);
    } else {
      next.remove(offset);
    }

    final updated = prefs.copyWith(enabledOffsets: next);
    await updated.save();
    if (mounted) setState(() => _prefs = updated);
    await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.schedule, color: AppTheme.primary),
          title: const Text('Reminder schedule'),
          subtitle: Text(
            prefs == null
                ? 'Loading…'
                : '${prefs.enabledOffsets.length} alerts enabled',
          ),
          trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded && prefs != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Column(
              children: ReminderOffset.values.map((offset) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(offset.settingsLabel),
                  value: prefs.isEnabled(offset),
                  activeColor: AppTheme.primary,
                  onChanged: (value) {
                    if (value == null) return;
                    _toggleOffset(offset, value);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
