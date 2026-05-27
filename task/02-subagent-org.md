# 02 — 多层 Subagent 组织

## 1. 组织图（三层）

```
                       ┌──────────────────────────┐
                       │ L1  Orchestrator (PM-bot) │
                       │  · 拆分任务 / 调度 L2     │
                       │  · 维护里程碑 + 风险      │
                       │  · 合并冲突仲裁           │
                       └────────────┬─────────────┘
                                    │
   ┌────────────┬────────────┬──────┴──────┬────────────┬────────────┬────────────┐
   ▼            ▼            ▼             ▼            ▼            ▼            ▼
 L2-ARCH    L2-UI/THEME   L2-ROUTE/SHELL  L2-DATA   L2-FEATURE   L2-QA       L2-DEVOPS
 架构师     设计系统     路由+布局壳      状态+API   业务特性     测试        CI/工具链
   │            │            │             │            │            │            │
   │            │            │             │            │            │            │
 (无 L3)     L3-Tokens   L3-Sidebar     L3-Auth     L3-Charts   L3-Unit     L3-CI
            L3-Comp-Lib  L3-Tabs        L3-Mock     L3-Editor   L3-Widget   L3-Golden
                         L3-Breadcrumb  L3-Storage  L3-JsonView L3-Integ    L3-Codecov
                         L3-Layout      L3-PermRepo L3-Table    L3-Contract
                                                    L3-Perm     L3-A11y
                                                    L3-Errors
```

每个 L2 都是**模块负责人**，把工作切成可独立测试的"垂直切片"派发给 L3。
L3 是**单一职责执行者**，输入 = 契约 + 测试 ID 列表，输出 = 通过测试的代码。

## 2. 各 Subagent 职责卡

### L1 — Orchestrator（PM-bot）
- **输入**：本工作计划。
- **输出**：每日里程碑状态 + 阻塞清单 + 下一日派单。
- **不做**：写代码、改测试。
- **决策权**：合并、版本号、范围裁剪、风险升级。

---

### L2-ARCH — 架构师
- **职责**：维护 ADR、抽象接口、目录骨架、依赖图。
- **交付**：
  - `lib/` 目录骨架 PR（空文件夹 + README）
  - `domain/` 层所有抽象接口（`AuthRepository` / `MenuRepository` / `TableDataSource` …）
  - `core/router/app_router.dart` 路由表骨架
- **验收测试**：契约测试（contract test）— 任意实现必须通过 `test/contract/*_contract_test.dart`。

---

### L2-UI/THEME — 设计系统负责人
- **输出**：
  - `core/theme/`：色板、字体、间距 token
  - `core/widgets/`：通用 `AppButton`/`AppInput`/`AppCard`/`AppTag`/`AppDialog`
  - Storybook（用 `widgetbook` 库搭建组件画廊）
- **L3 子任务**：
  - L3-Tokens：色板、间距、字体阶
  - L3-Comp-Lib：≥ 10 个原子组件 + widget 测试 + golden 测试

---

### L2-ROUTE/SHELL — 路由 & 应用壳
- **输出**：
  - `go_router` 路由 + redirect 守卫
  - `AppShell`（顶栏 + 侧栏 + 多标签 + 内容区）
  - 自适应布局（断点切换）
- **L3 子任务**：
  - L3-Sidebar：动态多级菜单
  - L3-Tabs：多标签导航 + 状态保活
  - L3-Breadcrumb：跟随路由
  - L3-Layout：响应式断点

---

### L2-DATA — 状态 & API
- **输出**：
  - `core/network/`：dio + 拦截器（含 Mock）
  - `core/storage/`：token / 偏好持久化
  - 全局 Riverpod providers
- **L3 子任务**：
  - L3-Auth：登录 / 登出 / token 刷新（仓库实现）
  - L3-Mock：JSON fixtures + 拦截器
  - L3-Storage：secure_storage 包装
  - L3-PermRepo：权限数据获取

---

### L2-FEATURE — 业务特性负责人（最大组，可再拆 2 人）
- **输出**：6 个特性页面，每个都"页面 + ViewModel + 测试"自洽。
- **L3 子任务**（每个独立可并行）：
  - L3-Charts：4 类图表
  - L3-Editor：Markdown + 富文本
  - L3-JsonView：JSON 树形展示
  - L3-Table：表格 + CSV 导出
  - L3-Perm：权限演示页
  - L3-Errors：错误页（404 / 401 / 500）

---

### L2-QA — 测试负责人（最重要的角色）
- **职责**：定义测试金字塔、维护用例库、保证 CI 门禁。
- **L3 子任务**：
  - L3-Unit：纯函数 / 仓库 / ViewModel 单测
  - L3-Widget：每个 widget 渲染 + 交互
  - L3-Integ：端到端关键流程（patrol）
  - L3-Contract：模块边界契约
  - L3-Golden：关键页面像素一致
  - L3-A11y：语义化 + 对比度
- **门禁权**：测试不通过的 PR 直接拒。

---

### L2-DEVOPS — 工具链
- **输出**：
  - GitHub Actions：lint / test / build / coverage
  - `melos` 或单包 monorepo 设置
  - 自动化截图比对（golden）
- **L3 子任务**：
  - L3-CI：workflow yml
  - L3-Golden：golden CI runner
  - L3-Codecov：覆盖率徽章

## 3. Subagent 之间的"契约模板"

每次 L1 → L2 → L3 派单都用同一份模板，保证不丢信息：

```yaml
task_id: T-AUTH-001
owner: L3-Auth
parent: L2-DATA
inputs:
  contracts:
    - lib/features/auth/domain/auth_repository.dart  # 已存在的接口
  fixtures:
    - test/fixtures/auth/login_success.json
    - test/fixtures/auth/login_invalid.json
  dependencies_done:
    - T-ARCH-002  # 接口已落地
outputs:
  files:
    - lib/features/auth/data/auth_repository_impl.dart
acceptance:
  tests:
    - TC-AUTH-001  # 正确凭证 → 返回 token
    - TC-AUTH-002  # 错误凭证 → 抛 InvalidCredentials
    - TC-AUTH-003  # 网络错误 → 抛 NetworkException
  coverage_min: 0.9
  no_dependency_on: ['lib/features/shell/**', 'lib/features/dashboard/**']
done_when:
  - flutter test test/features/auth/ 全绿
  - PR review approved by L2-DATA + L2-QA
```

## 4. 并行度与冲突

- L2-ARCH 是**前置阻塞项**：骨架 + 接口先落，其它 L2 才能开工。
- L2-UI/THEME 与 L2-FEATURE 并行：业务页先用占位 widget，等设计系统就绪再替换（widget 测试不变）。
- L2-DATA Mock 必须早于 L2-FEATURE 真实联调（M2 节点交付）。
- 同一文件不允许两个 L3 同时改 → 由 L1 在派单时做"文件锁"。

## 5. 沟通节奏

| 频率 | 形式 | 参与方 |
|------|------|--------|
| 每个 PR | 自动测试 + 1 名 L2 review | L2 + L2-QA |
| 每日 | L1 汇总：完成 / 阻塞 / 明日 | L1 + 全员 |
| 里程碑 | demo + 回归测试报告 | 全员 |
