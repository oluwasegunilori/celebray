import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/utils/date_format.dart';
import 'package:celebray/features/contacts_import/contacts_import_service.dart';
import 'package:celebray/features/contacts_import/domain/contact_suggestion.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/reminders/presentation/add_event_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactsImportSheet extends ConsumerStatefulWidget {
  const ContactsImportSheet({super.key});

  static Future<EventModel?> show(BuildContext context) {
    return showModalBottomSheet<EventModel?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ContactsImportSheet(),
    );
  }

  @override
  ConsumerState<ContactsImportSheet> createState() =>
      _ContactsImportSheetState();
}

class _ContactsImportSheetState extends ConsumerState<ContactsImportSheet> {
  ContactImportResult? _result;
  final Set<String> _selectedKeys = {};
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSuggestions());
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _result = const ContactImportResult(status: ContactImportStatus.loading);
      _selectedKeys.clear();
    });

    final existing = ref.read(eventProvider).value ?? [];
    final result = await ContactsImportService.fetchSuggestions(
      existingEvents: existing,
    );

    if (!mounted) return;

    setState(() {
      _result = result;
      if (result.status == ContactImportStatus.ready) {
        _selectedKeys.addAll(result.allBirthdaySuggestions.map((s) => s.dedupeKey));
      }
    });
  }

  Future<void> _importSelected() async {
    final result = _result;
    if (result == null || result.status != ContactImportStatus.ready) return;

    final selected = result.allBirthdaySuggestions
        .where((s) => _selectedKeys.contains(s.dedupeKey))
        .toList();
    if (selected.isEmpty) return;

    setState(() => _isImporting = true);

    final notifier = ref.read(eventProvider.notifier);
    for (final suggestion in selected) {
      await notifier.addEvent(suggestion.toDraftEvent());
    }

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selected.length == 1
              ? 'Added 1 celebration'
              : 'Added ${selected.length} celebrations',
        ),
      ),
    );
  }

  void _openSuggestion(ContactSuggestion suggestion) {
    if (suggestion.hasBirthday) {
      Navigator.pop(context, suggestion.toDraftEvent());
      return;
    }

    Navigator.pop(context);
    showAddEventSheet(
      context,
      initialData: suggestion.toNamePrefillDraft(),
      prefillNameOnly: true,
    );
  }

  Future<void> _openSettings() async {
    await ContactsImportService.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Import from Contacts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Birthdays import in one tap. For everyone else, tap a name '
                  'and add their celebration date.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(scrollController)),
              if (_result?.status == ContactImportStatus.ready &&
                  _result!.hasBirthdays)
                _buildImportBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    final result = _result;

    if (result == null ||
        result.status == ContactImportStatus.loading ||
        _isImporting) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (result.status) {
      case ContactImportStatus.ready:
        final items = <Widget>[];

        if (result.frequentSuggestions.isNotEmpty) {
          items.add(_sectionHeader('Frequently in touch · birthdays'));
          for (final suggestion in result.frequentSuggestions) {
            items.add(_birthdayTile(suggestion, highlight: true));
          }
        }

        if (result.suggestions.isNotEmpty) {
          items.add(_sectionHeader('All birthdays'));
          for (final suggestion in result.suggestions) {
            items.add(_birthdayTile(suggestion));
          }
        }

        if (result.frequentNamePrefills.isNotEmpty) {
          items.add(_sectionHeader('Frequently in touch · add date'));
          for (final suggestion in result.frequentNamePrefills) {
            items.add(_namePrefillTile(suggestion, highlight: true));
          }
        }

        if (result.namePrefills.isNotEmpty) {
          items.add(_sectionHeader('Add their celebration date'));
          for (final suggestion in result.namePrefills) {
            items.add(_namePrefillTile(suggestion));
          }
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 16),
          children: items,
        );
      case ContactImportStatus.permissionDenied:
        return _MessageState(
          scrollController: scrollController,
          icon: Icons.contacts_outlined,
          title: 'Contacts access needed',
          message: result.message ??
              'Allow contacts access so Celebray can suggest birthdays to add.',
          primaryLabel: 'Open Settings',
          onPrimary: _openSettings,
          secondaryLabel: 'Try Again',
          onSecondary: _loadSuggestions,
        );
      case ContactImportStatus.unsupported:
      case ContactImportStatus.empty:
      case ContactImportStatus.error:
        return _MessageState(
          scrollController: scrollController,
          icon: Icons.person_search_outlined,
          title: result.status == ContactImportStatus.empty
              ? 'Nothing new to add'
              : 'Could not import',
          message: result.message ?? 'Something went wrong.',
          primaryLabel: 'Try Again',
          onPrimary: _loadSuggestions,
        );
      case ContactImportStatus.loading:
        return const SizedBox.shrink();
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _birthdayTile(ContactSuggestion suggestion, {bool highlight = false}) {
    final selected = _selectedKeys.contains(suggestion.dedupeKey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: highlight
            ? AppTheme.primary.withValues(alpha: 0.08)
            : AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openSuggestion(suggestion),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: selected,
                  activeColor: AppTheme.primary,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedKeys.add(suggestion.dedupeKey);
                      } else {
                        _selectedKeys.remove(suggestion.dedupeKey);
                      }
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Birthday · ${dateFormatterDay.format(suggestion.date!)}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Customize before adding',
                  onPressed: () => _openSuggestion(suggestion),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _namePrefillTile(
    ContactSuggestion suggestion, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: highlight
            ? AppTheme.primary.withValues(alpha: 0.08)
            : AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openSuggestion(suggestion),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No birthday saved — tap to add date',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImportBar() {
    final count = _selectedKeys.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: count == 0 ? null : _importSelected,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  count == 0
                      ? 'Select celebrations to add'
                      : count == 1
                          ? 'Add 1 celebration'
                          : 'Add $count celebrations',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.scrollController,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final ScrollController scrollController;
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        Icon(icon, size: 48, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
        ],
      ],
    );
  }
}
