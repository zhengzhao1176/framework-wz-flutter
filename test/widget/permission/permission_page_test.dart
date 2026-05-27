import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/auth/application/auth_providers.dart';
import 'package:framework_wz/features/auth/domain/auth_models.dart';
import 'package:framework_wz/features/permission/permission_page.dart';

import '../../helpers/fake_auth_repository.dart';

/// TC-PERM-003 — role-based widget visibility.
void main() {
  Future<void> pump(WidgetTester tester, Role role) async {
    final repo = FakeAuthRepository(role: role);
    await repo.login(role.name, '123456');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: Scaffold(body: PermissionPage())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('admin sees all three blocks', (tester) async {
    await pump(tester, Role.admin);
    expect(find.byKey(const Key('perm.admin')), findsOneWidget);
    expect(find.byKey(const Key('perm.editor')), findsOneWidget);
    expect(find.byKey(const Key('perm.everyone')), findsOneWidget);
  });

  testWidgets('editor sees editor + everyone, not admin', (tester) async {
    await pump(tester, Role.editor);
    expect(find.byKey(const Key('perm.admin')), findsNothing);
    expect(find.byKey(const Key('perm.editor')), findsOneWidget);
    expect(find.byKey(const Key('perm.everyone')), findsOneWidget);
  });

  testWidgets('guest sees only everyone', (tester) async {
    await pump(tester, Role.guest);
    expect(find.byKey(const Key('perm.admin')), findsNothing);
    expect(find.byKey(const Key('perm.editor')), findsNothing);
    expect(find.byKey(const Key('perm.everyone')), findsOneWidget);
  });
}
