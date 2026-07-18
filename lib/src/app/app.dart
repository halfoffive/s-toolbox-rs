import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../settings/app_settings.dart';
import '../theme/app_theme.dart';
import 'router.dart';

/// 应用根 widget
///
/// 监听 [AppSettings] 主题模式变化；路由由 [buildRouter] 提供。
/// 主题切换按钮与左侧抽屉通过共享 [ToolboxAppBar] / [ToolboxDrawer]
/// 出现在所有页面，统一由 `AppSettings.instance` 单例驱动。
class ToolboxApp extends StatefulWidget {
  final AppSettings settings;
  const ToolboxApp({super.key, required this.settings});

  @override
  State<ToolboxApp> createState() => _ToolboxAppState();
}

class _ToolboxAppState extends State<ToolboxApp> {
  late final AppSettings _settings = widget.settings;
  late final GoRouter _router = buildRouter();

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
        return MaterialApp.router(
          title: 's-toolbox-rs',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: toFlutterThemeMode(option),
          routerConfig: _router,
        );
      },
    );
  }
}
