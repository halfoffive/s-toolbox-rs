import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../settings/app_settings.dart';
import '../../theme/app_theme.dart';
import '../../tools/registry.dart';
import '../../tools/tool.dart';
import '../../tools/tool_category.dart';

/// 首页：工具网格 + 顶部搜索 + 分类筛选
///
/// 主题切换按钮仅在此页 AppBar 出现；工具页 AppBar 不带主题入口。
class HomePage extends StatefulWidget {
  final AppSettings settings;

  const HomePage({super.key, required this.settings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 搜索词
  String _query = '';

  /// 当前选中的分类筛选；null 表示「全部」
  ToolCategory? _category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filtered = Registry.tools
        .where((t) => (_category == null || t.category == _category) && t.matches(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('工具箱'),
        centerTitle: true,
        actions: [
          _ThemeModeButton(settings: widget.settings),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final content = _buildBody(context, filtered, colorScheme);
            if (isWide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
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

  Widget _buildBody(
    BuildContext context,
    List<Tool> filtered,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SearchBar(
            hintText: '搜索工具',
            leading: const Icon(Icons.search),
            trailing: _query.isEmpty
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: '清除',
                      onPressed: () => setState(() => _query = ''),
                    ),
                  ],
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        // 分类筛选条
        _buildCategoryChips(context, colorScheme),
        const SizedBox(height: 4),
        // 工具网格 / 空态
        Expanded(child: _buildGrid(context, filtered, colorScheme)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCategoryChips(BuildContext context, ColorScheme colorScheme) {
    final chips = <Widget>[
      _chip(
        label: '全部',
        selected: _category == null,
        onTap: () => setState(() => _category = null),
      ),
      ...ToolCategory.values.map(
        (c) => _chip(
          label: c.label,
          avatar: Icon(c.icon, size: 18),
          selected: _category == c,
          onTap: () => setState(() => _category = c),
        ),
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          ...chips.expand((w) => [w, const SizedBox(width: 8)]),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Widget? avatar,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: avatar,
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<Tool> filtered,
    ColorScheme colorScheme,
  ) {
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              '无匹配工具',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 1.0,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final tool = filtered[i];
          return _ToolCard(tool: tool, onTap: () => context.push('/tools/${tool.id}'));
        },
      ),
    );
  }
}

/// 工具卡片
class _ToolCard extends StatelessWidget {
  final Tool tool;
  final VoidCallback onTap;

  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tool.icon, color: colorScheme.onPrimaryContainer, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                tool.name,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  tool.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题模式切换按钮 + 弹出菜单
///
/// 从旧版 `app.dart` 迁移而来，仅出现在首页 AppBar。
class _ThemeModeButton extends StatelessWidget {
  final AppSettings settings;
  const _ThemeModeButton({required this.settings});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeModeOption>(
      valueListenable: settings,
      builder: (context, option, _) {
        return PopupMenuButton<ThemeModeOption>(
          icon: Icon(_iconFor(option)),
          tooltip: '主题模式',
          onSelected: settings.setThemeMode,
          itemBuilder: (context) => [
            _item(ThemeModeOption.light, '浅色', Icons.light_mode_outlined, option),
            _item(ThemeModeOption.dark, '深色', Icons.dark_mode_outlined, option),
            _item(ThemeModeOption.system, '跟随系统', Icons.settings_brightness, option),
          ],
        );
      },
    );
  }

  IconData _iconFor(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.light:
        return Icons.light_mode_outlined;
      case ThemeModeOption.dark:
        return Icons.dark_mode_outlined;
      case ThemeModeOption.system:
        return Icons.settings_brightness;
    }
  }

  PopupMenuItem<ThemeModeOption> _item(
    ThemeModeOption value,
    String label,
    IconData icon,
    ThemeModeOption current,
  ) {
    return PopupMenuItem<ThemeModeOption>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          if (value == current) const Icon(Icons.check, size: 18),
        ],
      ),
    );
  }
}
