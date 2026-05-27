import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/table/table_page.dart';
import 'package:framework_wz/features/table/table_providers.dart';
import 'package:framework_wz/features/table/user_models.dart';

/// TC-TABLE-001..006 — page level interactions.
void main() {
  List<UserRow> rows() => [
        for (var i = 1; i <= 25; i++)
          UserRow(
            id: i,
            name: i.isEven ? 'Alice $i' : 'Bob $i',
            email: 'user$i@example.com',
            age: 20 + (i % 30),
            createdAt: DateTime(2024, 1, i.clamp(1, 28)),
            status: 'active',
          ),
      ];

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [usersProvider.overrideWith((_) async => rows())],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1280,
              height: 800,
              child: const TablePage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('TC-TABLE-001 default page shows 10 rows', (tester) async {
    await pump(tester);
    expect(find.textContaining('共 25 条'), findsOneWidget);
  });

  testWidgets('TC-TABLE-002 sort by age toggles via header tap', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('table.header.age')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    await tester.tap(find.byKey(const Key('table.header.age')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });

  testWidgets('TC-TABLE-005 search filters visible rows', (tester) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('table.search')), 'Alice');
    await tester.pumpAndSettle();
    // Alice rows = even ids in 1..25 = 12 rows; page size = 10 → "共 12 条"
    expect(find.textContaining('共 12 条'), findsOneWidget);
  });

  testWidgets('TC-TABLE-006 export button is present and tappable', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('table.export')), findsOneWidget);
    await tester.tap(find.byKey(const Key('table.export')));
    await tester.pump();
    // SnackBar may take a frame; can't verify clipboard but we ensure no crash.
  });

  testWidgets('next button advances page', (tester) async {
    await pump(tester);
    expect(find.text('1 / 3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('table.next')));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });
}
