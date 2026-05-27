import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'json_tree_view.dart';

class JsonViewPage extends StatefulWidget {
  const JsonViewPage({super.key});

  @override
  State<JsonViewPage> createState() => _JsonViewPageState();
}

class _JsonViewPageState extends State<JsonViewPage> {
  Object? _parsed;
  String? _error;

  static const _sample = '''
{
  "team": "Framework WZ",
  "members": [
    {"id": 1, "name": "Alice", "active": true, "roles": ["admin"]},
    {"id": 2, "name": "Bob", "active": false, "roles": ["editor", "guest"]}
  ],
  "config": {
    "theme": "light",
    "features": {"charts": true, "richtext": false},
    "meta": null
  }
}
''';

  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _sample);
    _parse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _parse() {
    try {
      setState(() {
        _parsed = jsonDecode(_ctrl.text);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _parsed = null;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final wide = c.maxWidth >= 800;
        final header = const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JSON展示列表',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                '配合 Collapse 折叠面板很轻易的就可以展示又长又臭的json字符串',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
        final left = Card(
          child: Column(
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    const Text('输入 JSON'),
                    const Spacer(),
                    TextButton.icon(
                      key: const Key('json.parse'),
                      onPressed: _parse,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('解析'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: TextField(
                    key: const Key('json.input'),
                    controller: _ctrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        final right = Card(
          child: _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      '解析失败：$_error',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                )
              : JsonTreeView(data: _parsed),
        );

        if (wide) {
          return Column(
            children: [
              header,
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: right),
                  ],
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            header,
            SizedBox(height: 220, child: left),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
