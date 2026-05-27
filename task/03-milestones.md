# 03 — 里程碑与依赖

## 1. 里程碑总览（6 个 M 节点）

| 里程碑 | 名称 | 周期（理想人日） | 主要交付 | 退出条件（DoD） |
|--------|------|-----------------|---------|----------------|
| **M0** | 项目初始化 | 1 | 仓库 + Flutter 骨架 + CI 跑通 | `flutter test` 空也得通过；CI workflow 绿 |
| **M1** | 架构骨架 | 2 | ADR 落地 + 抽象接口 + 路由表壳 + 设计系统 token | 契约测试全绿；空页可跳转 |
| **M2** | 数据与 Mock 层 | 3 | dio + 拦截器 + 全部 fixtures + Auth 仓库 | 单测 ≥ 90% 覆盖；Mock 切换可一键 |
| **M3** | 应用壳 + 核心导航 | 4 | 登录页 + Shell + 侧栏 + 多标签 + 面包屑 | 端到端跑通"登录→打开 3 标签→关闭→刷新仍在" |
| **M4** | 业务特性（并行 6 路） | 6 | Charts / Editor / JsonView / Table / Perm / Errors | 每个特性 widget 测 + golden 通过 |
| **M5** | 加固 + 发布 | 3 | A11y、性能、i18n、文档、构建 | 覆盖率 ≥ 80%；golden 零回归；APK / Web 构建产物 |

> 总计 ≈ 19 人日（单线），实际并行后预计 8 ~ 10 个工作日。

## 2. 依赖关系图

```
M0  ──►  M1  ──►  M2  ──►  M3  ──►  M4  ──►  M5
                              │       ▲
                              └───────┘
                              （Shell 与特性页之间双向：Shell 提供 slot，特性填内容）
```

L2 之间的细粒度依赖：

```
L2-ARCH ──► (所有 L2)            # 接口先落
L2-DATA ──► L2-FEATURE           # Mock + Auth 先就绪
L2-UI   ──► L2-FEATURE / L2-SHELL # 设计系统先就绪
L2-QA   ◄── (所有 L2 全过程)      # QA 全程并行参与，不是收尾
L2-DEVOPS ──► (M0 起持续运行)
```

## 3. 并行计划（M4 详细排期）

M4 时 6 个 L3 并行（资源充足时）：

| 通道 | L3 | 阻塞依赖 | 关键测试 ID |
|------|----|---------|------------|
| A | L3-Charts | M2 Mock 已就绪 | TC-CHART-* |
| B | L3-Editor | M1 设计系统就绪 | TC-EDIT-* |
| C | L3-JsonView | M1 | TC-JSON-* |
| D | L3-Table | M2 + Mock 大数据 fixture | TC-TABLE-* |
| E | L3-Perm | M2 Auth + Role | TC-PERM-* |
| F | L3-Errors | M1 路由 | TC-ERR-* |

合流前必须跑全量回归（见 [04-test-plan.md](04-test-plan.md) §8）。

## 4. 关键路径（最长链）

`M0 → ARCH 骨架 → DATA/Mock + UI tokens → Shell(Sidebar+Tabs) → Table（最复杂特性）→ M5 加固`

任何一个环节延迟，整体延迟。L1 每天监控该链上的"剩余工时"。

## 5. 风险节点（与 [06-risks-and-tooling.md](06-risks-and-tooling.md) 对应）

| 节点 | 风险 | 缓解 |
|------|------|------|
| M2 → M3 切换 | Mock 数据契约和实际后端不一致 | 数据 schema 写 contract test |
| M4 富文本 | flutter_quill 在 Web 上行为差异 | 早期写跨平台 widget 测试 + 手测 |
| M4 表格 | 大数据列表性能 | 加入"1 万行滚动 FPS" 性能门禁 |
| M5 golden | 字体跨平台像素差 | 锁定字体文件 + 用 `golden_toolkit` 的字体加载 |

## 6. 准入 / 准出（PR 级）

**准入（任何 PR 必须）：**
- 关联 task_id 与至少一个测试 ID
- 不动 `domain/` 接口（除非提 ADR）
- 不引入 transitive 依赖未声明

**准出（合并条件）：**
- `flutter analyze` 零警告
- 涉及单元的 file 覆盖 ≥ 90%
- widget 测变更必须附 golden 更新（如视觉变化）
- L2-QA 至少 1 人 approve
