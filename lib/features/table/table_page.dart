import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/async_view.dart';
import 'csv_exporter.dart';
import 'table_providers.dart';
import 'user_models.dart';

class TablePage extends ConsumerWidget {
  const TablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final st = ref.watch(tableControllerProvider);
    final controller = ref.read(tableControllerProvider.notifier);

    Future<void> exportRaw() async {
      final all = users.valueOrNull ?? const [];
      final csv = usersToCsv(all);
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出原始数据 ${all.length} 行到剪贴板')),
      );
    }

    Future<void> exportFiltered() async {
      final all = users.valueOrNull ?? const [];
      final filtered = applyFilterSort(all, st);
      final csv = usersToCsv(filtered);
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出筛选后 ${filtered.length} 行到剪贴板')),
      );
    }

    // Mirrors original Vue layout:
    //   [search ─────────────────────────  pagination]
    //   ┌─ table ─────────────────────────────────────┐
    //   │  rows                                       │
    //   └─────────────────────────────────────────────┘
    //   [export-raw] [export-filtered]   共 N 条
    //   表格综合实例
    //   轻松完成业务需求…
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchRow(onSearch: controller.setSearch),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: AsyncView<List<UserRow>>(
                value: users,
                emptyChecker: (d) => d.isEmpty,
                onRetry: () => ref.invalidate(usersProvider),
                dataBuilder: (all) {
                  final filtered = applyFilterSort(all, st);
                  final visible = paginate(filtered, st);
                  return _DataGrid(
                    rows: visible,
                    state: st,
                    onSort: controller.toggleSort,
                    onToggleSelect: controller.toggleSelect,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                ElevatedButton.icon(
                  key: const Key('table.exportRaw'),
                  onPressed: exportRaw,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('导出原始数据'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton.icon(
                  key: const Key('table.export'),
                  onPressed: exportFiltered,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('导出排序和过滤后的数据'),
                ),
                Expanded(
                  child: _Pagination(
                    total: applyFilterSort(users.valueOrNull ?? const [], st).length,
                    state: st,
                    onPage: controller.setPage,
                    onPageSize: controller.setPageSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              '表格综合实例',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              '轻松完成业务需求，再也不用被产品催了',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.onSearch});
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextField(
        key: const Key('table.search'),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, size: 18),
          hintText: '按姓名或邮箱搜索',
          isDense: true,
        ),
        onChanged: onSearch,
      ),
    );
  }
}

class _DataGrid extends StatelessWidget {
  const _DataGrid({
    required this.rows,
    required this.state,
    required this.onSort,
    required this.onToggleSelect,
  });

  final List<UserRow> rows;
  final TableState state;
  final void Function(SortKey) onSort;
  final void Function(int id) onToggleSelect;

  Widget _header(String label, SortKey? key) {
    if (key == null) return Text(label);
    final isActive = state.sort.key == key;
    final asc = state.sort.dir == SortDir.asc;
    return InkWell(
      key: Key('table.header.${key.name}'),
      onTap: () => onSort(key),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isActive)
            Icon(
              asc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');
    return SingleChildScrollView(
      child: DataTable(
        showCheckboxColumn: true,
        headingRowColor:
            WidgetStatePropertyAll(AppColors.bgPage.withValues(alpha: 0.4)),
        columns: [
          DataColumn(label: _header('ID', SortKey.id)),
          DataColumn(label: _header('姓名', SortKey.name)),
          DataColumn(label: _header('邮箱', null)),
          DataColumn(label: _header('年龄', SortKey.age)),
          DataColumn(label: _header('注册时间', SortKey.createdAt)),
          const DataColumn(label: Text('状态')),
        ],
        rows: [
          for (final r in rows)
            DataRow(
              selected: state.selected.contains(r.id),
              onSelectChanged: (_) => onToggleSelect(r.id),
              cells: [
                DataCell(Text('${r.id}')),
                DataCell(Text(r.name)),
                DataCell(Text(r.email)),
                DataCell(Text('${r.age}')),
                DataCell(Text(df.format(r.createdAt))),
                DataCell(_StatusChip(value: r.status)),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.value});
  final String value;

  Color get _bg => switch (value) {
        'active' => AppColors.success.withValues(alpha: 0.15),
        'pending' => AppColors.warning.withValues(alpha: 0.15),
        'banned' => AppColors.danger.withValues(alpha: 0.15),
        _ => AppColors.borderLight,
      };

  Color get _fg => switch (value) {
        'active' => AppColors.success,
        'pending' => AppColors.warning,
        'banned' => AppColors.danger,
        _ => AppColors.textRegular,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(value, style: TextStyle(color: _fg, fontSize: 12)),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.total,
    required this.state,
    required this.onPage,
    required this.onPageSize,
  });

  final int total;
  final TableState state;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onPageSize;

  int get _maxPage => total == 0 ? 0 : ((total - 1) ~/ state.pageSize);

  @override
  Widget build(BuildContext context) {
    final canPrev = state.page > 0;
    final canNext = state.page < _maxPage;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text('共 $total 条'),
          const Spacer(),
          DropdownButton<int>(
            key: const Key('table.pageSize'),
            value: state.pageSize,
            items: const [10, 20, 50, 100]
                .map((s) => DropdownMenuItem(value: s, child: Text('$s/页')))
                .toList(),
            onChanged: (v) {
              if (v != null) onPageSize(v);
            },
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            key: const Key('table.prev'),
            icon: const Icon(Icons.chevron_left),
            onPressed: canPrev ? () => onPage(state.page - 1) : null,
          ),
          Text('${state.page + 1} / ${_maxPage + 1}'),
          IconButton(
            key: const Key('table.next'),
            icon: const Icon(Icons.chevron_right),
            onPressed: canNext ? () => onPage(state.page + 1) : null,
          ),
        ],
      ),
    );
  }
}
