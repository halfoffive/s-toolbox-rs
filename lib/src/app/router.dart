import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../tools/registry.dart';
import 'toolbox_app_bar.dart';
import 'toolbox_drawer.dart';

/// 构建 GoRouter
///
/// 路由表：
/// - `/`           首页（工具网格 + 搜索 + 分类筛选）
/// - `/tools/:id`  工具页，id 在 [Registry] 中查找；未知 id 显示兜底页
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/tools/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final tool = Registry.findById(id);
          if (tool == null) {
            return const _UnknownToolPage();
          }
          return tool.builder(context);
        },
      ),
    ],
  );
}

/// 未知工具兜底页
class _UnknownToolPage extends StatelessWidget {
  const _UnknownToolPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolboxAppBar(toolName: '未找到'),
      drawer: const ToolboxDrawer(),
      body: const Center(child: Text('该工具不存在或已下线')),
    );
  }
}
