# s-toolbox-rs

一个基于 Flutter + Rust 的跨平台工具箱，适配移动端（Android）、桌面端（Windows / macOS / Linux）与 Web 端。首版包含一个基础计算器。

## 架构

```
┌─────────────────────────────────────────────┐
│             Flutter (Dart) UI               │
│   Material 3 · Roboto · 响应式布局          │
└──────────────────┬──────────────────────────┘
                   │ flutter_rust_bridge 2.12
                   │ (自动生成 FFI 绑定)
┌──────────────────▼──────────────────────────┐
│              Rust 核心 (s_toolbox_core)     │
│   词法分析 → 递归下降解析 → AST 求值        │
│   函数式风格 · 纯函数 · 不可变 AST          │
└─────────────────────────────────────────────┘
```

- **UI 层**：Flutter 3.44 + Material 3（`useMaterial3: true`，M3 baseline 紫色配色），Roboto + Noto Sans SC 本地打包字体，支持浅色 / 深色 / 跟随系统三种主题模式。
- **核心层**：Rust 实现计算器的 tokenize → parse → eval 流水线，通过 `flutter_rust_bridge` 暴露为 Dart 可调用的同步函数 `evaluate(expression: String) -> Result<f64, String>`。

## 目录结构

```
s-toolbox-rs/
├── lib/                      # Flutter (Dart) 源码
│   ├── main.dart             # 入口
│   └── src/
│       ├── app/              # 根 widget、主题模式切换
│       ├── theme/            # M3 主题构建
│       ├── settings/         # 应用设置（主题模式）
│       ├── features/
│       │   └── calculator/   # 计算器页面
│       └── rust/             # flutter_rust_bridge 生成物（.gitignore 忽略，本地/CI 再生）
├── rust/                     # Rust 核心源码
│   └── src/
│       ├── api/calc.rs       # 对 Flutter 暴露的入口
│       └── calc/             # 计算器实现
│           ├── token.rs      # 词法分析
│           ├── ast.rs        # AST 定义
│           ├── parser.rs     # 递归下降解析器
│           └── eval.rs       # AST 求值
├── rust_builder/             # cargokit（Flutter 加载 Rust 库的构建脚本）
├── assets/fonts/             # 本地打包字体（Roboto + Noto Sans SC）
├── android/ windows/ macos/ linux/ web/   # 各平台 runner
├── .github/workflows/ci.yml  # GitHub Actions 持续集成
└── flutter_rust_bridge.yaml  # flutter_rust_bridge 配置
```

> **注意**：`lib/src/rust/` 与 `rust/src/frb_generated*.rs` 是 `flutter_rust_bridge` 的生成物，已加入 `.gitignore` 不入库。本地开发或 CI 构建前需先运行 codegen（见下文）。

## 平台支持

| 平台 | 状态 | CI 构建 |
|------|------|--------|
| Android | ✅ | ubuntu (apk) |
| Windows | ✅ | windows (exe) |
| macOS | ✅ | macos (app) |
| Linux | ✅ | ubuntu (bundle) |
| Web | ✅ | ubuntu (web) |
| iOS | ❌ | 未包含 |

## 本地开发

### 环境要求

- Flutter 3.44+ (stable)
- Dart 3.12+
- Rust 1.96+ (stable)
- `flutter_rust_bridge_codegen` 2.12+：`cargo install flutter_rust_bridge_codegen`
- 各平台原生工具链（Android NDK、Windows MSVC、macOS Xcode、Linux GTK 等）

### 首次拉取后生成桥接代码

由于 FRB 生成物不入库，clone 后需先运行：

```bash
flutter_rust_bridge_codegen generate
```

### 运行

```bash
flutter pub get
flutter run -d windows      # 或 chrome / macos / linux / <android-device-id>
```

### 测试

```bash
# Rust 单元测试
cd rust && cargo test

# Flutter 单元测试（UI 结构）
flutter test

# 集成测试（真实 Rust 调用，需在设备/桌面端运行）
flutter test integration_test/simple_test.dart -d windows
```

### 代码质量

```bash
# Rust
cd rust
cargo fmt --check
cargo clippy --all-targets -- -D warnings

# Flutter
flutter analyze
```

## 计算器功能

- 基础四则运算：`+ - × ÷`
- 括号 `()`
- 正负号 `±`
- 百分号 `%`（后缀单目：`50% = 0.5`，`200×10% = 20`，支持连续 `50%% = 0.005`）
- 除零错误提示

表达式求值遵循标准优先级：`1 + 2 × 3 = 7`，`(1 + 2) × 3 = 9`。

## GitHub Actions

CI 工作流定义在 `.github/workflows/ci.yml`：

- **PR / push 到非 main 分支**：运行 lint + test（Rust clippy/fmt/test + Flutter analyze/test），快速反馈
- **push 到 main / 打 tag**：在 lint-test 通过后，并行构建 5 个平台产物并上传 artifact

## License

见 [LICENSE](LICENSE)。
