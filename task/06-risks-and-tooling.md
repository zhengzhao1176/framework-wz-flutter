# 06 — 风险与工具链

## 1. 风险登记表

| ID | 风险 | 等级 | 触发条件 | 缓解 | 应急方案 |
|----|------|------|----------|------|---------|
| R-01 | 富文本跨平台行为差异（Web vs Native） | 高 | `flutter_quill` 在 Web 上某些键盘事件丢失 | M1 即写跨平台 widget 测试 + 真机/浏览器走查 | 必要时退到 `markdown_editor_plus`，富文本暂时只做 MD |
| R-02 | 表格大数据滚动卡顿 | 中 | 10k 行 FPS 不达标 | 使用 `data_table_2` + 虚拟化；TC-TABLE-010 性能门禁 | 引入 `syncfusion_flutter_datagrid`（社区免费版）替换 |
| R-03 | Golden 跨平台像素差 | 中 | 不同 host OS 字体渲染不同 | 仅在 Linux CI 上比对；锁定字体；`flutter_test_font_loader` | 关键页改成"语义快照"代替像素快照 |
| R-04 | Mock 数据与未来真实 API 漂移 | 中 | 后端接入时字段对不上 | 所有 fixture 走 freezed schema + contract test | 接入时统一更新 fixture + 重跑回归 |
| R-05 | go_router 嵌套 + 多标签状态保活复杂 | 中 | 关闭/切换标签时丢状态 | 自定义 `TabsRegistry` + `IndexedStack`；写 5 条 TC-TAB 用例 | 退到不使用 ShellRoute，自己实现 Navigator 2 |
| R-06 | 七牛云上传 / 文件上传跨端差异 | 低 | Web 无 file system | Mock 上传 + 留 `UploadGateway` 抽象 | v1 仅占位 |
| R-07 | CI 时间过长 | 中 | 全量 golden + e2e | 拆 workflow：PR 跑增量、main 跑全量；并发 | 引入自托管 runner |
| R-08 | 国际化 arb 漏译 | 低 | 文案变更未同步 | CI 跑 `flutter gen-l10n --untranslated-messages-file` 失败 | manually 补齐 |
| R-09 | A11y 在源项目本就不严格 | 低 | 复刻时易忽视 | L2-QA 单独立 A11y check list | M5 集中加固 |
| R-10 | 范围蔓延 | 高 | 想"顺便加"七牛 / 主题面板 / WS | L1 严守 IN/OUT 边界，超出列入 Backlog | 直接拒，记录到下版本 |

## 2. 工具链

### 2.1 开发
- Flutter stable（≥ 3.24）
- Dart 3.x
- VS Code + 推荐扩展：`Dart`、`Flutter`、`Awesome Flutter Snippets`、`Error Lens`

### 2.2 包（核心）
```yaml
dependencies:
  flutter_riverpod: ^2
  go_router: ^14
  dio: ^5
  freezed_annotation: ^2
  json_annotation: ^4
  flutter_secure_storage: ^9
  shared_preferences: ^2
  fl_chart: ^0
  flutter_quill: ^10
  data_table_2: ^2
  csv: ^6
  intl: any

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1
  golden_toolkit: ^0
  build_runner: ^2
  freezed: ^2
  json_serializable: ^6
  widgetbook: ^3       # 组件画廊
  patrol: ^3           # 可选 E2E
```

> 版本号在 M0 由 L2-DEVOPS 锁死，写入 `pubspec.yaml` 与 `pubspec.lock`。

### 2.3 仓库结构
- 单包 Flutter 项目（不必 monorepo）
- 分支策略：`main`（保护）/ `feat/*` / `fix/*` / `chore/*`
- PR 必经 1 名 L2 + L2-QA approval

### 2.4 CI（GitHub Actions）

```yaml
# .github/workflows/ci.yml （示意，不实写）
jobs:
  analyze:
    steps: [checkout, setup-flutter, flutter pub get, flutter analyze, dart format --set-exit-if-changed]
  test-unit-widget:
    steps: [..., flutter test --coverage, upload-codecov]
  test-golden:
    runs-on: ubuntu-latest   # 锁定 OS 防像素差
    steps: [..., flutter test --tags=golden]
  test-integration-android:
    steps: [..., flutter test integration_test/]
  build-android:
    steps: [..., flutter build apk --release]
  build-web:
    steps: [..., flutter build web --release]
```

**门禁**：上述 jobs 全绿才允许合并 `main`。

### 2.5 覆盖率
- 工具：`lcov` + Codecov
- 目标：
  - 总行覆盖 ≥ 80%
  - `core/` 与 `features/*/domain/data` ≥ 90%
  - UI（presentation）≥ 70%

### 2.6 性能基线
- `flutter drive --profile` 录 Timeline
- 上传到 baseline 文件夹（git lfs），每次 PR 对比 p95

### 2.7 Lint
- 启用 `flutter_lints` + 自定义：
  - `avoid_print`
  - `prefer_single_quotes`
  - `require_trailing_commas`
  - `unawaited_futures`

## 3. 回滚策略

- 每个里程碑打 tag：`m1`, `m2`, …
- 出现高严重缺陷：`git revert` 引入缺陷的 PR，而不是从 main 回滚多次提交
- Mock 数据 broken：保留上一版 fixtures 在 `test/fixtures/_archive/` 7 天

## 4. 文档输出（M5 必须产出）

- `README.md`：项目简介 + 启动 + 测试
- `docs/architecture.md`：基于 `01-scope-and-architecture.md` 精简版
- `docs/contributing.md`：分支、PR、commit 规范
- `docs/test-guide.md`：如何加测试 / 如何更新 golden
- `CHANGELOG.md`：M1 ~ M5 节点记录

## 5. "完成"的硬性定义

> 同时满足，否则不发布：
1. CI 全绿（analyze + format + unit + widget + golden + integration + build × 平台）
2. P0 用例 100% pass / P1 ≥ 95%
3. 总覆盖 ≥ 80%
4. `flutter build apk --release` / `flutter build web --release` 成功
5. 文档 4 份齐备
6. L1 在 `task/CHANGELOG.md` 记录验收人 + 日期
