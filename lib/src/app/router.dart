import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../settings/app_settings.dart';
import '../tools/registry.dart';

/// 构建 GoRouter
///
/// 路由表：
/// - `/`           首页（工具网格 + 搜索 + 分类筛选）
/// - `/tools/:id`  工具页，id 在 [Registry] 中查找；未知 id 显示兜底页
GoRouter buildRouter(AppSettings settings) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(settings: settings),
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
      appBar: AppBar(title: const Text('未找到工具')),
      body: const Center(child: Text('该工具不存在或已下线')),
    );
  }
}
