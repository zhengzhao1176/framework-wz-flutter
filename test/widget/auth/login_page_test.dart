import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/auth/application/auth_providers.dart';
import 'package:framework_wz/features/auth/domain/auth_repository.dart';
import 'package:framework_wz/features/auth/presentation/login_page.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fake_auth_repository.dart';

/// TC-AUTH-007..010 — login form behavior.
void main() {
  Future<void> pumpLogin(WidgetTester tester, AuthRepository repo) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Scaffold(body: Text('dashboard')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  testWidgets('TC-AUTH-007 empty submit shows validation errors', (tester) async {
    final repo = FakeAuthRepository();
    await pumpLogin(tester, repo);

    await tester.enterText(find.byKey(const Key('login.username')), '');
    await tester.enterText(find.byKey(const Key('login.password')), '');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();

    expect(find.text('请输入用户名'), findsOneWidget);
  });

  testWidgets('TC-AUTH-008 wrong credentials show SnackBar', (tester) async {
    final repo = FakeAuthRepository(throwOn: 'wrong');
    await pumpLogin(tester, repo);

    await tester.enterText(find.byKey(const Key('login.username')), 'admin');
    await tester.enterText(find.byKey(const Key('login.password')), 'wrong');
    await tester.tap(find.byKey(const Key('login.submit')));
    // Login page has a perpetual particle animation; use timed pumps so we
    // don't deadlock waiting for it to settle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.textContaining('用户名或密码错误'), findsOneWidget);
  });

  testWidgets('TC-AUTH-009 submitting disables button + shows spinner', (tester) async {
    final repo = FakeAuthRepository(delay: const Duration(milliseconds: 500));
    await pumpLogin(tester, repo);

    await tester.enterText(find.byKey(const Key('login.username')), 'admin');
    await tester.enterText(find.byKey(const Key('login.password')), '123456');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump(const Duration(milliseconds: 100));

    final btn = tester.widget<ElevatedButton>(find.byKey(const Key('login.submit')));
    expect(btn.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('TC-AUTH-010 toggle visibility flips obscureText', (tester) async {
    final repo = FakeAuthRepository();
    await pumpLogin(tester, repo);

    final pwField = find.byKey(const Key('login.password'));
    TextField pw() => tester.widget<TextField>(find.descendant(
          of: pwField,
          matching: find.byType(TextField),
        ));

    expect(pw().obscureText, isTrue);
    await tester.tap(find.byKey(const Key('login.toggleObscure')));
    await tester.pump();
    expect(pw().obscureText, isFalse);
  });
}
