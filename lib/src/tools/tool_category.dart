import 'package:flutter/material.dart';

/// 工具分类枚举
///
/// 首版分类集合：计算 / 转换 / 编码 / 文本 / 其他。
/// 新增工具时优先归入既有分类；确实不匹配再新增枚举值。
enum ToolCategory {
  /// 计算类：计算器、表达式求值等
  calculate('计算', Icons.calculate_outlined),

  /// 转换类：单位换算、汇率、进制转换等
  convert('转换', Icons.swap_horiz_outlined),

  /// 编码类：Base64、URL、Hash 等
  encode('编码', Icons.code_outlined),

  /// 文本类：字数统计、大小写转换、去重等
  text('文本', Icons.text_fields_outlined),

  /// 其他：不便归类的工具
  other('其他', Icons.apps_outlined);

  final String label;
  final IconData icon;

  const ToolCategory(this.label, this.icon);
}
