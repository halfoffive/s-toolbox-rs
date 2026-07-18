import 'package:flutter/material.dart';

import '../widgets/theme_toggle_button.dart';

/// 全局共享 AppBar
///
/// 标题格式：`s-toolbox-rs · {toolName}`；左侧菜单按钮打开抽屉；
/// 右侧主题切换单按钮（[ThemeToggleButton]）。
class ToolboxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String toolName;

  const ToolboxAppBar({super.key, required this.toolName});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('s-toolbox-rs · $toolName'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: '菜单',
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: const [ThemeToggleButton()],
    );
  }
}
