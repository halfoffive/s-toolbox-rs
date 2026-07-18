import 'package:flutter/material.dart';

import '../../app/toolbox_app_bar.dart';
import '../../app/toolbox_drawer.dart';
import '../../rust/api/calc.dart';

/// 计算器页面
///
/// 表达式求值由 Rust 侧完成（[evaluate]），UI 仅负责输入累积与结果展示。
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  /// 表达式输入（用户按键累积）
  String _expression = '';
  /// 求值结果（按 = 后填入）
  String _result = '';
  /// 错误态
  String? _error;
  /// 是否正在求值
  bool _evaluating = false;

  /// 追加字符到表达式
  void _append(String token) {
    setState(() {
      _error = null;
      _result = '';
      _expression += token;
    });
  }

  /// 退格
  void _backspace() {
    setState(() {
      _error = null;
      _result = '';
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  /// 清空
  void _clear() {
    setState(() {
      _expression = '';
      _result = '';
      _error = null;
    });
  }

  /// 切换正负号：在表达式开头插入或移除 "-"
  void _toggleSign() {
    setState(() {
      _error = null;
      if (_expression.startsWith('-')) {
        _expression = _expression.substring(1);
      } else {
        _expression = '-$_expression';
      }
    });
  }

  /// 求值
  ///
  /// Rust 侧 [evaluate] 是 sync 函数（#[frb(sync)]），错误以异常形式抛出
  void _evaluate() {
    if (_expression.isEmpty || _evaluating) return;
    setState(() {
      _evaluating = true;
      _error = null;
    });
    try {
      final value = evaluate(expression: _expression);
      setState(() {
        _result = _format(value);
        _evaluating = false;
      });
    } on Object catch (e) {
      setState(() {
        _error = e.toString();
        _result = '';
        _evaluating = false;
      });
    }
  }

  /// 格式化数字：整数不显示小数点，浮点去掉尾部 0
  String _format(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    // 限制精度，避免浮点尾部长串
    return v.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolboxAppBar(toolName: '计算器'),
      drawer: const ToolboxDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 宽屏（桌面/Web）限宽居中；窄屏（移动）铺满
            final isWide = constraints.maxWidth > 600;
            final content = _buildContent(context);
            if (isWide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: content,
                ),
              );
            }
            return content;
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // 显示区
        Expanded(
          flex: 2,
          child: _buildDisplay(context),
        ),
        // 按键区
        Expanded(
          flex: 5,
          child: _buildKeypad(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 显示区：表达式 + 结果 / 错误
  Widget _buildDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 表达式行
            Text(
              _expression.isEmpty ? '0' : _expression,
              key: const ValueKey('expression'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // 结果 / 错误 / 等待
            if (_error != null)
              Text(
                _error!,
                key: const ValueKey('result'),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colorScheme.error,
                ),
              )
            else if (_evaluating)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                _result,
                key: const ValueKey('result'),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 按键网格
  Widget _buildKeypad(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 按键定义：[标签, 回调, 样式]
    // 样式：0=数字(Elevated), 1=运算符(FilledTonal), 2=功能(TextButton), 3=等号(Filled)
    final keys = <_CalcKey>[
      _CalcKey('C', _clear, 2),
      _CalcKey('⌫', _backspace, 2),
      _CalcKey('(', () => _append('('), 2),
      _CalcKey(')', () => _append(')'), 2),
      _CalcKey('7', () => _append('7'), 0),
      _CalcKey('8', () => _append('8'), 0),
      _CalcKey('9', () => _append('9'), 0),
      _CalcKey('÷', () => _append('/'), 1),
      _CalcKey('4', () => _append('4'), 0),
      _CalcKey('5', () => _append('5'), 0),
      _CalcKey('6', () => _append('6'), 0),
      _CalcKey('×', () => _append('*'), 1),
      _CalcKey('1', () => _append('1'), 0),
      _CalcKey('2', () => _append('2'), 0),
      _CalcKey('3', () => _append('3'), 0),
      _CalcKey('−', () => _append('-'), 1),
      _CalcKey('±', _toggleSign, 2),
      _CalcKey('0', () => _append('0'), 0),
      _CalcKey('.', () => _append('.'), 0),
      _CalcKey('＝', _evaluate, 3),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        physics: const NeverScrollableScrollPhysics(),
        children: keys.map((k) => _buildKey(context, k, colorScheme)).toList(),
      ),
    );
  }

  Widget _buildKey(
    BuildContext context,
    _CalcKey key,
    ColorScheme colorScheme,
  ) {
    final label = key.label;
    final style = TextStyle(
      fontSize: 22,
      fontWeight: key.style == 3 ? FontWeight.w500 : FontWeight.w400,
    );

    Widget btn;
    switch (key.style) {
      case 0: // 数字
        btn = ElevatedButton(
          onPressed: key.onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(label, style: style),
        );
        break;
      case 1: // 运算符
        btn = FilledButton.tonal(
          onPressed: key.onPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(label, style: style),
        );
        break;
      case 2: // 功能
        btn = TextButton(
          onPressed: key.onPressed,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(label, style: style.copyWith(color: colorScheme.onSurfaceVariant)),
        );
        break;
      case 3: // 等号
        btn = FilledButton(
          onPressed: key.onPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(label, style: style),
        );
        break;
      default:
        btn = ElevatedButton(onPressed: key.onPressed, child: Text(label));
    }
    return btn;
  }
}

/// 按键定义
class _CalcKey {
  final String label;
  final VoidCallback onPressed;
  final int style; // 0=数字 1=运算符 2=功能 3=等号
  const _CalcKey(this.label, this.onPressed, this.style);
}
