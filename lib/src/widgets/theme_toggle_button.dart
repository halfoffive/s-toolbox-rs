import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../theme/app_theme.dart';

/// 主题切换单按钮
///
/// 点击三态循环 light → dark → system → light（见 [AppSettings.cycleThemeMode]）。
/// 图标随当前模式变化，通过 [AnimatedSwitcher] 实现 fade + scale 组合动画。
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeModeOption>(
      valueListenable: AppSettings.instance,
      builder: (context, option, _) {
        return IconButton(
          tooltip: _labelFor(option),
          onPressed: AppSettings.instance.cycleThemeMode,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Icon(_iconFor(option), key: ValueKey(option)),
          ),
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

  String _labelFor(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.light:
        return '当前：浅色（点击切换）';
      case ThemeModeOption.dark:
        return '当前：深色（点击切换）';
      case ThemeModeOption.system:
        return '当前：跟随系统（点击切换）';
    }
  }
}
