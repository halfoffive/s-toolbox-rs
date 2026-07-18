import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings/app_settings.dart';
import '../theme/app_theme.dart';

/// 全局共享左侧抽屉
///
/// 头部展示应用名 + 版本号；设置区内联展示主题模式选项（[RadioListTile]）；
/// 底部提供 GitHub 仓库链接。后续可在设置区直接追加更多选项。
class ToolboxDrawer extends StatelessWidget {
  const ToolboxDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  's-toolbox-rs',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '设置',
              style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
          ValueListenableBuilder<ThemeModeOption>(
            valueListenable: AppSettings.instance,
            builder: (context, option, _) {
              return RadioGroup<ThemeModeOption>(
                groupValue: option,
                onChanged: (v) {
                  if (v != null) AppSettings.instance.setThemeMode(v);
                },
                child: Column(
                  children: [
                    RadioListTile<ThemeModeOption>(
                      value: ThemeModeOption.light,
                      secondary: const Icon(Icons.light_mode_outlined),
                      title: const Text('浅色'),
                    ),
                    RadioListTile<ThemeModeOption>(
                      value: ThemeModeOption.dark,
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('深色'),
                    ),
                    RadioListTile<ThemeModeOption>(
                      value: ThemeModeOption.system,
                      secondary: const Icon(Icons.settings_brightness),
                      title: const Text('跟随系统'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('GitHub 仓库'),
            subtitle: const Text('halfoffive/s-toolbox-rs'),
            onTap: () => _launchGitHub(context),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHub(BuildContext context) async {
    final uri = Uri.parse('https://github.com/halfoffive/s-toolbox-rs');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开链接：$uri')),
      );
    }
  }
}
