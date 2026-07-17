import 'package:flutter/foundation.dart';

import '../theme/app_theme.dart';

/// 应用设置状态
///
/// 首版仅持有主题模式，内存态（重启回到 system）。
/// 用 [ValueNotifier] 让 UI 响应式更新。
class AppSettings extends ValueNotifier<ThemeModeOption> {
  AppSettings() : super(ThemeModeOption.system);

  /// 切换主题模式
  void setThemeMode(ThemeModeOption mode) {
    if (mode != value) {
      value = mode;
    }
  }
}
