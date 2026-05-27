# framework_wz

Flutter port of [vue-framework-wz](https://github.com/herozhou/vue-framework-wz) — a multi-tab admin dashboard framework.

Work plan and test plan live under [`task/`](task/README.md). Test-first delivery: every feature maps to test IDs defined in [`task/04-test-plan.md`](task/04-test-plan.md).

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run -d chrome --dart-define=USE_MOCK=true
```

## Project layout

```
lib/
├── main.dart
├── app/                       App shell (MaterialApp, ProviderScope)
├── core/                      Framework code (no business)
│   ├── network/               dio + interceptors (incl. mock)
│   ├── storage/               secure + prefs wrappers
│   ├── router/                go_router + guards
│   ├── theme/                 colors / typography / spacing
│   ├── i18n/                  ARB-based localization
│   └── widgets/               Reusable widgets
└── features/                  Feature slices
    ├── auth/                  Login, logout, token
    ├── shell/                 Sidebar, tabs, breadcrumb
    ├── dashboard/
    ├── charts/                fl_chart
    ├── editor_markdown/
    ├── editor_richtext/
    ├── json_view/
    ├── table/                 data_table_2 + CSV export
    ├── permission/
    └── errors/
```

## Test layout

```
test/
├── unit/                      Pure / repo / view-model tests
├── widget/                    Single-widget render & interaction
├── golden/                    Snapshot pixel parity
├── contract/                  Interface contracts (shared across impls)
└── fixtures/                  JSON test data
integration_test/              End-to-end flows
```

## Commands

| Command | What it does |
|---------|--------------|
| `flutter pub get` | Install deps |
| `dart run build_runner build --delete-conflicting-outputs` | Generate freezed / json / riverpod |
| `flutter analyze` | Static analysis (must be zero warnings) |
| `dart format .` | Format |
| `flutter test --coverage` | Unit + widget + golden |
| `flutter test --update-goldens` | Refresh goldens after intentional UI change |
| `flutter test integration_test/` | Integration tests |
| `flutter run -d chrome --dart-define=USE_MOCK=true` | Run with mock data |

## Acceptance

See [`task/04-test-plan.md`](task/04-test-plan.md) §10. P0 100% pass, P1 ≥ 95%, coverage ≥ 80%.
