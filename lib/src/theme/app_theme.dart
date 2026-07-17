import 'package:flutter/material.dart';

/// 主题模式枚举：浅色 / 深色 / 跟随系统
enum ThemeModeOption {
  /// 浅色
  light,
  /// 深色
  dark,
  /// 跟随系统
  system,
}

/// 把应用层枚举映射为 Flutter [ThemeMode]
ThemeMode toFlutterThemeMode(ThemeModeOption option) {
  switch (option) {
    case ThemeModeOption.light:
      return ThemeMode.light;
    case ThemeModeOption.dark:
      return ThemeMode.dark;
    case ThemeModeOption.system:
      return ThemeMode.system;
  }
}

/// 构建浅色主题
///
/// 采用 Material 3 默认基线配色（种子色 0xFF6750A4，M3 baseline purple）
ThemeData buildLightTheme() => _build(ThemeData.light(useMaterial3: true));

/// 构建深色主题
ThemeData buildDarkTheme() => _build(ThemeData.dark(useMaterial3: true));

ThemeData _build(ThemeData base) {
  // M3 默认基线种子色（baseline purple），fromSeed 生成完整 ColorScheme
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: base.brightness,
  );

  // 给默认 TextTheme 的每个 slot 注入 fontFamily + fallback
  // （Flutter 3.x ThemeData 不直接提供 fontFamily 参数）
  final textTheme = _withFontFamily(base.textTheme);

  return base.copyWith(
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: _withFontFamily(base.primaryTextTheme),
  );
}

/// 把 [TextTheme] 每个 slot 的 TextStyle 都加上 Roboto + Noto Sans SC 回退
TextTheme _withFontFamily(TextTheme source) {
  TextStyle wrap(TextStyle? s) {
    return (s ?? const TextStyle()).copyWith(
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Noto Sans SC'],
    );
  }

  return source.copyWith(
    displayLarge: wrap(source.displayLarge),
    displayMedium: wrap(source.displayMedium),
    displaySmall: wrap(source.displaySmall),
    headlineLarge: wrap(source.headlineLarge),
    headlineMedium: wrap(source.headlineMedium),
    headlineSmall: wrap(source.headlineSmall),
    titleLarge: wrap(source.titleLarge),
    titleMedium: wrap(source.titleMedium),
    titleSmall: wrap(source.titleSmall),
    bodyLarge: wrap(source.bodyLarge),
    bodyMedium: wrap(source.bodyMedium),
    bodySmall: wrap(source.bodySmall),
    labelLarge: wrap(source.labelLarge),
    labelMedium: wrap(source.labelMedium),
    labelSmall: wrap(source.labelSmall),
  );
}
