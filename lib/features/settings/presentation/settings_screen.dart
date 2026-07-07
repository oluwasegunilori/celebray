import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/constants/app_constants.dart';
import 'package:celebray/features/calendar_import/widgets/calendar_import_sheet.dart';
import 'package:celebray/features/events/providers/event_provider.dart';
import 'package:celebray/features/auth/data/auth_service.dart';
import 'package:celebray/features/notifications/notification_service.dart';
import 'package:celebray/features/reminders/presentation/add_event_sheet.dart';
import 'package:celebray/features/settings/providers/settings_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _reminderDays = AppConstants.defaultReminderDaysBefore;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await NotificationService.areNotificationsEnabled();
    final days = await NotificationService.getReminderDaysBefore();
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _reminderDays = days;
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    }
  }

  Future<void> _rescheduleReminders() async {
    final events = ref.read(eventProvider).value;
    if (events != null) {
      await NotificationService.rescheduleAll(events);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will sign you out and remove your saved profile from this device. '
          'Your local events will remain on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (_) {
      await AuthService().signOut();
    }

    await AuthService().signOut();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted')),
      );
      ref.invalidate(currentUserProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          userAsync.when(
            data: (user) => user != null
                ? ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(user.name?.substring(0, 1).toUpperCase() ?? '?')
                          : null,
                    ),
                    title: Text(user.name ?? 'Signed in'),
                    subtitle: Text(user.email ?? ''),
                  )
                : const ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Not signed in'),
                    subtitle: Text('Sign in from onboarding to sync your profile'),
                  ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppTheme.primary),
            title: const Text('Notifications'),
            subtitle: const Text('Get reminded before celebrations'),
            value: _notificationsEnabled,
            activeThumbColor: AppTheme.primary,
            onChanged: (value) async {
              if (value) {
                await NotificationService.requestPermissions();
              }
              await NotificationService.setNotificationsEnabled(value);
              setState(() => _notificationsEnabled = value);
              if (value) await _rescheduleReminders();
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule, color: AppTheme.primary),
            title: const Text('Remind me before'),
            subtitle: Text('$_reminderDays days'),
            trailing: DropdownButton<int>(
              value: _reminderDays,
              items: const [1, 3, 7, 14, 30]
                  .map(
                    (d) => DropdownMenuItem(value: d, child: Text('$d days')),
                  )
                  .toList(),
              onChanged: (days) async {
                if (days == null) return;
                await NotificationService.setReminderDaysBefore(days);
                setState(() => _reminderDays = days);
                await _rescheduleReminders();
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_available, color: AppTheme.primary),
            title: const Text('Import from Calendar'),
            subtitle: const Text('Find birthdays and anniversaries to add'),
            onTap: () async {
              final draft = await CalendarImportSheet.show(context);
              if (draft != null && context.mounted) {
                showAddEventSheet(context, initialData: draft);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppTheme.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AppTheme.primary),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl(AppConstants.termsUrl),
          ),
          const Divider(),
          if (FirebaseAuth.instance.currentUser != null)
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.primary),
              title: const Text('Sign Out'),
              onTap: () async {
                await AuthService().signOut();
                ref.invalidate(currentUserProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out')),
                  );
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: _deleteAccount,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(_appVersion),
          ),
        ],
      ),
    );
  }
}
