import 'package:flutter/material.dart';

import 'tool_category.dart';

/// 工具元数据
///
/// 描述一个工具的展示信息与入口构造器。所有工具通过 [Registry] 统一注册，
/// 首页与路由均从注册表读取，新增工具只需在 `registry.dart` 加一条记录。
@immutable
class Tool {
  /// 唯一标识，同时作为路由参数（`/tools/:id`）
  final String id;

  /// 展示名称
  final String name;

  /// 一句话描述
  final String description;

  /// 所属分类
  final ToolCategory category;

  /// 卡片图标
  final IconData icon;

  /// 搜索关键词（不含 name/description，这两者默认参与搜索）
  final List<String> keywords;

  /// 工具页面构造器
  ///
  /// 返回带自身 [Scaffold] 的完整页面；go_router 会自动注入返回键。
  final WidgetBuilder builder;

  const Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.builder,
    this.keywords = const [],
  });

  /// 搜索匹配：对 name / description / keywords 做大小写不敏感子串匹配
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (name.toLowerCase().contains(q)) return true;
    if (description.toLowerCase().contains(q)) return true;
    for (final k in keywords) {
      if (k.toLowerCase().contains(q)) return true;
    }
    return false;
  }
}
