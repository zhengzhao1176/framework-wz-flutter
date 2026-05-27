import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/auth/application/auth_providers.dart';
import 'package:framework_wz/features/auth/domain/auth_models.dart';
import 'package:framework_wz/features/shell/application/menu_models.dart';
import 'package:framework_wz/features/shell/application/menu_providers.dart';
import 'package:framework_wz/features/shell/presentation/sidebar.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fake_auth_repository.dart';

/// TC-SIDE-001..003 — sidebar render + interaction.
void main() {
  Future<void> pump(WidgetTester tester, {String initialRoute = '/dashboard'}) async {
    final menus = [
      const MenuNode(key: 'dashboard', title: '仪表盘', path: '/dashboard'),
      MenuNode(
        key: 'charts',
        title: '图表',
        children: const [
          MenuNode(key: 'line', title: '折线图', path: '/charts/line'),
          MenuNode(key: 'bar', title: '柱状图', path: '/charts/bar'),
        ],
      ),
    ];
    final router = GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Scaffold(body: Sidebar()),
        ),
        GoRoute(
          path: '/charts/:type',
          builder: (_, __) => const Scaffold(body: Sidebar()),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(role: Role.admin)),
          menuListProvider.overrideWith((_) async => menus),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('TC-SIDE-001 top-level items render; nested collapsed by default', (tester) async {
    await pump(tester);
    expect(find.text('仪表盘'), findsOneWidget);
    expect(find.text('图表'), findsOneWidget);
    expect(find.text('折线图'), findsNothing); // collapsed initially
  });

  testWidgets('TC-SIDE-002 tapping group toggles expand', (tester) async {
    await pump(tester);
    await tester.tap(find.text('图表'));
    await tester.pumpAndSettle();
    expect(find.text('折线图'), findsOneWidget);
    expect(find.text('柱状图'), findsOneWidget);
  });

  testWidgets('TC-SIDE-003 current route auto-expands ancestor', (tester) async {
    await pump(tester, initialRoute: '/charts/line');
    expect(find.text('折线图'), findsOneWidget);
  });
}
