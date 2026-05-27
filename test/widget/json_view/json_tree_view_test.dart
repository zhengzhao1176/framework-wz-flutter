import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/json_view/json_tree_view.dart';

/// TC-JSON-001..003 — tree view rendering and folding.
void main() {
  Future<void> pump(WidgetTester tester, Object? data, {int initialDepth = 2}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonTreeView(data: data, initialDepth: initialDepth)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('TC-JSON-001 simple object renders keys', (tester) async {
    await pump(tester, {'a': 1, 'b': [2, 3]});
    expect(find.text('"a": '), findsOneWidget);
    expect(find.text('"b": '), findsOneWidget);
  });

  testWidgets('TC-JSON-002 deeper nesting collapsed beyond initialDepth', (tester) async {
    await pump(
      tester,
      {
        'a': {
          'b': {'c': 1},
        },
      },
      initialDepth: 1,
    );
    expect(find.text('"a": '), findsOneWidget);
    // 'c' is deeper than initialDepth so its name shouldn't appear yet
    expect(find.text('"c": '), findsNothing);
  });

  testWidgets('TC-JSON-003 tapping expand toggles children', (tester) async {
    await pump(tester, {'a': {'b': 1}}, initialDepth: 1);
    // Tap the arrow next to 'a'
    expect(find.text('"b": '), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_right).first);
    await tester.pumpAndSettle();
    expect(find.text('"b": '), findsOneWidget);
  });
}
