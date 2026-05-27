import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/app/app.dart';
import 'package:framework_wz/core/storage/storage.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Capture every uncaught flutter error so we can dump them at the end.
  final caught = <FlutterErrorDetails>[];
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    caught.add(details);
    debugPrint('=== caught Flutter error ===');
    debugPrint('${details.exceptionAsString()}');
    debugPrint('${details.stack}');
    originalOnError?.call(details);
  };

  testWidgets('TE-01 login → dashboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStoreProvider.overrideWithValue(InMemorySecureStore()),
            prefsStoreProvider.overrideWithValue(InMemoryPrefsStore()),
          ],
          child: const FrameworkWzApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('=== STEP 1 settled ===');

      expect(find.byKey(const Key('login.submit')), findsOneWidget,
          reason: 'should be on /login');
      debugPrint('=== STEP 1 OK: login page rendered ===');

      await tester.enterText(find.byKey(const Key('login.username')), 'admin');
      await tester.enterText(find.byKey(const Key('login.password')), '123456');
      await tester.pump();

      await tester.tap(find.byKey(const Key('login.submit')));
      debugPrint('=== STEP 2 submit tapped ===');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      debugPrint('=== STEP 2 settled, looking for dashboard ===');

      // Dump current widget tree text content
      final allText = find.byType(Text).evaluate().map((e) {
        final w = e.widget as Text;
        return w.data ?? '';
      }).where((s) => s.isNotEmpty).toList();
      debugPrint('=== visible text snippets: ${allText.take(20).toList()} ===');

      expect(find.textContaining('你好'), findsAtLeastNWidgets(1),
          reason: 'should be on dashboard');
    } catch (e, st) {
      debugPrint('=== test threw: $e ===');
      debugPrint('$st');
      rethrow;
    } finally {
      debugPrint('=== captured ${caught.length} flutter errors ===');
      for (var i = 0; i < caught.length; i++) {
        debugPrint('--- error #$i ---');
        debugPrint(caught[i].exceptionAsString());
      }
    }
  });
}
