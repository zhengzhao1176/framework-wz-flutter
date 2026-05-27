import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/shell/application/menu_models.dart';
import 'package:framework_wz/features/shell/application/menu_providers.dart';
import 'package:framework_wz/features/shell/presentation/breadcrumb.dart';
import 'package:go_router/go_router.dart';

/// TC-CRUM-001..002 — breadcrumb rendering and navigation.
void main() {
  Future<void> pump(WidgetTester tester, String location) async {
    final menus = [
      const MenuNode(key: 'dashboard', title: '仪表盘', path: '/dashboard'),
      MenuNode(
        key: 'charts',
        title: '图表',
        path: '/charts',
        children: const [
          MenuNode(key: 'line', title: '折线图', path: '/charts/line'),
        ],
      ),
    ];
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Scaffold(body: Breadcrumb()),
        ),
        GoRoute(
          path: '/charts',
          builder: (_, __) => const Scaffold(body: Breadcrumb()),
        ),
        GoRoute(
          path: '/charts/line',
          builder: (_, __) => const Scaffold(body: Breadcrumb()),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [menuListProvider.overrideWith((_) async => menus)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('TC-CRUM-001 renders 首页 / 图表 / 折线图 for nested route', (tester) async {
    await pump(tester, '/charts/line');
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('图表'), findsOneWidget);
    expect(find.text('折线图'), findsOneWidget);
  });
}
