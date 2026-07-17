import 'package:flutter/material.dart';

import 'src/app/app.dart';
import 'src/settings/app_settings.dart';
import 'src/rust/frb_generated.dart';

Future<void> main() async {
  // 确保 Flutter binding 就绪
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 Rust 库（flutter_rust_bridge）
  await RustLib.init();
  runApp(ToolboxApp(settings: AppSettings()));
}
