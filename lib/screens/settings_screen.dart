import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  late int _warningDays;
  late int _urgentDays;
  late bool _notificationEnabled;

  @override
  void initState() {
    super.initState();
    _themeMode = settingsService.themeMode;
    _warningDays = settingsService.warningDays;
    _urgentDays = settingsService.urgentDays;
    _notificationEnabled = settingsService.notificationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 主题设置（皮肤）
          _buildSectionHeader('外观'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('皮肤'),
            subtitle: Text(_getThemeModeText(_themeMode)),
            onTap: _showThemeDialog,
          ),
          const Divider(),

          // 保质期阈值设置
          _buildSectionHeader('保质期提醒'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('启用通知'),
            subtitle: Text(_notificationEnabled ? '已开启' : '已关闭'),
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() => _notificationEnabled = value);
              settingsService.setNotificationEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('即将过期提醒'),
            subtitle: Text('$_warningDays 天'),
            onTap: () => _showDaysDialog('即将过期提醒 (天)', _warningDays, (value) {
              setState(() => _warningDays = value);
              settingsService.setWarningDays(value);
            }),
          ),
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text('紧急提醒'),
            subtitle: Text('$_urgentDays 天'),
            onTap: () => _showDaysDialog('紧急提醒 (天)', _urgentDays, (value) {
              setState(() => _urgentDays = value);
              settingsService.setUrgentDays(value);
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '注：保质期小于紧急天数显示为红色，小于即将过期天数显示为橙色',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const Divider(),

          // 关于
          _buildSectionHeader('关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('收纳'),
            subtitle: const Text('版本 1.1.5'),
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

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('选择皮肤'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeText(mode)),
              value: mode,
              groupValue: _themeMode,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _themeMode = value);
                  settingsService.setThemeMode(value);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('皮肤已更改，重启后生效'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDaysDialog(String title, int currentValue, Function(int) onSave) {
    final controller = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '天数',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                onSave(value);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '收纳',
      applicationVersion: '1.1.5',
      applicationIcon: const Icon(
        Icons.inventory_2,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        const Text('一款简洁的物品收纳管理应用'),
        const SizedBox(height: 8),
        const Text('帮助您管理物品位置和保质期'),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          '功能介绍',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('• 物品管理（添加、编辑、删除）'),
        const Text('• 位置管理（预设+自定义位置）'),
        const Text('• 保质期追踪（智能状态提醒）'),
        const Text('• 分类筛选'),
        const Text('• 数据统计'),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text('作者：NONOd'),
      ],
    );
  }
}
