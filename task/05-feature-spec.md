# 05 — 特性规范（契约 + 测试映射）

> 每个特性一节：**契约接口 / 行为约定 / 视觉规范 / 关联测试 ID**。
> 这是 L2 → L3 派单时复制到 task 卡的"输入 + 验收"。

## 1. 通用规范

- **状态机**：每个有异步交互的特性都用 `AsyncValue<T>`（Riverpod）三态：loading / data / error。UI 必须显式处理三态。
- **错误展示**：统一通过 `ErrorView(message, onRetry)` 组件，不允许散落。
- **加载占位**：列表/卡片用 `Shimmer`，按钮用内嵌 `CircularProgressIndicator`。
- **复制反馈**：所有"复制"动作必有 `SnackBar` 反馈 1.5s。

---

## 2. AUTH — 登录与鉴权

### 2.1 抽象接口
```dart
abstract class AuthRepository {
  Future<AuthToken> login(String username, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserProfile?> currentUser();
  Stream<AuthEvent> events();
}
```

### 2.2 行为
- 登录成功后 token 写 `flutter_secure_storage`，用户信息走 `shared_preferences`。
- token 字段：`accessToken / refreshToken / expiresAt`。
- 失败原因明确暴露：`InvalidCredentials / NetworkError / ServerError`。
- 登录页支持"记住我"（仅记用户名，不记密码）。

### 2.3 视觉
- 居中卡片：宽 360（移动满屏）/ 420（桌面）。
- 主按钮：主色填充，圆角 8，高 44。
- 失败 SnackBar 红色背景，2s 自动隐藏。

### 2.4 关联测试
TC-AUTH-001..012, TE-01, TE-07, TG-LOGIN-01

---

## 3. ROUTE / SHELL — 路由与应用壳

### 3.1 路由表（go_router）
```
/login                                  # 公开
/                                       # redirect → /dashboard
ShellRoute (AppShell)
├── /dashboard
├── /charts/:type                        # type ∈ {line, bar, pie, gauge}
├── /editor/markdown
├── /editor/richtext
├── /json
├── /table
├── /permission                         # role-gated
├── /401  /403  /500
└── *  → /404
```

### 3.2 ShellRoute 契约
- 暴露 `child` 插槽。
- 顶栏左侧汉堡（仅 sm）+ 面包屑 + 右侧用户菜单。
- 侧栏：根据 `MenuRepository.list(role)` 渲染。
- 标签条：跟随当前路由自动添加；切换/关闭只在标签条交互。

### 3.3 关联测试
TC-ROUTE-001..006, TC-SHELL-001, TC-SIDE-001..004, TC-CRUM-001..003, TC-LAYOUT-001..005, TG-SHELL-01..03

---

## 4. TAB — 多标签详细行为

| 场景 | 行为 |
|------|------|
| 重复打开同一路由 | 不新增标签，激活已有 |
| URL 带 query | query 不同视为同一标签（除非显式声明唯一化键） |
| 关闭激活 | 默认激活左侧；若左无则激活右侧；若全无则跳 `/dashboard` |
| 标签条溢出 | 出现"…"下拉，按 LRU 排序 |
| 持久化 | tabs 列表写 `shared_preferences`，下次启动恢复 |

### 关联测试
TC-TAB-001..008, TE-04, TE-05

---

## 5. CHART — 图表

### 5.1 子页面
- `/charts/line`、`/charts/bar`、`/charts/pie`、`/charts/gauge`

### 5.2 数据契约
```dart
abstract class ChartDataSource {
  Future<List<SeriesPoint>> fetch({required ChartType type});
}
```

### 5.3 行为
- 默认从 Mock 拿（fixture 见 [04-test-plan.md §9](04-test-plan.md#9-测试数据--fixtures-规范)）。
- 三态：loading / data / error；data 为 `[]` 时显示空态。
- 折线 / 柱状支持 hover tooltip（Web/Desktop），mobile 支持 tap-to-show。

### 关联测试
TC-CHART-001..007, TG-CHART-01..04

---

## 6. EDIT — 编辑器

### 6.1 Markdown 编辑器
- 双栏：左输入 / 右预览（窄屏切 tab）。
- 支持工具栏快捷插入（H1~H3、bold、link、code block、image）。
- 图片上传走 `UploadGateway`（Mock 直接回固定 URL）。

### 6.2 富文本编辑器
- 基于 `flutter_quill`。
- 工具栏：B / I / U / 颜色 / 列表 / 引用 / 链接 / 图片。
- 输出格式：Quill Delta JSON。

### 关联测试
TC-EDIT-001..006, TG-EDIT-MD-01, TG-EDIT-RT-01

---

## 7. JSON — 树形展示

### 7.1 组件 API
```dart
JsonTreeView(
  data: dynamic,
  initialDepth: 2,
  onCopy: (subtree) {},
)
```

### 7.2 行为
- 节点类型展示带颜色：string 绿、number 蓝、bool 紫、null 灰、object/array 折叠图标。
- 数组 / 对象首行显示子项数。
- 深嵌套虚拟化（>500 节点时启用 lazy）。

### 关联测试
TC-JSON-001..006, TG-JSON-01

---

## 8. TABLE — 表格 & CSV 导出

### 8.1 列定义
| 列 | key | 类型 | 可排序 | 默认显示 |
|----|-----|------|--------|---------|
| ID | id | int | ✓ | ✓ |
| 姓名 | name | string | ✓ | ✓ |
| 邮箱 | email | string | ✗ | ✓ |
| 年龄 | age | int | ✓ | ✓ |
| 注册时间 | createdAt | DateTime | ✓ | ✓ |
| 状态 | status | enum | ✗ | ✓ |

### 8.2 行为
- 默认 10 行 / 页，可选 10/20/50/100。
- 搜索 = 在 name + email 上 `contains`，case-insensitive。
- 排序键 → URL `?sort=age,desc`，支持深链。
- 导出 CSV：Web 触发下载 / Native 用 `path_provider` 写到临时目录 + 弹分享。
- 字段含 `,`、`"`、换行：按 RFC 4180 转义。

### 关联测试
TC-TABLE-001..010, TE-03, TG-TABLE-01..02

---

## 9. PERM — 权限演示

### 9.1 RoleService
```dart
abstract class RoleService {
  Stream<Role> currentRole();
  Future<void> setRole(Role r);   // 仅 demo 用
  bool can(String permission);
}
```

### 9.2 演示页内容
- 顶部三个 chip：`admin / editor / guest` 切换。
- 三个区块：
  1. 仅 admin 可见
  2. admin + editor 可见
  3. 所有人可见
- 演示路由级守卫："访问 `/permission/admin`" 按钮在 guest 角色下点不动 / 给提示。

### 关联测试
TC-PERM-001..005, TE-06, TG-PERM-01

---

## 10. ERR — 错误页

### 10.1 页面
| 路径 | 内容 |
|------|------|
| `/404` | 大图 + "页面不存在" + 返回首页按钮 |
| `/401` | "请重新登录" + 自动 3s 跳 `/login` |
| `/403` | "无权限" + 返回 |
| `/500` | "服务器开小差" + 重试 |

### 10.2 全局错误兜底
- `MaterialApp.builder` 设置 `ErrorWidget.builder`，开发模式显示堆栈，发布模式显示通用错误页 + 上报。

### 关联测试
TC-ERR-001..004, TG-404-01

---

## 11. THEME — 设计 token

### 11.1 token（参考源项目 + Material 化）
```dart
class AppColors {
  static const primary    = Color(0xFF1890FF);  // 蓝（对齐源项目）
  static const success    = Color(0xFF52C41A);
  static const warning    = Color(0xFFFAAD14);
  static const danger     = Color(0xFFF5222D);
  static const bgPage     = Color(0xFFF0F2F5);
  static const bgSidebar  = Color(0xFF001529);  // 深色侧栏
  static const txtSidebar = Color(0xFFB7BDC6);
}
class AppSpacing { static const xs=4, sm=8, md=16, lg=24, xl=32; }
class AppRadius  { static const sm=4, md=8, lg=12; }
```

### 11.2 暗色
- v1 仅准备 ThemeData 切换 hook，UI 验证用 light 主题。
- 暗色 golden 见 TG-SHELL-01。

### 关联测试
TC-THEME-001..003

---

## 12. NET / MOCK — 网络层

### 12.1 dio 拦截器顺序
1. `AuthInterceptor`（注入 Bearer）
2. `LoggingInterceptor`（dev only）
3. `MockInterceptor`（dev/test only，根据 `--dart-define=USE_MOCK=true`）
4. `ErrorMapperInterceptor`（HTTP 状态码 → 领域异常）
5. `RetryInterceptor`（5xx 重试 1 次）

### 12.2 切换 Mock / 真实
- 环境变量 `USE_MOCK`（true / false）+ `API_BASE_URL`。
- `MockInterceptor` 仅当 `USE_MOCK=true` 时启用。

### 关联测试
TC-NET-001..006

---

## 13. 任务卡示例（套用 02 中模板）

> 把这种结构填给 L3，L3 看到就能干活。

```yaml
task_id: T-TABLE-005
owner: L3-Table
parent: L2-FEATURE
inputs:
  contracts:
    - lib/features/table/domain/table_repository.dart
    - test/fixtures/table/users_100.json
    - test/fixtures/table/users_with_escapes.json
  dependencies_done: [T-DATA-002, T-UI-CARD-001]
outputs:
  files:
    - lib/features/table/presentation/table_page.dart
    - lib/features/table/presentation/table_view_model.dart
    - lib/features/table/data/csv_exporter.dart
acceptance:
  tests: [TC-TABLE-001, TC-TABLE-002, TC-TABLE-003, TC-TABLE-004, TC-TABLE-005, TC-TABLE-006, TC-TABLE-007, TG-TABLE-01]
  coverage_min: 0.9
done_when:
  - flutter test test/features/table/ 全绿
  - golden 与 baseline 一致
  - PR review approved
```
