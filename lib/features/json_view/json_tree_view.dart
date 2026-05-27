import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class JsonTreeView extends StatelessWidget {
  const JsonTreeView({
    super.key,
    required this.data,
    this.initialDepth = 2,
  });

  final Object? data;
  final int initialDepth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: _Node(
        name: 'root',
        value: data,
        depth: 0,
        initialOpenDepth: initialDepth,
      ),
    );
  }
}

class _Node extends StatefulWidget {
  const _Node({
    required this.name,
    required this.value,
    required this.depth,
    required this.initialOpenDepth,
  });

  final String? name;
  final Object? value;
  final int depth;
  final int initialOpenDepth;

  @override
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.depth < widget.initialOpenDepth;
  }

  bool get _isContainer => widget.value is Map || widget.value is List;

  int get _childCount {
    final v = widget.value;
    if (v is Map) return v.length;
    if (v is List) return v.length;
    return 0;
  }

  Future<void> _copy() async {
    final encoded = const JsonEncoder.withIndent('  ').convert(widget.value);
    await Clipboard.setData(ClipboardData(text: encoded));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制 JSON'), duration: Duration(milliseconds: 1500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final indent = EdgeInsets.only(left: widget.depth * AppSpacing.md);
    if (!_isContainer) {
      return Padding(
        padding: indent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.name != null) ...[
                Text(
                  '"${widget.name}": ',
                  style: const TextStyle(color: AppColors.primaryDark),
                ),
              ],
              Flexible(child: _LeafText(value: widget.value)),
            ],
          ),
        ),
      );
    }

    final isMap = widget.value is Map;
    final open = isMap ? '{' : '[';
    final close = isMap ? '}' : ']';

    return Padding(
      padding: indent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Icon(
                  _expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  size: 18,
                ),
              ),
              if (widget.name != null && widget.name != 'root')
                Text(
                  '"${widget.name}": ',
                  style: const TextStyle(color: AppColors.primaryDark),
                ),
              Text(open),
              if (!_expanded) ...[
                const Text(' … ', style: TextStyle(color: AppColors.textSecondary)),
                Text(close),
                const SizedBox(width: 8),
                Text(
                  '($_childCount)',
                  style: const TextStyle(
                    color: AppColors.textPlaceholder,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                tooltip: '复制子树',
                icon: const Icon(Icons.copy, size: 14),
                onPressed: _copy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (_expanded) ...[
            if (isMap)
              for (final entry in (widget.value as Map).entries)
                _Node(
                  name: entry.key.toString(),
                  value: entry.value,
                  depth: widget.depth + 1,
                  initialOpenDepth: widget.initialOpenDepth,
                )
            else
              for (var i = 0; i < (widget.value as List).length; i++)
                _Node(
                  name: '$i',
                  value: (widget.value as List)[i],
                  depth: widget.depth + 1,
                  initialOpenDepth: widget.initialOpenDepth,
                ),
            Padding(
              padding: EdgeInsets.only(left: (widget.depth + 1) * AppSpacing.md),
              child: Text(close),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeafText extends StatelessWidget {
  const _LeafText({required this.value});
  final Object? value;

  Color get _color {
    if (value is String) return AppColors.success;
    if (value is num) return AppColors.primary;
    if (value is bool) return Colors.purple;
    if (value == null) return AppColors.textPlaceholder;
    return AppColors.textRegular;
  }

  String get _display {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _display,
      style: TextStyle(
        color: _color,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
    );
  }
}
