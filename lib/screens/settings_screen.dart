import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../view_models/item_view_model.dart';
import '../view_models/settings_view_model.dart';
import '../widgets/limited_text_context_menu.dart';
import 'reminder_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

enum _ThresholdType { warning, urgent }

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  late int _warningDays;
  late int _urgentDays;
  late bool _notificationEnabled;
  late AppLanguageMode _languageMode;
  late Locale _manualLocale;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    final settingsService = context.read<SettingsService>();
    final settingsViewModel = context.read<SettingsViewModel>();

    _themeMode = settingsService.themeMode;
    _warningDays = settingsService.warningDays;
    _urgentDays = settingsService.urgentDays;
    _notificationEnabled = settingsService.notificationEnabled;
    _languageMode = settingsViewModel.languageMode;
    _manualLocale = settingsViewModel.manualLocale;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsService = context.read<SettingsService>();
    final itemViewModel = context.read<ItemViewModel>();
    final notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.sectionAppearance),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeModeText(l10n, _themeMode)),
            onTap: _showThemeDialog,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_getLanguageText(l10n)),
            onTap: _showLanguageDialog,
          ),
          const Divider(),
          _buildSectionHeader(l10n.sectionExpirationReminder),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(l10n.notificationEnabled),
            subtitle: Text(
              _notificationEnabled ? l10n.statusEnabled : l10n.statusDisabled,
            ),
            value: _notificationEnabled,
            onChanged: (value) async {
              setState(() => _notificationEnabled = value);
              await settingsService.setNotificationEnabled(value);
              if (value) {
                await itemViewModel.rescheduleAllNotifications();
              } else {
                await notificationService.cancelAllNotifications();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(l10n.reminderSettings),
            subtitle: Text(
              _notificationEnabled
                  ? l10n.configureReminderSwitches
                  : l10n.enableNotificationsFirst,
            ),
            enabled: _notificationEnabled,
            onTap: _notificationEnabled
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReminderSettingsScreen(),
                      ),
                    );
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: Text(l10n.warningReminder),
            subtitle: Text('$_warningDays ${l10n.daysSuffix}'),
            onTap: () => _showDaysDialog(
              title: l10n.warningDialogTitle,
              currentValue: _warningDays,
              type: _ThresholdType.warning,
              onSave: (value) async {
                await _saveThreshold(
                  days: value,
                  onLocalSet: () => setState(() => _warningDays = value),
                  onPersist: () => settingsService.setWarningDays(value),
                  itemViewModel: itemViewModel,
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: Text(l10n.urgentReminder),
            subtitle: Text('$_urgentDays ${l10n.daysSuffix}'),
            onTap: () => _showDaysDialog(
              title: l10n.urgentDialogTitle,
              currentValue: _urgentDays,
              type: _ThresholdType.urgent,
              onSave: (value) async {
                await _saveThreshold(
                  days: value,
                  onLocalSet: () => setState(() => _urgentDays = value),
                  onPersist: () => settingsService.setUrgentDays(value),
                  itemViewModel: itemViewModel,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.thresholdNote,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const Divider(),
          _buildSectionHeader(l10n.sectionAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appTitle),
            subtitle: Text(
              _appVersion.isEmpty
                  ? l10n.versionLoading
                  : l10n.versionPrefix(_appVersion),
            ),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _getThemeModeText(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }

  String _getLanguageText(AppLocalizations l10n) {
    if (_languageMode == AppLanguageMode.system) {
      return l10n.languageFollowSystem;
    }
    if (_manualLocale.languageCode == 'zh' &&
        _manualLocale.countryCode == 'TW') {
      return l10n.languageTraditionalChinese;
    }
    if (_manualLocale.languageCode == 'en') {
      return l10n.languageEnglish;
    }
    return l10n.languageSimplifiedChinese;
  }

  void _showThemeDialog() {
    final l10n = AppLocalizations.of(context)!;
    final settingsViewModel = context.read<SettingsViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final selected = _themeMode == mode;
            return ListTile(
              title: Text(_getThemeModeText(l10n, mode)),
              trailing: selected ? const Icon(Icons.check) : null,
              onTap: () async {
                setState(() => _themeMode = mode);
                await settingsViewModel.setThemeMode(mode);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.themeUpdated)));
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final settingsViewModel = context.read<SettingsViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              title: l10n.languageFollowSystem,
              selected: _languageMode == AppLanguageMode.system,
              onTap: () async {
                setState(() => _languageMode = AppLanguageMode.system);
                await settingsViewModel.setLanguageFollowSystem();
                await _rescheduleNotificationsAfterLanguageChanged();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.languageUpdated)));
              },
            ),
            _buildLanguageOption(
              title: l10n.languageSimplifiedChinese,
              selected:
                  _languageMode == AppLanguageMode.manual &&
                  _manualLocale.languageCode == 'zh' &&
                  (_manualLocale.countryCode == 'CN' ||
                      _manualLocale.countryCode == null),
              onTap: () async {
                const locale = Locale('zh', 'CN');
                setState(() {
                  _languageMode = AppLanguageMode.manual;
                  _manualLocale = locale;
                });
                await settingsViewModel.setManualLanguage(locale);
                await _rescheduleNotificationsAfterLanguageChanged();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.languageUpdated)));
              },
            ),
            _buildLanguageOption(
              title: l10n.languageTraditionalChinese,
              selected:
                  _languageMode == AppLanguageMode.manual &&
                  _manualLocale.languageCode == 'zh' &&
                  _manualLocale.countryCode == 'TW',
              onTap: () async {
                const locale = Locale('zh', 'TW');
                setState(() {
                  _languageMode = AppLanguageMode.manual;
                  _manualLocale = locale;
                });
                await settingsViewModel.setManualLanguage(locale);
                await _rescheduleNotificationsAfterLanguageChanged();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.languageUpdated)));
              },
            ),
            _buildLanguageOption(
              title: l10n.languageEnglish,
              selected:
                  _languageMode == AppLanguageMode.manual &&
                  _manualLocale.languageCode == 'en',
              onTap: () async {
                const locale = Locale('en');
                setState(() {
                  _languageMode = AppLanguageMode.manual;
                  _manualLocale = locale;
                });
                await settingsViewModel.setManualLanguage(locale);
                await _rescheduleNotificationsAfterLanguageChanged();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.languageUpdated)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }

  void _showDaysDialog({
    required String title,
    required int currentValue,
    required _ThresholdType type,
    required Future<void> Function(int) onSave,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          contextMenuBuilder: buildLimitedTextContextMenu,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.dayLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                final error = _validateThresholdInput(type: type, value: value);
                if (error != null) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                await onSave(value);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;

    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: _appVersion.isEmpty ? '1.0.0' : _appVersion,
      applicationIcon: const Icon(
        Icons.inventory_2,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        Text(l10n.aboutDescriptionLine1),
        const SizedBox(height: 8),
        Text(l10n.aboutDescriptionLine2),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          l10n.featureTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(l10n.featureItem1),
        Text(l10n.featureItem2),
        Text(l10n.featureItem3),
        Text(l10n.featureItem4),
        Text(l10n.featureItem5),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Ice Wraith'),
      ],
    );
  }

  Future<void> _saveThreshold({
    required int days,
    required VoidCallback onLocalSet,
    required Future<void> Function() onPersist,
    required ItemViewModel itemViewModel,
  }) async {
    onLocalSet();
    await onPersist();
    itemViewModel.refreshComputedState();
    await itemViewModel.rescheduleAllNotifications();
  }

  String? _validateThresholdInput({
    required _ThresholdType type,
    required int value,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (type == _ThresholdType.warning && value <= _urgentDays) {
      return l10n.warningValidation(_urgentDays);
    }
    if (type == _ThresholdType.urgent && value >= _warningDays) {
      return l10n.urgentValidation(_warningDays);
    }
    return null;
  }

  Future<void> _rescheduleNotificationsAfterLanguageChanged() async {
    final settingsService = context.read<SettingsService>();
    if (!settingsService.notificationEnabled) return;
    await context.read<ItemViewModel>().rescheduleAllNotifications();
  }
}
