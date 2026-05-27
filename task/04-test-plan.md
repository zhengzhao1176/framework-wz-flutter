# 04 — 测试计划（核心交付物）

> **本文件是验收的唯一权威依据**。任何"功能完成"必须能映射到一条或多条本文件的测试 ID。

## 目录

1. [测试策略与金字塔](#1-测试策略与金字塔)
2. [测试分层与工具](#2-测试分层与工具)
3. [测试 ID 命名规则](#3-测试-id-命名规则)
4. [模块测试用例（按特性分组）](#4-模块测试用例)
5. [跨模块 / 端到端用例](#5-跨模块--端到端用例)
6. [非功能测试（性能 / A11y / i18n / 安全）](#6-非功能测试)
7. [Golden 测试矩阵](#7-golden-测试矩阵)
8. [回归与 CI 门禁](#8-回归与-ci-门禁)
9. [测试数据 / Fixtures 规范](#9-测试数据--fixtures-规范)
10. [统计与优先级](#10-统计与优先级)

---

## 1. 测试策略与金字塔

```
                /\
               /E2E\         5 ~ 8 条   ── 关键路径，patrol / integration_test
              /------\
             / Widget \     50 ~ 70 条  ── 渲染 + 交互 + 状态
            /----------\
           /    Unit    \  150 + 条     ── 仓库 / VM / 纯函数 / mapper
          /--------------\
         / Contract / Golden \  各 ~20 条 ── 接口契约 + 像素一致
```

**比例目标**：单测 60% / Widget 25% / 契约+Golden 10% / E2E 5%。

**优先级**：
- **P0（阻塞发布）**：登录、路由守卫、Mock 切换、Shell、表格、错误页
- **P1（必过）**：图表、Markdown、JSON、多标签、面包屑、权限
- **P2（增益）**：i18n、暗色模式、A11y、性能

---

## 2. 测试分层与工具

| 层 | 工具 | 位置 | 典型断言 |
|----|------|------|---------|
| 单元 | `flutter_test` + `mocktail` | `test/unit/**` | 纯函数返回、仓库 mock 调用 |
| Widget | `flutter_test` | `test/widget/**` | `find.byType` / 点击 / 状态变化 |
| Golden | `golden_toolkit` | `test/golden/**` | 截图与基线比对 |
| 契约 | `flutter_test` | `test/contract/**` | 抽象接口的所有实现共享同一测试 |
| 集成 | `integration_test` | `integration_test/**` | 全流程跳转 |
| E2E | `patrol`（可选） | `integration_test/e2e/**` | 真实点击 + 截图 + 网络断点 |
| 性能 | `flutter test --reporter` + `Timeline` | `test/perf/**` | 滚动 FPS / 启动耗时 |
| A11y | `flutter_test` `semantics` + axe-flutter | `test/a11y/**` | 语义节点 / 对比度 |

---

## 3. 测试 ID 命名规则

格式：`TC-<MODULE>-<NNN>` （Test Case），`TG-<PAGE>-<NNN>`（Golden），`TE-<NN>`（E2E）。

模块代号：

| 代号 | 模块 |
|------|------|
| AUTH | 登录 / 鉴权 |
| ROUTE | 路由 + 守卫 |
| SHELL | 应用壳 |
| TAB | 多标签 |
| SIDE | 侧栏 |
| CRUM | 面包屑 |
| CHART | 图表 |
| EDIT | 编辑器 |
| JSON | JSON 树形 |
| TABLE | 表格 |
| PERM | 权限 |
| ERR | 错误页 |
| LAYOUT | 自适应 |
| NET | 网络 / Mock |
| THEME | 主题 / 样式 |
| I18N | 国际化 |
| A11Y | 可访问性 |
| PERF | 性能 |
| SEC | 安全 |

---

## 4. 模块测试用例

### 4.1 AUTH — 登录与鉴权

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-AUTH-001 | 单元 | P0 | 用户名 `admin` 密码 `123456` | 调 `AuthRepository.login()` | 返回非空 `AuthToken`，`Storage` 被写入一次 |
| TC-AUTH-002 | 单元 | P0 | 用户名 `admin` 密码错误 | 同上 | 抛 `InvalidCredentialsException`，`Storage` 未被写入 |
| TC-AUTH-003 | 单元 | P0 | dio 抛 `SocketException` | 同上 | 抛 `NetworkException` |
| TC-AUTH-004 | 单元 | P0 | 已登录且 token 未过期 | 调 `isLoggedIn()` | 返回 `true` |
| TC-AUTH-005 | 单元 | P0 | token 已过期 | 调 `isLoggedIn()` | 返回 `false`，自动清除 storage |
| TC-AUTH-006 | 单元 | P1 | 任意已登录态 | 调 `logout()` | storage 清空，发出 `AuthEvent.loggedOut` |
| TC-AUTH-007 | Widget | P0 | 登录页空白 | 不填任何内容点提交 | 用户名输入框显示"必填"错误 |
| TC-AUTH-008 | Widget | P0 | 登录页 | 填错误凭证提交 | 出现 SnackBar `用户名或密码错误`，按钮恢复可点 |
| TC-AUTH-009 | Widget | P0 | 登录页 | 提交中 | 按钮显示 spinner 且 disabled |
| TC-AUTH-010 | Widget | P1 | 登录页 | 切换"显示密码" | 密码框 `obscureText` 变化 |
| TC-AUTH-011 | E2E | P0 | 冷启动应用 | 输入正确凭证 → 提交 | 跳转到 `/dashboard`，侧栏可见 |
| TC-AUTH-012 | 安全 | P0 | 登录成功 | dump 存储 | 明文密码不存在；token 在 secure storage |

### 4.2 ROUTE — 路由与守卫

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-ROUTE-001 | 单元 | P0 | 未登录 | 直接访问 `/dashboard` | redirect 到 `/login`，原 path 存入 `from` query |
| TC-ROUTE-002 | 单元 | P0 | 已登录 | 访问 `/login` | redirect 到 `/dashboard` |
| TC-ROUTE-003 | 单元 | P0 | 不存在路径 `/foo` | push | 渲染 404 页 |
| TC-ROUTE-004 | 单元 | P1 | role=guest | 访问 `/permission/admin` | redirect 到 403 |
| TC-ROUTE-005 | 集成 | P0 | 登录后 deep link `/charts?type=line` | 冷启动 | 跳转到该路径且参数传入 |
| TC-ROUTE-006 | 单元 | P1 | 多个嵌套 shell route | push 子路由 | 父路由不卸载（state 保活） |

### 4.3 SHELL / SIDE / TAB / CRUM — 应用壳

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-SHELL-001 | Widget | P0 | shell 渲染 | 默认状态 | 顶栏 + 侧栏 + 内容三块齐备 |
| TC-SIDE-001 | Widget | P0 | 菜单包含 3 个顶级 + 2 层子菜单 | 渲染 | 顶级显示，子菜单折叠 |
| TC-SIDE-002 | Widget | P0 | 同上 | 点击带子菜单的项 | 展开 / 折叠动画完成；ARIA expanded 切换 |
| TC-SIDE-003 | Widget | P1 | 当前路由 `/charts/line` | 渲染 | 对应叶子项高亮，祖先项展开 |
| TC-SIDE-004 | Widget | P1 | 菜单深度 4 级 | 渲染 | 缩进正确，无遮挡 |
| TC-TAB-001 | Widget | P0 | 0 个标签 | 打开 `/dashboard` | 标签数 = 1，激活 |
| TC-TAB-002 | Widget | P0 | 已有 3 个标签 | 再次点击第二个标签对应菜单 | 标签数仍为 3，激活切到该标签 |
| TC-TAB-003 | Widget | P0 | 多标签 | 在表格页输入了筛选，切到其它再回来 | 筛选条件保留（IndexedStack 保活） |
| TC-TAB-004 | Widget | P0 | 多标签 | 关闭非激活标签 | 标签消失，当前激活不变 |
| TC-TAB-005 | Widget | P0 | 多标签 | 关闭激活标签 | 激活回退到左侧相邻；若是首个则切到右侧 |
| TC-TAB-006 | Widget | P1 | 多标签 | 右键 / 长按 → "关闭其它" | 仅保留当前 |
| TC-TAB-007 | Widget | P1 | 多标签 | "关闭全部" | 标签清空，跳转 `/dashboard` |
| TC-TAB-008 | 单元 | P1 | 标签数 > 屏宽 | 计算溢出 | 出现"更多"下拉 |
| TC-CRUM-001 | Widget | P0 | 路由 `/charts/line` | 渲染 | 面包屑：首页 / 图表 / 折线 |
| TC-CRUM-002 | Widget | P0 | 点击面包屑中"图表" | — | 路由跳到 `/charts` |
| TC-CRUM-003 | Widget | P1 | 路由参数变化 `/table?page=2` | 渲染 | 面包屑保持稳定 |

### 4.4 LAYOUT — 自适应

| ID | 类型 | 优先级 | 屏幕宽度 | When | Then |
|----|------|--------|---------|------|------|
| TC-LAYOUT-001 | Widget | P0 | 360 (sm) | 渲染 shell | 侧栏隐藏，左上角汉堡菜单可见 |
| TC-LAYOUT-002 | Widget | P0 | 768 (md) | 同上 | 侧栏 collapsed（仅图标） |
| TC-LAYOUT-003 | Widget | P0 | 1280 (lg) | 同上 | 侧栏展开（图标 + 文字） |
| TC-LAYOUT-004 | Widget | P1 | 360 → 1280 实时变化 | resize | 三种状态依次切换无溢出 |
| TC-LAYOUT-005 | Widget | P1 | 360 | 点汉堡 | Drawer 弹出 |

### 4.5 NET — 网络与 Mock

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-NET-001 | 单元 | P0 | Mock 拦截器启用 | GET `/api/menus` | 返回 fixture `menus.json` 内容 |
| TC-NET-002 | 单元 | P0 | Mock 关闭，BaseUrl 配置 | 同请求 | 真正发请求（用 mocktail 验证 dio adapter） |
| TC-NET-003 | 单元 | P0 | 拦截器收到 401 | — | 触发 logout 事件 + 跳转 `/login` |
| TC-NET-004 | 单元 | P1 | 请求超时 5s | — | 抛 `NetworkException(reason: timeout)` |
| TC-NET-005 | 单元 | P1 | 401 + token 可刷新 | — | 自动 refresh + 重放原请求 |
| TC-NET-006 | 契约 | P0 | 任意 `ApiClient` 实现 | 必跑 contract 套件 | 5 条标准化方法行为一致 |

### 4.6 CHART — 图表

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-CHART-001 | Widget | P1 | 折线数据 7 点 | 渲染 | 7 个 spot，X/Y 轴标签正确 |
| TC-CHART-002 | Widget | P1 | 空数据 `[]` | 渲染 | 显示"暂无数据"占位 |
| TC-CHART-003 | Widget | P1 | 数据加载中 | 渲染 | shimmer / spinner |
| TC-CHART-004 | Widget | P1 | 网络错误 | 渲染 | 错误提示 + 重试按钮 |
| TC-CHART-005 | Widget | P1 | 4 种图表 tab | 切换 | 状态隔离，互不污染 |
| TC-CHART-006 | Widget | P2 | 鼠标悬停柱状图某柱 | hover | tooltip 显示该柱的数值 |
| TC-CHART-007 | Golden | P1 | 各类型图首屏 | render | 与基线 ≤ 0.5% 像素差 |

### 4.7 EDIT — 编辑器

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-EDIT-001 | Widget | P1 | 空 Markdown 编辑器 | 输入 `# hi` | 预览区显示 `<h1>hi</h1>` 样式 |
| TC-EDIT-002 | Widget | P1 | MD 文本含代码块 | 渲染预览 | 出现 `<pre>` 块 + 等宽字体 |
| TC-EDIT-003 | Widget | P1 | 富文本编辑器 | 选中文字点 B | 文字变粗 |
| TC-EDIT-004 | Widget | P1 | 富文本 | 上传图片（Mock 返回 url） | 图片占位 → 真实预览 |
| TC-EDIT-005 | 单元 | P1 | Quill Delta | 调 `toMarkdown()` | 输出与预期一致 |
| TC-EDIT-006 | Widget | P2 | 编辑器内容 | 触发"导出" | 下载 / 复制到剪贴板 |

### 4.8 JSON — JSON 树形

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-JSON-001 | Widget | P1 | 简单对象 `{a:1, b:[2,3]}` | 渲染 | 显示 2 个键，`b` 可展开 |
| TC-JSON-002 | Widget | P1 | 嵌套 5 层 | 渲染 | 默认折叠到 2 层 |
| TC-JSON-003 | Widget | P1 | 任意节点 | 点击展开/折叠图标 | 子节点显示/隐藏 |
| TC-JSON-004 | Widget | P1 | 节点 | 点"复制" | 剪贴板包含子树 JSON |
| TC-JSON-005 | Widget | P2 | 100KB JSON | 渲染 | 首屏 < 200ms，不冻 UI（虚拟化） |
| TC-JSON-006 | Widget | P2 | 非法 JSON 输入 | parse | 显示错误位置 |

### 4.9 TABLE — 表格与导出

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-TABLE-001 | Widget | P0 | 100 行数据 | 渲染 | 默认页 10 行显示 |
| TC-TABLE-002 | Widget | P0 | 同上 | 点表头"年龄"↑ | 按 age 升序，箭头切到↓的预备 |
| TC-TABLE-003 | Widget | P0 | 同上 | 再点同表头 | 切到 age 降序 |
| TC-TABLE-004 | Widget | P0 | 同上 | 翻到第 3 页 | 显示 21~30 行 |
| TC-TABLE-005 | Widget | P0 | 顶部搜索框输 "li" | input | 仅显示名字含 "li" 的行，分页器更新 |
| TC-TABLE-006 | Widget | P0 | 同上 | 点"导出 CSV" | 触发下载（Web）/ 保存到临时目录（Native），CSV 内容与当前过滤+排序一致 |
| TC-TABLE-007 | 单元 | P0 | DataRow 列表 | `toCsv()` | 字段含引号 / 逗号 / 换行被正确转义 |
| TC-TABLE-008 | Widget | P1 | 选中 3 行 | 看顶部 | 显示"已选 3 项" + 批量删除按钮 |
| TC-TABLE-009 | Widget | P1 | 列宽拖拽 | 拖动 | 列宽变化，下次回到该页保留 |
| TC-TABLE-010 | 性能 | P1 | 10 000 行数据 | 滚动到底 | FPS ≥ 55（在 Profile 模式） |

### 4.10 PERM — 权限

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-PERM-001 | 单元 | P0 | role=`admin` | `canAccess('user.delete')` | true |
| TC-PERM-002 | 单元 | P0 | role=`editor` | 同上 | false |
| TC-PERM-003 | Widget | P0 | role=`guest` 进入演示页 | 渲染 | "仅访客可见"模块出现，"管理员模块"被 hide |
| TC-PERM-004 | Widget | P0 | role 切换 | 同页 | UI 实时更新（Riverpod 监听） |
| TC-PERM-005 | 单元 | P0 | 服务端返回的菜单与 role 不匹配 | 路由注册 | 该菜单不渲染（双层防护） |

### 4.11 ERR — 错误页

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-ERR-001 | Widget | P0 | 路由 `/__nope` | 进入 | 渲染 404，含"返回首页"按钮 |
| TC-ERR-002 | Widget | P0 | 401 拦截器触发 | — | 跳 401 页 + 3s 后回 `/login` |
| TC-ERR-003 | Widget | P1 | 500 mock 响应 | API 调用 | 错误 banner 显示并可重试 |
| TC-ERR-004 | Widget | P1 | widget 内 throw | 渲染 | `ErrorWidget.builder` 接管，不白屏 |

### 4.12 THEME — 主题与样式

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-THEME-001 | 单元 | P1 | 默认 theme | 取 `primary` | 与设计 token `#1890ff` 等 |
| TC-THEME-002 | Widget | P2 | 切到 dark | 重启 | persisted；颜色翻转 |
| TC-THEME-003 | Golden | P1 | light / dark 各一张关键页 | 渲染 | 与基线一致 |

### 4.13 I18N — 国际化

| ID | 类型 | 优先级 | Given | When | Then |
|----|------|--------|-------|------|------|
| TC-I18N-001 | 单元 | P2 | locale=zh-CN | 取 `login.title` | "登录" |
| TC-I18N-002 | 单元 | P2 | locale=en-US | 同上 | "Sign In" |
| TC-I18N-003 | Widget | P2 | 切换语言 | 整页 | 文案实时切换，不需重启 |
| TC-I18N-004 | 单元 | P2 | arb 缺 key | 启动 | CI 失败（拒绝缺译） |

---

## 5. 跨模块 / 端到端用例（E2E）

| ID | 路径 | 步骤 | 断言 |
|----|------|------|------|
| TE-01 | 登录到主页 | 输入凭证 → 提交 → 等待跳转 | url=`/dashboard`，侧栏 + 顶栏 + 标签可见 |
| TE-02 | 浏览图表并新开标签 | 主页 → 点"图表"侧栏 → 点折线 → 切到柱状 | 顶部 3 个标签，最后激活柱状 |
| TE-03 | 表格筛选 + 导出 | 进入表格页 → 输入"li" → 点导出 | 触发 CSV，文件名规则匹配，内容行数 = 过滤后 |
| TE-04 | 多标签状态保留 | 表格输筛选 → 切到 JSON → 回到表格 | 筛选值仍在 |
| TE-05 | 关闭激活标签 | 三标签场景 → 关闭中间激活的 | 自动激活到左侧 |
| TE-06 | 权限切换 | 退出 → 用 editor 登录 → 进权限页 | "管理员模块"看不到 |
| TE-07 | 路由守卫 | 未登录直访 `/charts` | 跳 `/login?from=/charts` → 登录后回 `/charts` |
| TE-08 | 错误恢复 | Mock 让一次 API 500 → 点重试 | 第二次正常 |

---

## 6. 非功能测试

### 6.1 性能（PERF）

| ID | 指标 | 阈值 | 测量方法 |
|----|------|------|---------|
| TC-PERF-001 | 冷启动到首屏 | ≤ 2 s （release on Pixel 6 / iPhone 12） | `Timeline` |
| TC-PERF-002 | 路由切换平均帧时 | ≤ 16ms p95 | `Timeline.frames` |
| TC-PERF-003 | 表格 10k 行滚动 | FPS ≥ 55 | `flutter drive --profile` |
| TC-PERF-004 | 包体（Android release） | ≤ 25 MB | `flutter build apk` |

### 6.2 可访问性（A11Y）

| ID | 校验 | 工具 |
|----|------|------|
| TC-A11Y-001 | 所有交互元素有 `Semantics.label` | `find.bySemanticsLabel` |
| TC-A11Y-002 | 文本对比度 ≥ 4.5 | 自动化扫主题色 |
| TC-A11Y-003 | 键盘 Tab 顺序合理（Web） | manual + 录制 |
| TC-A11Y-004 | 屏幕阅读器朗读关键流程 | 手测 + 报告 |

### 6.3 安全（SEC）

| ID | 校验 |
|----|------|
| TC-SEC-001 | token 仅存 `flutter_secure_storage`，不进日志 |
| TC-SEC-002 | 网络层禁用 HTTP（除 dev mock） |
| TC-SEC-003 | 日志脱敏（用户名 / token 不写入 file log） |
| TC-SEC-004 | 依赖审计（`flutter pub outdated` + 已知 CVE） |

### 6.4 国际化已在 §4.13。

---

## 7. Golden 测试矩阵

| ID | 页面 | 屏幕组合 | 主题 |
|----|------|---------|------|
| TG-LOGIN-01 | 登录页 | 360×800 / 1280×800 | light |
| TG-SHELL-01 | 主壳（侧栏展开） | 1280×800 | light + dark |
| TG-SHELL-02 | 主壳（侧栏折叠） | 768×800 | light |
| TG-SHELL-03 | 主壳（移动 drawer） | 360×800 | light |
| TG-CHART-01 | 折线 | 1280×800 | light |
| TG-CHART-02 | 柱状 | 1280×800 | light |
| TG-CHART-03 | 饼图 | 1280×800 | light |
| TG-CHART-04 | 仪表 | 1280×800 | light |
| TG-TABLE-01 | 表格首页 | 1280×800 | light |
| TG-TABLE-02 | 表格过滤+选中 | 1280×800 | light |
| TG-EDIT-MD-01 | MD 编辑器 | 1280×800 | light |
| TG-EDIT-RT-01 | 富文本 | 1280×800 | light |
| TG-JSON-01 | JSON 默认 | 1280×800 | light |
| TG-PERM-01 | 权限演示 | 1280×800 | light |
| TG-404-01 | 404 | 1280×800 | light |

字体策略：**强制加载 `Noto Sans CJK` + `Roboto`** 避免跨平台像素差。

---

## 8. 回归与 CI 门禁

### 每次 PR
1. `flutter analyze` 零警告
2. `dart format --set-exit-if-changed`
3. `flutter test --coverage`
4. 行覆盖增量不下降；模块新增文件 ≥ 90%
5. Golden 比对：差异 > 0.5% 失败
6. 不允许 `skip:` 标签除非附说明

### 合并到 main
1. 全量回归（P0+P1 用例）
2. `integration_test` 至少跑 Android emu + Web Chrome
3. Codecov 总覆盖 ≥ 80% 才能合
4. 性能基线对比（前一晚 baseline）

### 夜间 CI
- 全平台构建（Android / iOS / Web / macOS）
- 全部 E2E
- 性能跑分入库

---

## 9. 测试数据 / Fixtures 规范

```
test/fixtures/
├── auth/
│   ├── login_success.json
│   ├── login_invalid.json
│   ├── token_expired.json
│   └── role_admin.json / role_editor.json / role_guest.json
├── menus/
│   ├── menus_admin.json
│   └── menus_guest.json
├── charts/
│   ├── line.json / bar.json / pie.json / gauge.json
│   ├── empty.json / error.json
├── table/
│   ├── users_100.json
│   ├── users_10000.json    # 性能用
│   ├── users_with_escapes.json  # CSV 转义用
├── json/
│   ├── shallow.json / nested_5.json / large_100kb.json / invalid.json
└── editor/
    └── markdown_samples.md
```

**约定**：
- 所有 fixture 必须有 schema（用 `freezed` 模型可反序列化）
- 修改 fixture 必须同时更新使用它的测试
- 大文件（>50KB）走 `git lfs`

---

## 10. 统计与优先级

| 模块 | P0 | P1 | P2 | 总计 |
|------|----|----|----|------|
| AUTH | 7 | 4 | 1 | 12 |
| ROUTE | 4 | 2 | 0 | 6 |
| SHELL/SIDE/TAB/CRUM | 9 | 7 | 0 | 16 |
| LAYOUT | 3 | 2 | 0 | 5 |
| NET | 3 | 3 | 0 | 6 |
| CHART | 0 | 6 | 1 | 7 |
| EDIT | 0 | 5 | 1 | 6 |
| JSON | 0 | 4 | 2 | 6 |
| TABLE | 7 | 3 | 0 | 10 |
| PERM | 5 | 0 | 0 | 5 |
| ERR | 2 | 2 | 0 | 4 |
| THEME | 0 | 2 | 1 | 3 |
| I18N | 0 | 0 | 4 | 4 |
| E2E | 6 | 2 | 0 | 8 |
| PERF / A11Y / SEC / GOLDEN | 9 | 6 | 6 | 21 |
| **合计** | **55** | **48** | **16** | **119** |

> **发布定义**：P0 = 100% 通过 / P1 ≥ 95% / P2 不要求；Golden 零未审计差异。
