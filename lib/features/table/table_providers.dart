import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import 'user_models.dart';

abstract class UsersRepository {
  Future<List<UserRow>> fetchAll();
}

class DioUsersRepository implements UsersRepository {
  DioUsersRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<UserRow>> fetchAll() async {
    final res = await _dio.get<Object?>('/api/users');
    final body = res.data;
    final list = body is List
        ? body
        : (body is Map ? body['items'] as List? ?? const [] : const []);
    return list
        .cast<Map<String, Object?>>()
        .map(UserRow.fromJson)
        .toList(growable: false);
  }
}

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => DioUsersRepository(ref.watch(dioProvider)),
);

final usersProvider = FutureProvider<List<UserRow>>((ref) async {
  return ref.watch(usersRepositoryProvider).fetchAll();
});

class TableState {
  const TableState({
    this.search = '',
    this.sort = const SortSpec(key: SortKey.id, dir: SortDir.asc),
    this.page = 0,
    this.pageSize = 10,
    this.selected = const {},
  });

  final String search;
  final SortSpec sort;
  final int page;
  final int pageSize;
  final Set<int> selected;

  TableState copyWith({
    String? search,
    SortSpec? sort,
    int? page,
    int? pageSize,
    Set<int>? selected,
  }) {
    return TableState(
      search: search ?? this.search,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      selected: selected ?? this.selected,
    );
  }
}

class TableController extends StateNotifier<TableState> {
  TableController() : super(const TableState());

  void setSearch(String s) {
    state = state.copyWith(search: s, page: 0);
  }

  void toggleSort(SortKey key) {
    if (state.sort.key == key) {
      state = state.copyWith(sort: state.sort.toggle(), page: 0);
    } else {
      state = state.copyWith(
        sort: SortSpec(key: key, dir: SortDir.asc),
        page: 0,
      );
    }
  }

  void setPage(int p) {
    state = state.copyWith(page: p);
  }

  void setPageSize(int s) {
    state = state.copyWith(pageSize: s, page: 0);
  }

  void toggleSelect(int id) {
    final next = {...state.selected};
    if (!next.add(id)) next.remove(id);
    state = state.copyWith(selected: next);
  }

  void clearSelection() {
    state = state.copyWith(selected: const {});
  }
}

final tableControllerProvider =
    StateNotifierProvider<TableController, TableState>((_) => TableController());

/// Pure pipeline: filter → sort.
List<UserRow> applyFilterSort(List<UserRow> rows, TableState s) {
  final q = s.search.toLowerCase().trim();
  final filtered = q.isEmpty
      ? rows
      : rows
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.email.toLowerCase().contains(q))
          .toList(growable: false);

  final sorted = [...filtered];
  sorted.sort((a, b) {
    int cmp;
    switch (s.sort.key) {
      case SortKey.id:
        cmp = a.id.compareTo(b.id);
      case SortKey.name:
        cmp = a.name.compareTo(b.name);
      case SortKey.age:
        cmp = a.age.compareTo(b.age);
      case SortKey.createdAt:
        cmp = a.createdAt.compareTo(b.createdAt);
    }
    return s.sort.dir == SortDir.asc ? cmp : -cmp;
  });
  return sorted;
}

List<UserRow> paginate(List<UserRow> rows, TableState s) {
  final start = s.page * s.pageSize;
  if (start >= rows.length) return const [];
  final end = (start + s.pageSize).clamp(0, rows.length);
  return rows.sublist(start, end);
}
