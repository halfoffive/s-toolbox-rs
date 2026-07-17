import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../theme/app_theme.dart';
import '../features/calculator/calculator_page.dart';

/// 应用根 widget
///
/// 监听 [AppSettings] 主题模式变化，在 AppBar 提供切换入口
class ToolboxApp extends StatefulWidget {
  final AppSettings settings;
  const ToolboxApp({super.key, required this.settings});

  @override
  State<ToolboxApp> createState() => _ToolboxAppState();
}

class _ToolboxAppState extends State<ToolboxApp> {
  late final AppSettings _settings = widget.settings;

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeModeOption>(
      valueListenable: _settings,
      builder: (context, option, _) {
        return MaterialApp(
          title: 's-toolbox-rs',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: toFlutterThemeMode(option),
          home: _HomeShell(settings: _settings),
        );
      },
    );
  }
}

/// 首页外壳：预留工具切换位（首版仅计算器），右上角主题切换
class _HomeShell extends StatelessWidget {
  final AppSettings settings;
  const _HomeShell({required this.settings});

  @override
  Widget build(BuildContext context) {
    return CalculatorPageWithTheme(settings: settings);
  }
}

/// 把主题切换入口注入计算器 AppBar
class CalculatorPageWithTheme extends StatelessWidget {
  final AppSettings settings;
  const CalculatorPageWithTheme({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CalculatorPage(),
        Positioned(
          top: 0,
          right: 0,
          child: _ThemeModeButton(settings: settings),
        ),
      ],
    );
  }
}

/// 主题模式切换按钮 + 弹出菜单
class _ThemeModeButton extends StatelessWidget {
  final AppSettings settings;
  const _ThemeModeButton({required this.settings});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeModeOption>(
      valueListenable: settings,
      builder: (context, option, _) {
        return PopupMenuButton<ThemeModeOption>(
          icon: Icon(_iconFor(option)),
          tooltip: '主题模式',
          onSelected: settings.setThemeMode,
          itemBuilder: (context) => [
            _item(ThemeModeOption.light, '浅色', Icons.light_mode_outlined, option),
            _item(ThemeModeOption.dark, '深色', Icons.dark_mode_outlined, option),
            _item(ThemeModeOption.system, '跟随系统', Icons.settings_brightness, option),
          ],
        );
      },
    );
  }

  IconData _iconFor(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.light:
        return Icons.light_mode_outlined;
      case ThemeModeOption.dark:
        return Icons.dark_mode_outlined;
      case ThemeModeOption.system:
        return Icons.settings_brightness;
    }
  }

  PopupMenuItem<ThemeModeOption> _item(
    ThemeModeOption value,
    String label,
    IconData icon,
    ThemeModeOption current,
  ) {
    return PopupMenuItem<ThemeModeOption>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          if (value == current)
            const Icon(Icons.check, size: 18),
        ],
      ),
    );
  }
}
