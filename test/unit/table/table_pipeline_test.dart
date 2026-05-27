import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/table/csv_exporter.dart';
import 'package:framework_wz/features/table/table_providers.dart';
import 'package:framework_wz/features/table/user_models.dart';

/// TC-TABLE-001..007 — pure pipeline + CSV.
void main() {
  UserRow row(int id, String name, int age, {String email = '', String status = 'active'}) {
    return UserRow(
      id: id,
      name: name,
      email: email.isEmpty ? 'user$id@example.com' : email,
      age: age,
      createdAt: DateTime(2024, 1, id),
      status: status,
    );
  }

  final users = [
    row(1, 'Alice', 30),
    row(2, 'Bob', 25),
    row(3, 'Carol', 40),
    row(4, '李伟', 35),
    row(5, 'Dave', 28),
    row(6, 'Eve', 50),
    row(7, 'Frank', 22),
    row(8, 'Grace', 60),
    row(9, 'Henry', 45),
    row(10, 'Ivy', 33),
    row(11, 'Jack', 41),
  ];

  test('TC-TABLE-001 default page size 10', () {
    const s = TableState();
    final visible = paginate(applyFilterSort(users, s), s);
    expect(visible.length, 10);
  });

  test('TC-TABLE-002 sort by age ascending', () {
    final s = TableState(sort: const SortSpec(key: SortKey.age, dir: SortDir.asc));
    final sorted = applyFilterSort(users, s);
    expect(sorted.map((u) => u.age).take(3), [22, 25, 28]);
  });

  test('TC-TABLE-003 sort by age descending', () {
    final s = TableState(sort: const SortSpec(key: SortKey.age, dir: SortDir.desc));
    final sorted = applyFilterSort(users, s);
    expect(sorted.first.age, 60);
  });

  test('TC-TABLE-004 paginate to page 2 returns next slice', () {
    const s = TableState(page: 1, pageSize: 5);
    final visible = paginate(applyFilterSort(users, s), s);
    expect(visible.map((u) => u.id), [6, 7, 8, 9, 10]);
  });

  test('TC-TABLE-005 search filters by name OR email', () {
    const s = TableState(search: 'ali');
    final filtered = applyFilterSort(users, s);
    expect(filtered.map((u) => u.name), ['Alice']);
  });

  test('TC-TABLE-005 search is case-insensitive', () {
    const s = TableState(search: 'BOB');
    final filtered = applyFilterSort(users, s);
    expect(filtered, hasLength(1));
  });

  test('TC-TABLE-007 CSV escapes commas, quotes, newlines', () {
    final tricky = [
      UserRow(
        id: 1,
        name: 'O\'Hara, Jr.',
        email: 'a"b@c.com',
        age: 30,
        createdAt: DateTime(2024, 1, 1),
        status: 'active',
      ),
      UserRow(
        id: 2,
        name: 'multi\nline',
        email: 'x@y.com',
        age: 40,
        createdAt: DateTime(2024, 1, 2),
        status: 'pending',
      ),
    ];
    final csv = usersToCsv(tricky);
    // Header
    expect(csv, contains('id,name,email,age,createdAt,status'));
    // Quotes get doubled, commas/newlines force quoting
    expect(csv, contains('"O\'Hara, Jr."'));
    expect(csv, contains('"a""b@c.com"'));
    expect(csv, contains('"multi\nline"'));
  });

  test('CSV produces one header + N data rows', () {
    final csv = usersToCsv(users.take(3));
    expect(csv.split('\n').where((l) => l.isNotEmpty).length, 4);
  });
}
