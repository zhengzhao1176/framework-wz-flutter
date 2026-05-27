# 01 — 范围与架构

## 1. 复刻范围（IN / OUT）

### IN — 必须复刻
| 模块 | Vue 版能力 | Flutter 复刻形态 |
|------|-----------|-----------------|
| 登录 / 鉴权 | 用户名密码登录、token 持久化、登出 | `/login` 路由 + `AuthRepository` + 安全存储 |
| 路由 & 守卫 | Vue Router + 动态路由 | `go_router` + `redirect` 守卫 + 基于 role 的动态注册 |
| 全局布局 | 顶栏 + 侧栏 + 主区 + 多标签 | `Scaffold` + `AdaptiveLayout`（手机=抽屉, 平板/桌面=固定侧栏） |
| 动态侧栏 | 多级菜单、路由驱动 | `NavigationRail` / 自定义递归 `MenuTile` |
| 多 TAB 导航 | 打开多页签、关闭、保留状态 | `IndexedStack` + `TabsController`（state 保活） |
| 面包屑 | 跟随路由实时更新 | `Breadcrumb` widget 订阅 `GoRouter` 当前栈 |
| 图表 | ECharts | `fl_chart`（折线 / 柱状 / 饼图 / 仪表） |
| 富文本 / Markdown | Tinymce + MD | `flutter_quill` 或 `markdown_editor_plus` |
| JSON 展示 | JSON 树形 | 自研 `JsonTreeView`（支持折叠 / 复制） |
| 数据表格 | 排序 / 翻页 / 筛选 / 导出 CSV | `data_table_2` + `csv` 包 |
| 权限页面 | role-based 显示 | `PermissionGate` widget + role 检查 |
| 错误页 | 404 / 401 / 500 | `errorBuilder` + 专属页面 |
| Mock 数据 | mock.js 拦截 | `dio` Interceptor + 内置 fixtures |
| 自适应 | 大中小屏 | `LayoutBuilder` + 断点（<600, <1024, ≥1024） |

### OUT — 暂不复刻（写入"未来可选")
- 七牛云上传 SDK（用本地占位/Mock 上传替代，留扩展点）
- 主题在线切换（首版仅 light，dark 留 hook）
- 服务端真实 API（全程 Mock，预留 `BaseUrl` 切换）

## 2. 技术栈对齐

| 维度 | Vue 版 | Flutter 版选型 | 理由 |
|------|--------|----------------|------|
| 语言 | JS | Dart 3.x | Flutter 默认 |
| 框架 | Vue 2 | Flutter 3.x stable | LTS |
| 状态 | Vuex | **Riverpod 2** | 编译期 DI、易测试、不依赖 BuildContext |
| 路由 | Vue Router | **go_router** | 声明式 + redirect 守卫 + deep link |
| HTTP | axios | **dio** + retrofit | 拦截器生态 |
| Mock | mock.js | **dio Interceptor + JSON fixtures** | 与生产链路同形 |
| 图表 | ECharts | **fl_chart** | MIT、活跃、够用 |
| 富文本 | Tinymce | **flutter_quill** | 跨平台、可序列化 |
| 表格 | el-table | **data_table_2** | 大数据量、排序 |
| 持久化 | localStorage | `flutter_secure_storage` + `shared_preferences` | token 走安全存储 |
| 国际化 | i18n | `flutter_localizations` + `intl` | 内置 |
| 测试 | Jest | `flutter_test` + `integration_test` + `mocktail` + `golden_toolkit` + `patrol`(E2E) | 分层完整 |
| CI | — | GitHub Actions + Codecov | 强制门禁 |

## 3. 目标目录结构（Clean Architecture 风格）

```
lib/
├── main.dart
├── app/                       # 应用壳：MaterialApp / 主题 / Provider 根
├── core/                      # 框架级（无业务）
│   ├── network/               # dio + interceptors（含 Mock）
│   ├── storage/               # secure / prefs 封装
│   ├── router/                # go_router 配置 + guards
│   ├── theme/                 # 颜色 / 字体 / 间距
│   ├── i18n/                  # arb 文件 + 生成
│   └── widgets/               # 通用组件：Breadcrumb / JsonTreeView / PermissionGate
├── features/                  # 按特性切片
│   ├── auth/{data,domain,presentation}
│   ├── shell/                 # 布局 + 侧栏 + 多标签
│   ├── dashboard/
│   ├── charts/
│   ├── editor_markdown/
│   ├── editor_richtext/
│   ├── json_view/
│   ├── table/
│   ├── permission/
│   └── errors/
└── shared/                    # 跨特性的 model / util
test/                          # 单元 + widget
integration_test/              # 端到端
test/golden/                   # 黄金图
```

## 4. 关键架构决策（ADR 索引）

| ID | 决策 | 替代方案 | 选择理由 |
|----|------|---------|---------|
| ADR-01 | Riverpod 而非 Bloc / Provider | Bloc 模板繁，Provider 不利于测试 | DI + 可重写 + 编译期检查 |
| ADR-02 | go_router 而非 auto_route | auto_route 代码生成重 | 与 Vue Router 语义最近 |
| ADR-03 | 多 Tab 用 `IndexedStack` 保活 | 每次重建 | 复用源项目"标签状态保留"语义 |
| ADR-04 | Mock 走 dio Interceptor，不引专门库 | http_mock_adapter | 切换生产 API 零改动 |
| ADR-05 | 数据契约用 freezed + json_serializable | 手写 | 不可变 + 自动 equals |
| ADR-06 | 接口在 domain 层定义抽象，data 层实现 | 直接调用 | 便于单测注入 fake |

## 5. 与 Vue 版的对齐口径

- **行为对齐**：源项目存在的功能行为（如"关闭标签后回到上一个")必须有对应测试覆盖。
- **视觉接近**：颜色 / 间距向源项目靠拢（色板见 [05-feature-spec.md](05-feature-spec.md)），但允许 Material 风格小幅调整。
- **不抄路径**：路由命名遵循 Flutter 习惯（小写 + 短横线），不强求与 Vue 路径一致。
