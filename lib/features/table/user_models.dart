class UserRow {
  const UserRow({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.createdAt,
    required this.status,
  });

  final int id;
  final String name;
  final String email;
  final int age;
  final DateTime createdAt;
  final String status;

  factory UserRow.fromJson(Map<String, Object?> j) => UserRow(
        id: (j['id']! as num).toInt(),
        name: j['name']! as String,
        email: j['email']! as String,
        age: (j['age']! as num).toInt(),
        createdAt: DateTime.parse(j['createdAt']! as String),
        status: j['status']! as String,
      );
}

enum SortKey { id, name, age, createdAt }

enum SortDir { asc, desc }

class SortSpec {
  const SortSpec({required this.key, required this.dir});
  final SortKey key;
  final SortDir dir;

  SortSpec toggle() => SortSpec(
        key: key,
        dir: dir == SortDir.asc ? SortDir.desc : SortDir.asc,
      );
}
