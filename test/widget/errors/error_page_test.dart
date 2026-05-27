import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/errors/error_pages.dart';
import 'package:go_router/go_router.dart';

/// TC-ERR-001 — 404 page renders + home button works.
void main() {
  testWidgets('TC-ERR-001 404 page renders with returnable home button', (tester) async {
    String? lastRoute;
    final router = GoRouter(
      initialLocation: '/404',
      routes: [
        GoRoute(
          path: '/404',
          builder: (_, __) => const ErrorPage(code: 404),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) {
            lastRoute = '/dashboard';
            return const Scaffold(body: Text('home'));
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('页面不存在'), findsOneWidget);
    expect(find.byKey(const Key('error.goHome')), findsOneWidget);

    await tester.tap(find.byKey(const Key('error.goHome')));
    await tester.pumpAndSettle();
    expect(lastRoute, '/dashboard');
  });

  testWidgets('TC-ERR-002 401 page renders with hint text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ErrorPage(code: 401)),
    );
    await tester.pump();
    expect(find.text('401'), findsOneWidget);
    expect(find.textContaining('登录'), findsAtLeastNWidgets(1));
  });
}
