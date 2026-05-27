import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/auth/application/auth_providers.dart';
import 'package:framework_wz/features/auth/presentation/login_page.dart';

import '../../helpers/fake_auth_repository.dart';

/// Standalone smoke test for the form layout.
void main() {
  testWidgets('login page composes username / password / submit', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('login.username')), findsOneWidget);
    expect(find.byKey(const Key('login.password')), findsOneWidget);
    expect(find.byKey(const Key('login.submit')), findsOneWidget);
    expect(find.text('登录'), findsAtLeastNWidgets(1));
  });
}
