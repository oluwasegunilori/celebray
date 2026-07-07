import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/utils/date_format.dart';
import 'package:celebray/features/calendar_import/calendar_import_service.dart';
import 'package:celebray/features/calendar_import/domain/calendar_suggestion.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarImportSheet extends ConsumerStatefulWidget {
  const CalendarImportSheet({super.key});

  static Future<EventModel?> show(BuildContext context) {
    return showModalBottomSheet<EventModel?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CalendarImportSheet(),
    );
  }

  @override
  ConsumerState<CalendarImportSheet> createState() =>
      _CalendarImportSheetState();
}

class _CalendarImportSheetState extends ConsumerState<CalendarImportSheet> {
  CalendarImportResult? _result;
  final Set<String> _selectedKeys = {};
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSuggestions());
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _result = const CalendarImportResult(status: CalendarImportStatus.loading);
      _selectedKeys.clear();
    });

    final existing = ref.read(eventProvider).value ?? [];
    final result = await CalendarImportService.fetchSuggestions(
      existingEvents: existing,
    );

    if (!mounted) return;

    setState(() {
      _result = result;
      if (result.status == CalendarImportStatus.ready) {
        _selectedKeys.addAll(result.suggestions.map((s) => s.dedupeKey));
      }
    });
  }

  Future<void> _importSelected() async {
    final result = _result;
    if (result == null || result.status != CalendarImportStatus.ready) return;

    final selected = result.suggestions
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

  void _customizeSuggestion(CalendarSuggestion suggestion) {
    Navigator.pop(context, suggestion.toDraftEvent());
  }

  Future<void> _openSettings() async {
    await CalendarImportService.openAppSettings();
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
                        'Import from Calendar',
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
                  'We scan your calendar for birthdays and anniversaries you have not added yet.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(scrollController)),
              if (_result?.status == CalendarImportStatus.ready)
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
        result.status == CalendarImportStatus.loading ||
        _isImporting) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (result.status) {
      case CalendarImportStatus.ready:
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: result.suggestions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final suggestion = result.suggestions[index];
            final selected = _selectedKeys.contains(suggestion.dedupeKey);

            return Material(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _customizeSuggestion(suggestion),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                              '${suggestion.type} · ${dateFormatterDay.format(suggestion.date)}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            if (suggestion.sourceTitle != suggestion.name)
                              Text(
                                suggestion.sourceTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Customize before adding',
                        onPressed: () => _customizeSuggestion(suggestion),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      case CalendarImportStatus.permissionDenied:
        return _MessageState(
          scrollController: scrollController,
          icon: Icons.event_busy_outlined,
          title: 'Calendar access needed',
          message: result.message ??
              'Allow calendar access so Celebray can suggest celebrations to add.',
          primaryLabel: 'Open Settings',
          onPrimary: _openSettings,
          secondaryLabel: 'Try Again',
          onSecondary: _loadSuggestions,
        );
      case CalendarImportStatus.unsupported:
      case CalendarImportStatus.empty:
      case CalendarImportStatus.error:
        return _MessageState(
          scrollController: scrollController,
          icon: result.status == CalendarImportStatus.empty
              ? Icons.search_off_outlined
              : Icons.info_outline,
          title: result.status == CalendarImportStatus.empty
              ? 'Nothing new to import'
              : 'Could not import',
          message: result.message ?? 'Please try again later.',
          primaryLabel: 'Try Again',
          onPrimary: _loadSuggestions,
        );
      case CalendarImportStatus.loading:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImportBar() {
    final count = _selectedKeys.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            TextButton(
              onPressed: count == _result!.suggestions.length
                  ? () => setState(() => _selectedKeys.clear())
                  : () => setState(
                      () => _selectedKeys.addAll(
                        _result!.suggestions.map((s) => s.dedupeKey),
                      ),
                    ),
              child: Text(
                count == _result!.suggestions.length
                    ? 'Clear all'
                    : 'Select all',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: count == 0 || _isImporting ? null : _importSelected,
              child: Text(
                count == 0
                    ? 'Add selected'
                    : count == 1
                        ? 'Add 1 celebration'
                        : 'Add $count celebrations',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final ScrollController scrollController;
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(32),
      children: [
        Icon(icon, size: 56, color: AppTheme.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onPrimary, child: Text(primaryLabel)),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onSecondary,
            child: Text(secondaryLabel!),
          ),
        ],
      ],
    );
  }
}
