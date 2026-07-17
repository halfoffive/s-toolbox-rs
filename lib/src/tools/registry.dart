import '../features/calculator/calculator_page.dart';
import 'tool.dart';
import 'tool_category.dart';

/// 工具中央注册表
///
/// 新增工具步骤：
/// 1. 在 `features/<name>/` 下实现页面 widget；
/// 2. 在此列表追加一条 [Tool] 记录；
/// 3. 无需改路由 / 首页 —— 路由 `/tools/:id` 会自动派发。
class Registry {
  Registry._();

  /// 全部已注册工具
  static final List<Tool> tools = [
    Tool(
      id: 'calculator',
      name: '计算器',
      description: '四则运算、括号、正负号表达式求值',
      category: ToolCategory.calculate,
      icon: ToolCategory.calculate.icon,
      builder: (_) => const CalculatorPage(),
      keywords: ['calc', '加减乘除', '表达式', '求值'],
    ),
  ];

  /// 按 id 查找工具，未找到返回 null
  static Tool? findById(String id) {
    for (final t in tools) {
      if (t.id == id) return t;
    }
    return null;
  }
}
