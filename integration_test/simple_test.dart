// 集成测试：真实调用 Rust 求值 + 完整 app 启动
//
// 需在真机/模拟器/桌面端运行：flutter test integration_test/simple_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:s_toolbox_rs/src/app/app.dart';
import 'package:s_toolbox_rs/src/rust/api/calc.dart';
import 'package:s_toolbox_rs/src/rust/frb_generated.dart';
import 'package:s_toolbox_rs/src/settings/app_settings.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Rust 求值', () {
    setUpAll(() async => await RustLib.init());

    test('基础四则', () {
      expect(evaluate(expression: '1+2'), 3.0);
      expect(evaluate(expression: '6*7'), 42.0);
      expect(evaluate(expression: '(1+2)*3'), 9.0);
    });

    test('百分号', () {
      expect(evaluate(expression: '50%'), 0.5);
      expect(evaluate(expression: '200*10%'), 20.0);
    });

    test('一元负号', () {
      expect(evaluate(expression: '-5'), -5.0);
      expect(evaluate(expression: '3*-2'), -6.0);
    });

    test('除零返回错误', () {
      expect(() => evaluate(expression: '1/0'), throwsException);
    });
  });

  testWidgets('app 能启动并显示计算器', (WidgetTester tester) async {
    await RustLib.init();
    await tester.pumpWidget(ToolboxApp(settings: AppSettings()));
    await tester.pumpAndSettle();

    expect(find.text('计算器'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
