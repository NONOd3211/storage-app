import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../view_models/item_view_model.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  late bool _warningEnabled;
  late bool _urgentEnabled;
  late bool _oneDayEnabled;
  late bool _dueDayEnabled;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    final settingsService = context.read<SettingsService>();
    _warningEnabled = settingsService.warningReminderEnabled;
    _urgentEnabled = settingsService.urgentReminderEnabled;
    _oneDayEnabled = settingsService.oneDayReminderEnabled;
    _dueDayEnabled = settingsService.dueDayReminderEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsService = context.read<SettingsService>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reminderSettings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.warningReminder),
            subtitle: Text(l10n.warningReminderSubtitle),
            value: _warningEnabled,
            onChanged: _updating
                ? null
                : (value) async {
                    setState(() => _warningEnabled = value);
                    await settingsService.setWarningReminderEnabled(value);
                    await _rescheduleIfNeeded(settingsService);
                  },
          ),
          SwitchListTile(
            title: Text(l10n.urgentReminder),
            subtitle: Text(l10n.urgentReminderSubtitle),
            value: _urgentEnabled,
            onChanged: _updating
                ? null
                : (value) async {
                    setState(() => _urgentEnabled = value);
                    await settingsService.setUrgentReminderEnabled(value);
                    await _rescheduleIfNeeded(settingsService);
                  },
          ),
          SwitchListTile(
            title: Text(l10n.oneDayReminder),
            value: _oneDayEnabled,
            onChanged: _updating
                ? null
                : (value) async {
                    setState(() => _oneDayEnabled = value);
                    await settingsService.setOneDayReminderEnabled(value);
                    await _rescheduleIfNeeded(settingsService);
                  },
          ),
          SwitchListTile(
            title: Text(l10n.dueDayReminder),
            value: _dueDayEnabled,
            onChanged: _updating
                ? null
                : (value) async {
                    setState(() => _dueDayEnabled = value);
                    await settingsService.setDueDayReminderEnabled(value);
                    await _rescheduleIfNeeded(settingsService);
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _rescheduleIfNeeded(SettingsService settingsService) async {
    if (!settingsService.notificationEnabled) return;
    setState(() => _updating = true);
    try {
      await context.read<ItemViewModel>().rescheduleAllNotifications();
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }
}
