# AGENTS.md

本文件为 AI 助手（如 OpenCode / Lingma）在此仓库中工作时提供指导。

## AI 工作流规范

### 分支与 PR 流程（必须遵守）

1. **除非用户明确指定**，AI 在执行任何代码修改前，必须先基于最新 `main` 创建一个功能分支（命名规则：`feat/xxx`、`fix/xxx`、`chore/xxx`）。
2. 所有修改在该分支上进行，不得直接在 `main` 分支提交。
3. 修改完成后，将分支推送到远程并创建 Pull Request。

### 变更后必须更新的文件

每次完成功能修改或 Bug 修复后，AI 必须同步创建或更新以下文件：

- **AGENTS.md**（本文件）：如有新增命令、架构变更等，及时补充。
- **CHANGELOG.md**：按版本号记录变更内容（新增功能、修复、破坏性变更等）。当前仓库尚未建立，首次变更时创建。
- **README.md**：如功能描述、目录结构、使用说明发生变化，及时更新。

---

## 常用命令

### 环境准备

```bash
# 安装桥接代码生成器（仅首次或升级时）
cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked

# clone 后或 FRB 接口变更后，重新生成桥接代码（生成物不入库，必须先跑才能编译）
flutter_rust_bridge_codegen generate

# 安装 Dart 依赖
flutter pub get
```

### 运行

```bash
flutter run -d windows      # Windows 桌面
flutter run -d chrome         # Web
flutter run -d macos          # macOS
flutter run -d linux          # Linux
flutter run -d <device-id>    # Android 真机
```

### 测试

```bash
# Rust 单元测试（必须在 rust/ 目录下）
cd rust && cargo test

# Flutter 单元测试
flutter test

# 集成测试（需要连接设备或桌面平台）
flutter test integration_test/simple_test.dart -d windows
```

### Lint / 代码质量（CI 门禁，提交前必过）

```bash
# Rust
cd rust
cargo fmt --check
cargo clippy --all-targets -- -D warnings

# Flutter
flutter analyze
```

---

## 项目架构

```
┌─────────────────────────────────────────────┐
│             Flutter (Dart) UI               │
│  首页(工具网格+搜索+分类) -> go_router -> 工具页 │
│  Material 3 · Roboto · 浅色/深色主题         │
└──────────────────┬──────────────────────────┘
                   │ flutter_rust_bridge 2.12
                   │ (自动生成 FFI 绑定)
┌──────────────────▼──────────────────────────┐
│              Rust 核心 (s_toolbox_core)     │
│   词法分析 -> 递归下降解析 -> AST 求值        │
└─────────────────────────────────────────────┘
```

### 两层架构

- **Flutter UI 层**（`lib/`）：Flutter 3.44 + Material 3。首页展示工具网格 + 搜索 + 分类筛选，通过 `go_router` 派发到各工具页；支持浅色 / 深色 / 跟随系统主题。
- **Rust 核心层**（`rust/`）：纯 Rust 实现业务逻辑，通过 `flutter_rust_bridge` 暴露为 Dart 同步函数。

### 关键路径

| 路径 | 说明 |
|------|------|
| `lib/main.dart` | Flutter 入口，初始化 `RustLib` 后 `runApp` |
| `lib/src/app/app.dart` | 根 widget `ToolboxApp`，主题监听 + 路由装配 |
| `lib/src/app/router.dart` | go_router 路由表：`/` 首页、`/tools/:id` 工具页（按 id 在 Registry 查找，未知 id 显示兜底页） |
| `lib/src/app/toolbox_app_bar.dart` | **全局共享 AppBar**：标题 `s-toolbox-rs · {toolName}` + 左侧菜单按钮 + 右侧主题切换按钮 |
| `lib/src/app/toolbox_drawer.dart` | **全局共享 Drawer**：内联主题模式设置 + GitHub 仓库链接 |
| `lib/src/tools/registry.dart` | **工具中央注册表**，新增工具在此追加一条 `Tool` 记录 |
| `lib/src/tools/tool.dart` | `Tool` 元数据定义（id / 名称 / 分类 / builder / 搜索关键词） |
| `lib/src/features/home/` | 首页（工具网格 + 搜索 + 分类筛选） |
| `lib/src/features/calculator/` | 计算器工具页 UI |
| `lib/src/widgets/theme_toggle_button.dart` | 主题切换单按钮：三态循环 light→dark→system + AnimatedSwitcher 动画 |
| `lib/src/rust/` | FRB 生成物（`.gitignore` 忽略，本地/CI 生成） |
| `rust/src/api/calc.rs` | Rust 对 Flutter 暴露的 API 入口（`evaluate` / `init_app`） |
| `rust/src/calc/` | 计算器核心：`token.rs`(词法) -> `parser.rs`(解析) -> `eval.rs`(求值)，外加 `ast.rs` / `mod.rs` |
| `rust/src/frb_generated.rs` | FRB 生成物（`.gitignore` 忽略） |
| `rust_builder/` | cargokit 构建脚本，Flutter 加载 Rust 动态库的桥梁 |
| `flutter_rust_bridge.yaml` | FRB 配置：Rust 输入 `crate::api`，Dart 输出 `lib/src/rust` |
| `.github/workflows/ci.yml` | CI：PR 跑 lint+test，push main/tag 跑全平台构建 + Web 部署到 GitHub Pages |

### 新增工具（最高频改动，务必按此流程）

新增一个工具**只需两步**，无需改路由或首页：

1. 在 `lib/src/features/<name>/` 下实现页面 widget（返回带自身 `Scaffold` 的完整页面，go_router 自动注入返回键）。
2. 在 `lib/src/tools/registry.dart` 的 `Registry.tools` 列表追加一条 `Tool` 记录（`id` 同时作为路由参数 `/tools/:id`，并提供 `keywords` 供首页搜索）。

首页网格、搜索、分类筛选、路由派发均从 `Registry` 读取，自动生效。

> 若工具需要 Rust 计算：在 `rust/src/api/` 新增公开函数后**必须重新运行** `flutter_rust_bridge_codegen generate`，再在 Dart 侧调用 `lib/src/rust/` 下生成物。

### FRB 桥接机制

`flutter_rust_bridge` 将 `rust/src/api/` 下的公开 Rust 函数自动生成 Dart 绑定到 `lib/src/rust/`。
修改 Rust API 后**必须重新运行** `flutter_rust_bridge_codegen generate`。
生成物不入库（见 `.gitignore`），clone 后需先生成才能编译。

### CI 行为

- **PR / push 到非 main 分支**：仅运行 lint + test（Rust fmt/clippy/test + Flutter analyze/test），快速反馈。
- **push 到 main / 打 tag `v*`**：lint-test 通过后，并行构建 Android/Windows/macOS/Linux/Web 五平台产物并上传 artifact；并把 Web 产物部署到 GitHub Pages（地址：<https://halfoffive.github.io/s-toolbox-rs/>，base-href `/s-toolbox-rs/`）。仓库 Settings → Pages → Source 需设为 GitHub Actions。
- CI 固定 Flutter 3.44.4 / Rust 1.96.0，并预装 `flutter_rust_bridge_codegen` 与 `cargo-expand` 后再跑 codegen。

---

## 技术栈版本

| 组件 | 版本 |
|------|------|
| Flutter | 3.44+ (stable) |
| Dart | 3.12+ |
| Rust | 1.96+ (stable) |
| flutter_rust_bridge | 2.12.0 |
| flutter_rust_bridge_codegen | 2.12.0 |
| go_router | ^14.6.0 |
