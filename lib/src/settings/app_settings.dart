import 'package:flutter/foundation.dart';

import '../theme/app_theme.dart';

/// 应用设置状态
///
/// 持有主题模式（light / dark / system），内存态（重启回到 system）。
/// 用 [ValueNotifier] 让 UI 响应式更新。
///
/// 通过 [instance] 单例在任意 widget 中获取，避免改动 [Tool.builder] 与
/// 路由 builder 签名传递设置引用。
class AppSettings extends ValueNotifier<ThemeModeOption> {
  /// 全局单例，[main] 中创建后立即赋值。
  static late AppSettings instance;

  AppSettings() : super(ThemeModeOption.system) {
    instance = this;
  }

  /// 切换主题模式
  void setThemeMode(ThemeModeOption mode) {
    if (mode != value) {
      value = mode;
    }
  }

  /// 三态循环：light → dark → system → light
  ///
  /// 供主题切换单按钮使用。
  void cycleThemeMode() {
    switch (value) {
      case ThemeModeOption.light:
        value = ThemeModeOption.dark;
      case ThemeModeOption.dark:
        value = ThemeModeOption.system;
      case ThemeModeOption.system:
        value = ThemeModeOption.light;
    }
  }
}
