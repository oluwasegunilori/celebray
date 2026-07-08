import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/calendar_import/widgets/calendar_import_sheet.dart';
import 'package:celebray/features/reminders/presentation/add_event_sheet.dart';
import 'package:flutter/material.dart';

enum _ToolbarMenuAction { importCalendar }

class HomeToolbarActions extends StatelessWidget {
  final GlobalKey? settingsKey;

  const HomeToolbarActions({super.key, this.settingsKey});

  static Future<void> openCalendarImport(BuildContext context) async {
    final draft = await CalendarImportSheet.show(context);
    if (draft != null && context.mounted) {
      showAddEventSheet(context, initialData: draft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: settingsKey,
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        PopupMenuButton<_ToolbarMenuAction>(
          tooltip: 'More options',
          icon: const Icon(Icons.more_vert),
          onSelected: (action) {
            switch (action) {
              case _ToolbarMenuAction.importCalendar:
                openCalendarImport(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _ToolbarMenuAction.importCalendar,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.event_available_outlined,
                  color: AppTheme.primary,
                ),
                title: Text('Import from my calendar'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
