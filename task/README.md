# Flutter 复刻 vue-framework-wz — 工作计划索引

> 源项目：https://github.com/herozhou/vue-framework-wz
> 目标：用 Flutter 复刻该 Vue 后台管理框架，**以"测试通过 + DoD 全勾"为唯一验收口径**。
> 暂不写代码。本目录为正式工作底稿。

## 阅读顺序

| # | 文档 | 给谁看 | 主要回答的问题 |
|---|------|--------|----------------|
| 1 | [01-scope-and-architecture.md](01-scope-and-architecture.md) | 全员 | 复刻什么？技术栈如何对齐？目录结构怎样？ |
| 2 | [02-subagent-org.md](02-subagent-org.md) | PM / Tech Lead | 多层 subagent 怎么分工？接口如何对接？ |
| 3 | [03-milestones.md](03-milestones.md) | PM / 全员 | 里程碑、依赖、并行度、关键路径 |
| 4 | [04-test-plan.md](04-test-plan.md) | **QA + 全员（核心）** | 验收测试设计、用例清单、CI 门禁 |
| 5 | [05-feature-spec.md](05-feature-spec.md) | 模块负责人 | 每个特性的契约 + 对应测试 ID |
| 6 | [06-risks-and-tooling.md](06-risks-and-tooling.md) | PM / DevOps | 风险、工具链、CI、回滚策略 |

## 核心原则（贴墙）

1. **测试先行（Test-First）**：先写 spec + 测试用例，再写实现。无测试不合并。
2. **多层 subagent**：L1 指挥 → L2 模块负责 → L3 执行者；每层只对下一层下达"输入 / 输出 / 验收测试 ID"三件套。
3. **契约即测试**：模块间通过 Dart 抽象接口对接，所有契约用 contract test 锁定。
4. **像素对齐源项目，但行为以测试为准**：UI 风格参考 Vue 版，但功能正确性由测试断言定义。
5. **小步快跑**：一个 subagent 一次只交付一个可被独立测试的"垂直切片"。

## 验收（一句话）

> CI 全绿 + 所有 P0/P1 用例通过 + 关键页面 golden 测试一致 + `flutter test --coverage` 行覆盖 ≥ 80% → 视为交付完成。
