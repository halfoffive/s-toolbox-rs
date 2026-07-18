// 计算器 UI 单元测试
//
// 只测 UI 交互（表达式累积），不触发真实 Rust 求值（FFI 在单元测试环境不可用）

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:s_toolbox_rs/src/features/calculator/calculator_page.dart';
import 'package:s_toolbox_rs/src/settings/app_settings.dart';

void main() {
  // 初始化 AppSettings 单例（ToolboxAppBar 的 ThemeToggleButton 依赖）
  setUpAll(() => AppSettings());

  testWidgets('按键累积表达式并显示', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CalculatorPage()),
    );

    // 初始表达式行显示 0
    final exprFinder = find.byKey(const ValueKey('expression'));
    Text exprWidget() => tester.widget<Text>(exprFinder);
    expect(exprWidget().data, '0');

    // 按 1 2
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();

    expect(exprWidget().data, '12');
  });

  testWidgets('清空按钮重置显示', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CalculatorPage()),
    );

    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('C'));
    await tester.pump();

    expect((tester.widget<Text>(find.byKey(const ValueKey('expression')))).data, '0');
  });

  testWidgets('退格删除末位', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CalculatorPage()),
    );

    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('⌫'));
    await tester.pump();

    expect((tester.widget<Text>(find.byKey(const ValueKey('expression')))).data, '7');
  });
}
