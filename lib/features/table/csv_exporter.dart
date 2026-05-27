import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import 'user_models.dart';

/// Pure function — convert rows to RFC 4180 CSV.
///
/// `id, name, email, age, createdAt, status` in this exact order.
String usersToCsv(Iterable<UserRow> rows) {
  final fmt = DateFormat('yyyy-MM-dd HH:mm');
  final data = <List<Object?>>[
    ['id', 'name', 'email', 'age', 'createdAt', 'status'],
    for (final r in rows)
      [r.id, r.name, r.email, r.age, fmt.format(r.createdAt), r.status],
  ];
  return const ListToCsvConverter(eol: '\n').convert(data);
}
